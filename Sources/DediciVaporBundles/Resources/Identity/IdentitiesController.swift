//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Foundation
import Vapor

internal struct IdentitiesController: RouteCollection, ResourceController {
    typealias Resource = Identity

    func boot(routes: RoutesBuilder) throws {
        let identities = routes
            .grouped(ForwardedAuthAuthenticator(), ForwardedAuthResult.guardMiddleware())
            .grouped("identities")
        identities.get(use: getAllForOwner)
        identities.group(":identityId") { identity in
            identity.get(use: defaultReadOne(idPathComponentName: "identityId"))
            identity.delete(use: defaultDeleteOne(
                idPathComponentName: "identityId",
                resourceValidator: .init(checkOwnership)
            ))
            identity.patch("sign", use: signIdentity)
        }
        identities.post(use: defaultCreateOne())
    }

    func signIdentity(request: Request) throws -> EventLoopFuture<IdentityResponse> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let identityId: Identity.IDValue = try request.parameters.require("identityId")
        let identities = IdentitiesRepository(database: request.db)
        let body = try request.content.decode(IdentitySignature.self)

        return identities
            .find(identityId)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { (targetedIdentity: Identity) throws -> EventLoopFuture<Identity> in
                try self.checkOwnership(of: targetedIdentity, for: request)
                try authResult.identity.verifyThatItMade(body.signature, for: targetedIdentity)

                targetedIdentity.consistencySignature = body.signature.rawRepresentation
                targetedIdentity.consistencySignatureAuthorIdentityId = authResult.identityId.value

                return identities.saving(targetedIdentity)
            }
            .flatMap { $0 }
            .flatMapThrowing { try IdentityResponse.make(from: $0, and: request) }
            .flatMap { $0 }
    }

    func checkOwnership(of identity: Identity, for request: Request) throws {
        let authResult: ForwardedAuthResult = try request.auth.require()
        guard identity.ownerId == authResult.ownerId.value else { throw Abort(.forbidden) }
    }

    func getAllForOwner(request: Request) throws -> EventLoopFuture<[IdentityResponse]> {
        let ownerId: UUIDv4 = try request.query.get(at: "ownerId")
        return try defaultReadList(resourcesProvider: { (request: Request) throws -> EventLoopFuture<[Identity]?> in
            request.db.query(Identity.self)
                .filter(\.$ownerId == ownerId.value)
                .all().map { $0 }
        })(request)
    }
}
