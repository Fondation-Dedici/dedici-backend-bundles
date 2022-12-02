//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Fluent

internal struct OneTimePreKeysCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(OneTimePreKey.schema)
            .id()
            .field(OneTimePreKey.FieldKeys.creationDate, .datetime, .required)
            .field(OneTimePreKey.FieldKeys.lastModificationDate, .datetime, .required)
            .field(OneTimePreKey.FieldKeys.identityId, .uuid, .required)
            .field(OneTimePreKey.FieldKeys.publicKey, .sql(raw: "VARBINARY(32)"), .required)
            .unique(on: OneTimePreKey.FieldKeys.identityId, OneTimePreKey.FieldKeys.publicKey)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(OneTimePreKey.schema)
            .delete()
    }
}
