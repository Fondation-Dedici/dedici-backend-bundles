//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct BundleResponse: ResourceRequestResponse {
    typealias Resource = Bundle

    struct OneTimePreKey: Hashable, Content {
        let id: UUIDv4
        let publicKey: PublicKey
    }

    struct LongTermPreKey: Hashable, Content {
        let id: UUIDv4
        let publicKey: PublicKey
        let publicKeySignature: Signature
    }

    var id: UUIDv4
    var creationDate: Date
    var lastModificationDate: Date
    var expirationDate: Date
    var initiatorIdentityId: UUIDv4
    var describedIdentityId: UUIDv4
    var otPreKey: OneTimePreKey?
    var ltPreKey: LongTermPreKey

    static func make(from resource: Bundle, and request: Request) throws -> EventLoopFuture<Self> {
        let response = try Self(from: resource, and: request)
        return request.eventLoop.makeSucceededFuture(response)
    }

    init(from resource: Bundle, and _: Request) throws {
        let otPreKey: OneTimePreKey?
        if let id = resource.otPreKeyId, let pk = resource.otPreKeyPublicKey {
            otPreKey = try .init(
                id: .init(value: id),
                publicKey: .init(from: pk)
            )
        } else {
            otPreKey = nil
        }
        let ltPreKey = try LongTermPreKey(
            id: .init(value: resource.ltPreKeyId),
            publicKey: .init(from: resource.ltPreKeyPublicKey),
            publicKeySignature: .init(from: resource.ltPreKeyPublicKeySignature)
        )

        self.id = try .init(value: resource.id.require())
        self.creationDate = resource.creationDate
        self.lastModificationDate = resource.lastModificationDate
        self.expirationDate = try resource.expirationDate.require()
        self.initiatorIdentityId = try .init(value: resource.initiatorIdentityId)
        self.describedIdentityId = try .init(value: resource.describedIdentityId)
        self.otPreKey = otPreKey
        self.ltPreKey = ltPreKey
    }
}
