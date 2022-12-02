//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Fluent

internal struct LongTermPreKeysCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(LongTermPreKey.schema)
            .id()
            .field(LongTermPreKey.FieldKeys.creationDate, .datetime, .required)
            .field(LongTermPreKey.FieldKeys.lastModificationDate, .datetime, .required)
            .field(LongTermPreKey.FieldKeys.identityId, .uuid, .required)
            .field(LongTermPreKey.FieldKeys.publicKey, .sql(raw: "VARBINARY(32)"), .required)
            .field(LongTermPreKey.FieldKeys.publicKeySignature, .sql(raw: "VARBINARY(64)"), .required)
            .field(LongTermPreKey.FieldKeys.expirationDate, .datetime, .required)
            .unique(on: LongTermPreKey.FieldKeys.identityId, LongTermPreKey.FieldKeys.publicKey)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(LongTermPreKey.schema)
            .delete()
    }
}
