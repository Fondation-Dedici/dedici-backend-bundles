//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Foundation
import Vapor

internal struct BundlesController: RouteCollection, ResourceController {
    typealias Resource = Bundle

    func boot(routes: RoutesBuilder) throws {
        let bundles = routes
            .grouped(ForwardedAuthAuthenticator(), ForwardedAuthResult.guardMiddleware())
            .grouped("bundles")
        bundles.patch(use: defaultCreateList(saveInsteadOfCreate: true))
        bundles.group(":bundleId") { identity in
            identity.delete(use: defaultDeleteOne(
                idPathComponentName: "bundleId",
                resourceValidator: .init(checkOwnership)
            ))
        }
    }

    func checkOwnership(of bundle: Bundle, for request: Request) throws -> EventLoopFuture<Void> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let identities: DefaultRepository<Identity> = request.repositories.get()
        return identities.find(bundle.initiatorIdentityId)
            .unwrap(or: Abort(.internalServerError, reason: "Could not find bundle's initiator's identity"))
            .flatMapThrowing {
                guard $0.ownerId == authResult.ownerId.value else { throw Abort(.forbidden) }
            }
    }
}
