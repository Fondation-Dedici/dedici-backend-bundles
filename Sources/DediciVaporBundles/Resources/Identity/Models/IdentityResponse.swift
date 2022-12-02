//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct IdentityResponse: Hashable, ResourceRequestResponse {
    public struct ConsistencySignature: Hashable, Content {
        let value: Signature
        let authorIdentityId: UUIDv4
    }

    var id: UUIDv4
    var creationDate: Date
    var lastModificationDate: Date
    var ownerId: UUIDv4
    var publicKey: PublicKey
    var consistencySignature: ConsistencySignature?
    let deviceName: String?
    let deviceModel: String?

    static func make(from resource: Identity, and request: Request) throws -> EventLoopFuture<Self> {
        let response = try Self(from: resource, and: request)
        return request.eventLoop.makeSucceededFuture(response)
    }

    init(from resource: Identity, and _: Request) throws {
        self.id = try .init(value: resource.id.require())
        self.creationDate = resource.creationDate
        self.lastModificationDate = resource.lastModificationDate
        self.ownerId = try .init(value: resource.ownerId)
        self.publicKey = try .init(from: resource.publicKey)
        self.deviceName = resource.deviceName
        self.deviceModel = resource.deviceModel

        if resource.consistencySignature != nil || resource.consistencySignatureAuthorIdentityId != nil {
            self.consistencySignature = .init(
                value: try .init(from: resource.consistencySignature.require()),
                authorIdentityId: try .init(value: resource.consistencySignatureAuthorIdentityId.require())
            )
        }
    }
}
