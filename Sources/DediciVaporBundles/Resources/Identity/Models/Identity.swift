//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Vapor

internal final class Identity: ResourceModel {
    static let schema = "identities"

    @ID(key: FieldKeys.id)
    var id: UUID?

    @Field(key: FieldKeys.creationDate)
    var creationDate: Date

    @Field(key: FieldKeys.lastModificationDate)
    var lastModificationDate: Date

    @Field(key: FieldKeys.ownerId)
    var ownerId: UUID

    @Field(key: FieldKeys.publicKey)
    var publicKey: Data

    @Field(key: FieldKeys.consistencySignature)
    var consistencySignature: Data?

    @Field(key: FieldKeys.consistencySignatureAuthorIdentityId)
    var consistencySignatureAuthorIdentityId: UUID?

    @Field(key: FieldKeys.deviceName)
    var deviceName: String?

    @Field(key: FieldKeys.deviceModel)
    var deviceModel: String?

    init() {}

    init(
        id: UUIDv4,
        creationDate: Date = Date(),
        lastModificationDate: Date = Date(),
        ownerId: UUIDv4,
        publicKey: PublicKey,
        deviceName: String?,
        deviceModel: String?,
        consistencySignature: IdentityResponse.ConsistencySignature?
    ) {
        self.id = id.value
        self.creationDate = creationDate
        self.lastModificationDate = lastModificationDate
        self.ownerId = ownerId.value
        self.publicKey = publicKey.rawRepresentation
        self.deviceName = deviceName
        self.deviceModel = deviceModel
        self.consistencySignature = consistencySignature?.value.rawRepresentation
        self.consistencySignatureAuthorIdentityId = consistencySignature?.authorIdentityId.value
    }

    func verifyThatItMade(_ signature: Signature, for identity: Identity) throws {
        let key: PublicKey
        do {
            key = try PublicKey(from: publicKey)
        } catch {
            throw SpecificError.consistencyCheckFailed(
                debugMessage: "Consistency signature author's public key is not a valid key because: \(error)."
            )
        }
        let data = [
            Data("identityApproval".utf8),
            ownerId.data,
            try id.require().data,
            try identity.id.require().data,
        ].reduce(Data(), +)
        do {
            try key.verify(signature, wasMadeFrom: data)
        } catch {
            throw SpecificError.consistencyCheckFailed(
                debugMessage: "\(data.asHexadecimalString()) Consistency check failed because: \(error)."
            )
        }
    }
}

extension Identity {
    enum FieldKeys {
        static let id: FieldKey = .id
        static let creationDate: FieldKey = .string("creation_date")
        static let lastModificationDate: FieldKey = .string("last_modification_date")
        static let ownerId: FieldKey = .string("owner_id")
        static let publicKey: FieldKey = .string("public_key")
        static let consistencySignature: FieldKey = .string("consistency_signature")
        static let consistencySignatureAuthorIdentityId: FieldKey = .string("consistency_signature_author_identity_id")
        static let deviceName: FieldKey = .string("device_name")
        static let deviceModel: FieldKey = .string("device_model")
    }
}

extension Identity: HasDefaultResponse {
    typealias DefaultResponse = IdentityResponse
}

extension Identity: HasDefaultCreateOneBody {
    typealias DefaultCreateOneBody = IdentityNew
}
