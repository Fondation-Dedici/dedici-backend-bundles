//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Foundation
import Vapor

internal struct ModelMiddlewaresConfiguration: AppConfiguration {
    func configure(_ application: Application) throws {
        let middlewares: [AnyModelMiddleware] = [
            ResourceModelMiddleware<Bundle>(),
            ResourceModelMiddleware<Identity>(),
            ResourceModelMiddleware<IdentityCheck>(),
            ResourceModelMiddleware<LongTermPreKey>(),
            ResourceModelMiddleware<OneTimePreKey>(),
        ]

        middlewares.forEach { application.databases.middleware.use($0) }
    }
}
