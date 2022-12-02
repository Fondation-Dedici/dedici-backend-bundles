//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct OneTimePreKeyResponse: ResourceRequestResponse {
    var id: UUIDv4
    var creationDate: Date
    var lastModificationDate: Date
    var identityId: UUIDv4
    var publicKey: PublicKey

    static func make(from resource: OneTimePreKey, and request: Request) throws -> EventLoopFuture<Self> {
        let response = try Self(from: resource, and: request)
        return request.eventLoop.makeSucceededFuture(response)
    }

    init(from resource: OneTimePreKey, and _: Request) throws {
        self.id = try .init(value: resource.id.require())
        self.creationDate = resource.creationDate
        self.lastModificationDate = resource.lastModificationDate
        self.identityId = try .init(value: resource.identityId)
        self.publicKey = try .init(from: resource.publicKey)
    }
}
