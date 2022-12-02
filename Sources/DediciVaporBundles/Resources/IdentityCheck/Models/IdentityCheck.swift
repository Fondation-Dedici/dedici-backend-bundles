//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Vapor

internal final class IdentityCheck: ResourceModel {
    static let schema = "identity_checks"

    @ID(key: FieldKeys.id)
    var id: UUID?

    @Field(key: FieldKeys.creationDate)
    var creationDate: Date

    @Field(key: FieldKeys.lastModificationDate)
    var lastModificationDate: Date

    @Field(key: FieldKeys.identityId)
    var identityId: UUID

    @Field(key: FieldKeys.material)
    var material: Data

    @Field(key: FieldKeys.materialSignature)
    var materialSignature: Data

    @Field(key: FieldKeys.isSignatureValid)
    var isSignatureValid: Bool

    init() {}

    init(
        id: UUIDv4,
        creationDate: Date = Date(),
        lastModificationDate: Date = Date(),
        identityId: UUIDv4,
        material: IdentityCheck.SignatureMaterial,
        materialSignature: Signature,
        isSignatureValid: Bool
    ) {
        self.id = id.value
        self.creationDate = creationDate
        self.lastModificationDate = lastModificationDate
        self.identityId = identityId.value
        self.material = material.rawRepresentation
        self.materialSignature = materialSignature.rawRepresentation
        self.isSignatureValid = isSignatureValid
    }
}

extension IdentityCheck {
    enum FieldKeys {
        static let id: FieldKey = .id
        static let creationDate: FieldKey = .string("creation_date")
        static let lastModificationDate: FieldKey = .string("last_modification_date")
        static let identityId: FieldKey = .string("identity_id")
        static let material: FieldKey = .string("material")
        static let materialSignature: FieldKey = .string("material_signature")
        static let isSignatureValid: FieldKey = .string("is_signature_valid")
    }
}
