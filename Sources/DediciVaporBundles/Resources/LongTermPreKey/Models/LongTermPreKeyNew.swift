//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct LongTermPreKeyNew: ResourceCreateOneRequestBody, Hashable, Validatable {
    typealias Resource = LongTermPreKey

    static func validations(_ validations: inout Validations) {
        let maximumMaxAge = PublicConfiguration.current.longTimePreKeyMaximumMaxAge
        validations.add("maxAge", as: Int.self, is: .range(0 ... maximumMaxAge), required: false)
    }

    var id: UUIDv4?
    var publicKey: PublicKey
    var publicKeySignature: Signature
    var maxAge: Int?

    func asResource(considering request: Request) throws -> EventLoopFuture<Resource> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let body = try request.content.decode(LongTermPreKeyNew.self)
        let preKey = LongTermPreKey(
            id: body.id ?? .init(),
            identityId: authResult.identityId,
            publicKey: body.publicKey,
            publicKeySignature: body.publicKeySignature,
            maxAge: body.maxAge ?? PublicConfiguration.current.longTimePreKeyDefaultMaxAge
        )

        return request.eventLoop.makeSucceededFuture(preKey)
    }
}
