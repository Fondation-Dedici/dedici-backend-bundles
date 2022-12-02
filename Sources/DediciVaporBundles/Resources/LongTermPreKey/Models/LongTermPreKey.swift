//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Vapor

internal final class LongTermPreKey: ResourceModel {
    static let schema = "long_term_pre_keys"

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

    @Field(key: FieldKeys.publicKeySignature)
    var publicKeySignature: Data

    @Field(key: FieldKeys.expirationDate)
    var expirationDate: Date?

    init() {}

    init(
        id: UUIDv4,
        creationDate: Date = Date(),
        lastModificationDate: Date = Date(),
        identityId: UUIDv4,
        publicKey: PublicKey,
        publicKeySignature: Signature,
        maxAge: Int
    ) {
        self.id = id.value
        self.creationDate = creationDate
        self.lastModificationDate = lastModificationDate
        self.identityId = identityId.value
        self.publicKey = publicKey.rawRepresentation
        self.publicKeySignature = publicKeySignature.rawRepresentation
        self.expirationDate = Date().addingTimeInterval(.init(maxAge))
    }
}

extension LongTermPreKey {
    enum FieldKeys {
        static let id: FieldKey = .id
        static let creationDate: FieldKey = .string("creation_date")
        static let lastModificationDate: FieldKey = .string("last_modification_date")
        static let identityId: FieldKey = .string("identity_id")
        static let publicKey: FieldKey = .string("public_key")
        static let publicKeySignature: FieldKey = .string("public_key_signature")
        static let expirationDate: FieldKey = .string("expiration_date")
    }
}

extension LongTermPreKey: ModelCanExpire {
    var expirationDateField: FieldProperty<LongTermPreKey, Date?> { $expirationDate }
}

extension LongTermPreKey: HasDefaultResponse {
    typealias DefaultResponse = LongTermPreKeyResponse
}

extension LongTermPreKey: HasDefaultCreateOneBody {
    typealias DefaultCreateOneBody = LongTermPreKeyNew
}
