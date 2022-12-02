//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Fluent

internal struct IdentitiesCreate: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Identity.schema)
            .id()
            .field(Identity.FieldKeys.creationDate, .datetime, .required)
            .field(Identity.FieldKeys.lastModificationDate, .datetime, .required)
            .field(Identity.FieldKeys.ownerId, .uuid, .required)
            .field(Identity.FieldKeys.publicKey, .sql(raw: "VARBINARY(32)"), .required)
            .field(Identity.FieldKeys.consistencySignature, .data)
            .field(Identity.FieldKeys.consistencySignatureAuthorIdentityId, .uuid)
            .field(Identity.FieldKeys.deviceName, .custom("VARCHAR(255)"))
            .field(Identity.FieldKeys.deviceModel, .custom("VARCHAR(63)"))
            .unique(on: Identity.FieldKeys.publicKey)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Identity.schema)
            .delete()
    }
}
