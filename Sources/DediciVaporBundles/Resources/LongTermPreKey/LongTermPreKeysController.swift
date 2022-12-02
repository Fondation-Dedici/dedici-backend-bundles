//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Curve25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Foundation
import Vapor

internal struct LongTermPreKeysController: RouteCollection, ResourceController {
    typealias Resource = LongTermPreKey

    func boot(routes: RoutesBuilder) throws {
        let preKeys = routes
            .grouped(ForwardedAuthAuthenticator(), ForwardedAuthResult.guardMiddleware())
            .grouped("long-term-pre-keys")
        preKeys.get(use: getAllMyKeys)
        let preKeyIdComponent = "preKeyId"
        preKeys.group(":\(preKeyIdComponent)") { identity in
            identity.get(use: defaultReadOne(idPathComponentName: preKeyIdComponent))
            identity.delete(use: defaultDeleteOne(
                idPathComponentName: preKeyIdComponent,
                resourceValidator: .init(checkPreKeyOwnership)
            ))
        }
        preKeys.post(use: defaultCreateOne(resourceValidator: .init(validateNewPreKey)))
    }

    func getAllMyKeys(request: Request) throws -> EventLoopFuture<[LongTermPreKeyResponse]> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        return try defaultReadList(resourcesProvider: { request in
            LongTermPreKey.query(on: request.db)
                .filter(\.$identityId == authResult.identityId.value)
                .all().map { $0 }
        })(request)
    }

    private func validateNewPreKey(_ newPreKey: LongTermPreKey, considering request: Request) -> EventLoopFuture<Void> {
        let repository: DefaultRepository<Identity> = request.repositories.get()
        return repository.find(newPreKey.identityId)
            .flatMapThrowing { (identity: Identity?) in
                guard let identity = identity else {
                    throw Abort(.badRequest, reason: "Identity not found.")
                }

                let verifies = Curve25519.verify(
                    signature: newPreKey.publicKeySignature,
                    for: newPreKey.publicKey,
                    publicKey: identity.publicKey
                )

                guard verifies else {
                    throw Abort(.badRequest, reason: "Failed to verify signature using identity's public key.")
                }
            }
    }

    private func checkPreKeyOwnership(_ preKey: LongTermPreKey, for request: Request) throws -> EventLoopFuture<Void> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let repository: DefaultRepository<Identity> = request.repositories.get()
        return repository.find(preKey.identityId)
            .flatMapThrowing { (identity: Identity?) in
                guard let identity = identity else {
                    throw Abort(.internalServerError, reason: "Identity not found.")
                }

                guard identity.ownerId == authResult.ownerId.value else { throw Abort(.forbidden) }
            }
    }
}
