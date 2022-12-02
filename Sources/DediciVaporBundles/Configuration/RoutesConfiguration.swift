//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import Foundation
import Vapor

internal struct RoutesConfiguration: AppConfiguration {
    func configure(_ application: Application) throws {
        let collections: [RouteCollection] = [
            IdentitiesController(),
            IdentityChecksController(),
            LongTermPreKeysController(),
            OneTimePreKeysController(),
            BundlesController(),
        ]

        try collections.forEach(application.register(collection:))
    }
}
