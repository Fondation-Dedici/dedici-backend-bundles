//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct OneTimePreKeyNew: Hashable {
    var id: UUIDv4?
    var publicKey: PublicKey
}

extension OneTimePreKeyNew: ResourceCreateOneRequestBody {
    typealias Resource = OneTimePreKey

    func asResource(considering request: Request) throws -> EventLoopFuture<Resource> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let preKey = OneTimePreKey(
            id: id ?? .init(),
            identityId: authResult.identityId,
            publicKey: publicKey
        )

        return request.eventLoop.makeSucceededFuture(preKey)
    }
}

extension OneTimePreKeyNew: ResourceCreateListRequestBodyItem {
    var resourceId: UUID { (id ?? .init()).value }
}
