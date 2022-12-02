//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Foundation
import NIO
import Vapor

internal struct ForwardedAuthAuthenticator {}

extension ForwardedAuthAuthenticator: RequestAuthenticator {
    func authenticate(request: Request) -> EventLoopFuture<Void> {
        guard
            let authResult = request.headers.nxServerAuthResult,
            let identityIdString = authResult.extraAuth?["identity"]?.object?["identityId"]?.string,
            let identityId = UUIDv4(identityIdString)
        else { return request.eventLoop.makeSucceededFuture(()) }

        let repository: DefaultRepository<Identity> = request.repositories.get()
        return repository.find(identityId.value)
            .optionalMap { ForwardedAuthResult(ownerId: authResult.userId, identityId: identityId, identity: $0) }
            .map { $0.flatMap(request.auth.login) }
    }
}
