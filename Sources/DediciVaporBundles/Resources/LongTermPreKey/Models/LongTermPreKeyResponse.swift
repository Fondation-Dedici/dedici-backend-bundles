//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct LongTermPreKeyResponse: ResourceRequestResponse {
    var id: UUIDv4
    var creationDate: Date
    var lastModificationDate: Date
    var identityId: UUIDv4
    var publicKey: Data
    var publicKeySignature: Data
    var expirationDate: Date

    static func make(from resource: LongTermPreKey, and request: Request) throws -> EventLoopFuture<Self> {
        let response = try Self(from: resource, and: request)
        return request.eventLoop.makeSucceededFuture(response)
    }

    init(from resource: LongTermPreKey, and _: Request) throws {
        self.id = try .init(value: resource.id.require())
        self.creationDate = resource.creationDate
        self.lastModificationDate = resource.lastModificationDate
        self.identityId = try .init(value: resource.identityId)
        self.publicKey = resource.publicKey
        self.publicKeySignature = resource.publicKeySignature
        self.expirationDate = try resource.expirationDate.require()
    }
}
