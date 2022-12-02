//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Vapor

internal final class OneTimePreKey: ResourceModel {
    static let schema = "one_time_pre_keys"

    @ID(key: FieldKeys.id)
    var id: UUID?

    @Field(key: FieldKeys.creationDate)
    var creationDate: Date

    @Field(key: FieldKeys.lastModificationDate)
    var lastModificationDate: Date

    @Field(key: FieldKeys.identityId)
    var identityId: UUID

    @Field(key: FieldKeys.publicKey)
    var publicKey: Data

    init() {}

    init(
        id: UUIDv4,
        creationDate: Date = Date(),
        lastModificationDate: Date = Date(),
        identityId: UUIDv4,
        publicKey: PublicKey
    ) {
        self.id = id.value
        self.creationDate = creationDate
        self.lastModificationDate = lastModificationDate
        self.identityId = identityId.value
        self.publicKey = publicKey.rawRepresentation
    }
}

extension OneTimePreKey {
    enum FieldKeys {
        static let id: FieldKey = .id
        static let creationDate: FieldKey = .string("creation_date")
        static let lastModificationDate: FieldKey = .string("last_modification_date")
        static let identityId: FieldKey = .string("identity_id")
        static let publicKey: FieldKey = .string("public_key")
    }
}

extension OneTimePreKey: HasDefaultResponse {
    typealias DefaultResponse = OneTimePreKeyResponse
}

extension OneTimePreKey: HasDefaultCreateOneBody {
    typealias DefaultCreateOneBody = OneTimePreKeyNew
}

extension OneTimePreKey: HasDefaultCreateListBody {
    typealias DefaultCreateListBody = OneTimePreKeyListNew
}
