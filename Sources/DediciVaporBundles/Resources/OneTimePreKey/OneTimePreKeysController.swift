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

internal struct OneTimePreKeysController: RouteCollection, ResourceController {
    typealias Resource = OneTimePreKey

    func boot(routes: RoutesBuilder) throws {
        let preKeys = routes
            .grouped(ForwardedAuthAuthenticator(), ForwardedAuthResult.guardMiddleware())
            .grouped("one-time-pre-keys")
        preKeys.get(use: getAllMyKeys)
        let preKeyIdComponent = "preKeyId"
        preKeys.get("ids", use: getAllMyKeyIds)
        preKeys.group(":\(preKeyIdComponent)") { identity in
            identity.get(use: defaultReadOne(
                idPathComponentName: preKeyIdComponent,
                resourceValidator: .init(checkPreKeyOwnership)
            ))
            identity.delete(use: defaultDeleteOne(
                idPathComponentName: preKeyIdComponent,
                resourceValidator: .init(checkPreKeyOwnership)
            ))
        }
        preKeys.post(use: defaultCreateOne(resourceValidator: .init(checkPreKeysFutureCount)))
        preKeys.patch(use: defaultCreateList(resourcesValidator: .init(checkPreKeysFutureCount)))
    }

    func getAllMyKeys(request: Request) throws -> EventLoopFuture<[OneTimePreKeyResponse]> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        return try defaultReadList(resourcesProvider: { request in
            OneTimePreKey.query(on: request.db)
                .filter(\.$identityId == authResult.identityId.value)
                .all().map { $0 }
        })(request)
    }

    func getAllMyKeyIds(request: Request) throws -> EventLoopFuture<OneTimePreKeyIdsList> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        return OneTimePreKeysRepository(database: request.db).keyIds(for: authResult.identityId.value)
            .map(OneTimePreKeyIdsList.init)
    }

    private func checkPreKeysFutureCount(_: OneTimePreKey, for request: Request) throws -> EventLoopFuture<Void> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let repository: DefaultRepository<OneTimePreKey> = request.repositories.get()
        let max = PublicConfiguration.current.oneTimePreKeysCount
        return repository.countKeys(for: authResult.identityId.value)
            .guard({ $0 + 1 <= max }, else: Abort(.badRequest, reason: "Total key count would exceed max"))
            .map { _ in }
    }

    private func checkPreKeysFutureCount(
        _ preKeys: [OneTimePreKey],
        for request: Request
    ) throws -> EventLoopFuture<Void> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let repository: DefaultRepository<OneTimePreKey> = request.repositories.get()
        let max = PublicConfiguration.current.oneTimePreKeysCount
        return repository.countKeys(for: authResult.identityId.value)
            .guard(
                { $0 + preKeys.count <= max },
                else: Abort(.badRequest, reason: "Total key count would exceed max")
            )
            .map { _ in }
    }

    private func checkPreKeyOwnership(_ preKey: OneTimePreKey, for request: Request) throws -> EventLoopFuture<Void> {
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
