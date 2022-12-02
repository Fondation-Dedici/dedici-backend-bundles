//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import Fluent
import Foundation
import Vapor

internal typealias LongTermPreKeysRepository = DefaultRepository<LongTermPreKey>

extension LongTermPreKeysRepository {
    func findFirstValid(
        for identityId: Identity.IDValue,
        database: Database? = nil
    ) -> EventLoopFuture<LongTermPreKey?> {
        LongTermPreKey.query(on: database ?? self.database)
            .filter(\.$identityId == identityId)
            .filter(\.$expirationDate >= Date())
            .sort(\.$expirationDate, .descending)
            .first()
    }
}
