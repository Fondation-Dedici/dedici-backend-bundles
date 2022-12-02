//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct IdentityNew: Codable, ResourceCreateOneRequestBody {
    typealias Resource = Identity

    var id: UUIDv4?
    var publicKey: PublicKey
    let deviceName: String?
    let deviceModel: String?
    let consistencySignature: IdentityResponse.ConsistencySignature?

    func asResource(considering request: Request) throws -> EventLoopFuture<Resource> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let body = try request.content.decode(Self.self)
        let identity = Identity(
            id: body.id ?? .init(),
            ownerId: authResult.ownerId,
            publicKey: body.publicKey,
            deviceName: deviceName,
            deviceModel: deviceModel,
            consistencySignature: consistencySignature
        )

        return request.eventLoop.makeSucceededFuture(identity)
    }
}
