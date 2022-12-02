//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Vapor

internal final class Bundle: ResourceModel {
    static let schema = "bundles"

    @ID(key: FieldKeys.id)
    var id: UUID?

    @Field(key: FieldKeys.creationDate)
    var creationDate: Date

    @Field(key: FieldKeys.lastModificationDate)
    var lastModificationDate: Date

    @Field(key: FieldKeys.expirationDate)
    var expirationDate: Date?

    @Field(key: FieldKeys.initiatorIdentityId)
    var initiatorIdentityId: UUID

    @Field(key: FieldKeys.describedIdentityId)
    var describedIdentityId: UUID

    @Field(key: FieldKeys.otPreKeyId)
    var otPreKeyId: UUID?

    @Field(key: FieldKeys.otPreKeyPublicKey)
    var otPreKeyPublicKey: Data?

    @Field(key: FieldKeys.ltPreKeyId)
    var ltPreKeyId: UUID

    @Field(key: FieldKeys.ltPreKeyPublicKey)
    var ltPreKeyPublicKey: Data

    @Field(key: FieldKeys.ltPreKeyPublicKeySignature)
    var ltPreKeyPublicKeySignature: Data

    init() {}

    init(
        id: UUIDv4,
        creationDate: Date = Date(),
        lastModificationDate: Date = Date(),
        expirationDate: Date,
        initiatorIdentityId: UUIDv4,
        describedIdentityId: UUIDv4,
        otPreKey: (id: UUIDv4, publicKey: PublicKey)?,
        ltPreKeyId: UUIDv4,
        ltPreKeyPublicKey: PublicKey,
        ltPreKeyPublicKeySignature: Signature
    ) {
        self.id = id.value
        self.creationDate = creationDate
        self.lastModificationDate = lastModificationDate
        self.expirationDate = expirationDate
        self.initiatorIdentityId = initiatorIdentityId.value
        self.describedIdentityId = describedIdentityId.value
        self.otPreKeyId = otPreKey?.id.value
        self.otPreKeyPublicKey = otPreKey?.publicKey.rawRepresentation
        self.ltPreKeyId = ltPreKeyId.value
        self.ltPreKeyPublicKey = ltPreKeyPublicKey.rawRepresentation
        self.ltPreKeyPublicKeySignature = ltPreKeyPublicKeySignature.rawRepresentation
    }
}

extension Bundle {
    enum FieldKeys {
        static let id: FieldKey = .id
        static let creationDate: FieldKey = .string("creation_date")
        static let lastModificationDate: FieldKey = .string("last_modification_date")
        static let expirationDate: FieldKey = .string("expiration_date")
        static let initiatorIdentityId: FieldKey = .string("initiator_identity_id")
        static let describedIdentityId: FieldKey = .string("described_identity_id")
        static let otPreKeyId: FieldKey = .string("ot_pre_key_id")
        static let otPreKeyPublicKey: FieldKey = .string("ot_pre_key_public_key")
        static let ltPreKeyId: FieldKey = .string("lt_pre_key_id")
        static let ltPreKeyPublicKey: FieldKey = .string("lt_pre_key_public_key")
        static let ltPreKeyPublicKeySignature: FieldKey = .string("lt_pre_key_public_key_signature")
    }
}

extension Bundle: ModelCanExpire {
    var expirationDateField: FieldProperty<Bundle, Date?> { $expirationDate }
}

extension Bundle: HasDefaultResponse {
    typealias DefaultResponse = BundleResponse
}

extension Bundle: HasDefaultCreateOneBody {
    typealias DefaultCreateOneBody = BundleNew
}

extension Bundle: HasDefaultCreateListBody {
    typealias DefaultCreateListBody = BundleListNew
}
