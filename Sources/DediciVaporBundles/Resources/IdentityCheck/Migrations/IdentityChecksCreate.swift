//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Fluent

internal struct IdentityChecksCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(IdentityCheck.schema)
            .id()
            .field(IdentityCheck.FieldKeys.creationDate, .datetime, .required)
            .field(IdentityCheck.FieldKeys.lastModificationDate, .datetime, .required)
            .field(IdentityCheck.FieldKeys.identityId, .uuid, .required)
            .field(IdentityCheck.FieldKeys.material, .sql(raw: "VARBINARY(32)"), .required)
            .field(IdentityCheck.FieldKeys.materialSignature, .sql(raw: "VARBINARY(64)"), .required)
            .field(IdentityCheck.FieldKeys.isSignatureValid, .bool, .required)
            .unique(
                on: IdentityCheck.FieldKeys.identityId,
                IdentityCheck.FieldKeys.material,
                IdentityCheck.FieldKeys.materialSignature
            )
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(IdentityCheck.schema)
            .delete()
    }
}
