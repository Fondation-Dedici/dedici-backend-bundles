//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import FCM
import Fluent
import Foundation
import Vapor

internal struct IdentityChecksController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let identities = routes.grouped("identity-checks")
        identities.post(use: postIdentityCheck)
    }

    func postIdentityCheck(request: Request) throws -> EventLoopFuture<ExtraAuthResponse<JsonObject>> {
        let requestContent = try request.content.decode(ExtraAuthRequest<IdentityCheckNew>.self)
        let newIdentityCheck = requestContent.content
        let ownerId = requestContent.userId
        let identities = IdentitiesRepository(database: request.db)
        let ltPreKeys = LongTermPreKeysRepository(database: request.db)
        let otPreKeys = OneTimePreKeysRepository(database: request.db)
        let identityChecks = DefaultRepository<IdentityCheck>(database: request.db)

        return Identity.find(newIdentityCheck.identityId.value, on: request.db)
            .flatMap { (identity: Identity?) -> EventLoopFuture<Identity> in
                if let identity = identity { return request.eventLoop.makeSucceededFuture(identity) }

                guard let publicKey = newIdentityCheck.publicKey else {
                    let error = IdentityCheckError.missingPublicKeyToCreateNewIdentity
                    request.logger.error("\(error)")
                    return request.eventLoop.makeFailedFuture(error)
                }
                let identityId = newIdentityCheck.identityId
                let identity = Identity(
                    id: identityId,
                    ownerId: ownerId,
                    publicKey: publicKey,
                    deviceName: requestContent.content.deviceName,
                    deviceModel: requestContent.content.deviceModel,
                    consistencySignature: requestContent.content.consistencySignature
                )
                if let keys = newIdentityCheck.bundleKeys {
                    let otKeys = keys.storableOtPreKeys(identityId: identityId)
                    let ltKey = keys.storableLtPreKey(identityId: identityId)

                    return identities.saving(identity)
                        .flatMap { (_: Identity) -> EventLoopFuture<Identity> in
                            EventLoopFuture<Void>.andAllSucceed(
                                [otPreKeys.save(otKeys), ltPreKeys.save(ltKey)],
                                on: request.eventLoop
                            )
                            .map { identity }
                        }
                } else {
                    return identities.saving(identity)
                }
            }
            .flatMapThrowing {
                guard $0.ownerId == ownerId.value else { throw Abort(.forbidden) }
                return $0
            }
            .flatMap { (identity: Identity) -> EventLoopFuture<Identity> in
                IdentityCheck.query(on: request.db)
                    .filter(\.$material == newIdentityCheck.material.rawRepresentation)
                    .filter(\.$identityId == newIdentityCheck.identityId.value)
                    .first()
                    .flatMapThrowing {
                        guard $0 == nil else { throw IdentityCheckError.materialHasBeenUsedBefore }
                        return identity
                    }
            }
            .flatMapThrowing { (identity: Identity) in
                try self.verify(that: newIdentityCheck, from: request, checks: identity)
                return identity
            }
            .flatMap { (_: Identity) -> EventLoopFuture<Void> in
                identities
                    .check(newIdentityCheck.identityId.value, isConsistentFor: ownerId.value)
                    .flatMapError { error -> EventLoopFuture<Void> in
                        do {
                            return try ConsistencyNotification.make(from: requestContent, considering: request)
                                .tryFlatMap { notifications in
                                    let requests = try notifications
                                        .map { try self.sendNotification(notification: $0, considering: request) }
                                    return EventLoopFuture<Void>.andAllSucceed(requests, on: request.eventLoop)
                                }
                                .flatMapThrowing { throw error }
                        } catch {
                            return request.eventLoop.makeFailedFuture(error)
                        }
                    }
            }
            .flatMap { _ -> EventLoopFuture<ExtraAuthResponse<JsonObject>> in
                let idCheckId = UUIDv4()
                let response = ExtraAuthResponse<JsonObject>(
                    id: idCheckId,
                    content: [
                        "identityId": .string(newIdentityCheck.identityId.value.uuidString),
                    ]
                )
                let identityCheck = IdentityCheck(id: idCheckId, newIdentityCheck: newIdentityCheck)
                return identityChecks.save(identityCheck).map { response }
            }
    }

    private func verify(that identityCheck: IdentityCheckNew, from request: Request, checks identity: Identity) throws {
        guard let publicKey = try? PublicKey(from: identity.publicKey) else {
            request.logger
                .error("Invalid stored public key for identity \(identity.id?.uuidString ?? "?")")
            throw Abort(.internalServerError)
        }

        let material = identityCheck.material
        let signature = identityCheck.materialSignature
        guard publicKey.verifies(signature, wasMadeFrom: material) else {
            throw IdentityCheckError.signatureVerificationFailed
        }
    }

    private func sendNotification(
        notification: Notification,
        considering request: Request
    ) throws -> EventLoopFuture<Void> {
        var data = notification.data ?? [:]

        data["type"] = data["type"] ?? "\(type(of: notification).type)"

        let fcmMessage = FCMMessage(
            topic: notification.topic,
            notification: notification.fcmNotification,
            data: data,
            name: notification.name,
            android: notification.android,
            webpush: notification.webpush,
            apns: notification.apns
        )

        request.logger.info("Sending notification on \(notification.topic)")
        return request.fcm.send(fcmMessage)
            .map { _ in }
    }
}
