//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import Fluent
import Foundation
import Vapor

internal typealias OneTimePreKeysRepository = DefaultRepository<OneTimePreKey>

extension OneTimePreKeysRepository {
    func findFirstValid(
        for identityId: Identity.IDValue,
        database: Database? = nil
    ) -> EventLoopFuture<OneTimePreKey?> {
        OneTimePreKey.query(on: database ?? self.database)
            .filter(\.$identityId == identityId)
            .sort(\.$creationDate, .ascending)
            .first()
    }

    func countKeys(for identityId: Identity.IDValue, database: Database? = nil) -> EventLoopFuture<Int> {
        OneTimePreKey.query(on: database ?? self.database)
            .filter(\.$identityId == identityId)
            .count()
    }

    func keyIds(for identityId: Identity.IDValue, database: Database? = nil) -> EventLoopFuture<Set<UUID>> {
        OneTimePreKey.query(on: database ?? self.database)
            .filter(\.$identityId == identityId)
            .all(\.$id)
            .map(Set.init)
    }
}
