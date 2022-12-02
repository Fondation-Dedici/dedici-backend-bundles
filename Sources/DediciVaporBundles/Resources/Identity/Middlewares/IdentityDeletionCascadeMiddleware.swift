//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Fluent
import Foundation
import Vapor

internal struct IdentityDeletionCascadeMiddleware: ModelMiddleware {
    typealias Model = Identity

    func delete(model: Identity, force: Bool, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        let nextStep = next.delete(model, force: force, on: db)
        guard let identityId = model.id else { return nextStep }
        return nextStep
            .flatMap { IdentityCheck.query(on: db).filter(\.$identityId == identityId).delete() }
            .flatMap { LongTermPreKey.query(on: db).filter(\.$identityId == identityId).delete() }
            .flatMap { OneTimePreKey.query(on: db).filter(\.$identityId == identityId).delete() }
            .flatMap { Bundle.query(on: db).filter(\.$describedIdentityId == identityId).delete() }
            .flatMap { Bundle.query(on: db).filter(\.$initiatorIdentityId == identityId).delete() }
    }
}
