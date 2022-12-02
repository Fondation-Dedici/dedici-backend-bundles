//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import FluentMySQLDriver
import Foundation
import Vapor

internal struct MigrationsConfiguration: AppConfiguration {
    func configure(_ application: Application) throws {
        let migrations: [Migration] = [
            IdentitiesCreate(),
            IdentityChecksCreate(),
            LongTermPreKeysCreate(),
            OneTimePreKeysCreate(),
            BundleCreate(),
        ]

        migrations.forEach { application.migrations.add($0) }
    }
}
