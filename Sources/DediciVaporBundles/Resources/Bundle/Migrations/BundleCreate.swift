//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Fluent

internal struct BundleCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Bundle.schema)
            .id()
            .field(Bundle.FieldKeys.creationDate, .datetime, .required)
            .field(Bundle.FieldKeys.lastModificationDate, .datetime, .required)
            .field(Bundle.FieldKeys.expirationDate, .datetime, .required)
            .field(Bundle.FieldKeys.initiatorIdentityId, .uuid, .required)
            .field(Bundle.FieldKeys.describedIdentityId, .uuid, .required)
            .field(Bundle.FieldKeys.otPreKeyId, .uuid)
            .field(Bundle.FieldKeys.otPreKeyPublicKey, .sql(raw: "VARBINARY(32)"))
            .field(Bundle.FieldKeys.ltPreKeyId, .uuid, .required)
            .field(Bundle.FieldKeys.ltPreKeyPublicKey, .sql(raw: "VARBINARY(32)"), .required)
            .field(Bundle.FieldKeys.ltPreKeyPublicKeySignature, .sql(raw: "VARBINARY(64)"), .required)
            .unique(
                on: Bundle.FieldKeys.initiatorIdentityId,
                Bundle.FieldKeys.describedIdentityId,
                Bundle.FieldKeys.ltPreKeyId,
                Bundle.FieldKeys.otPreKeyId
            )
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Bundle.schema)
            .delete()
    }
}
