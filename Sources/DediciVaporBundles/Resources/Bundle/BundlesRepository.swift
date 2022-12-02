//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import Fluent
import Foundation
import Vapor

internal typealias BundlesRepository = DefaultRepository<Bundle>

extension BundlesRepository {
    func findFirstValid(
        for initiatorIdentityId: Identity.IDValue,
        describing describedIdentityId: Identity.IDValue,
        from database: Database? = nil
    ) -> EventLoopFuture<Bundle?> {
        Bundle.query(on: database ?? self.database)
            .filter(\.$describedIdentityId == describedIdentityId)
            .filter(\.$initiatorIdentityId == initiatorIdentityId)
            .filter(\.$expirationDate >= Date())
            .first()
    }
}
