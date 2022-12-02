//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import Vapor

public struct PublicConfiguration: Codable {
    public static let current: PublicConfiguration = {
        do {
            let oneTimePreKeysCount = try Environment.require(
                key: "ONE_TIME_PRE_KEYS_COUNT",
                using: Int.init
            )
            let oneTimePreKeysInitialCount = try Environment.require(
                key: "ONE_TIME_PRE_KEYS_INITIAL_COUNT",
                using: Int.init
            )
            let longTimePreKeyMaximumMaxAge = try Environment.require(
                key: "LONG_TIME_PRE_KEY_MAX_MAX_AGE",
                using: Int.init
            )
            let longTimePreKeyDefaultMaxAge = try Environment.require(
                key: "LONG_TIME_PRE_KEY_DEFAULT_MAX_AGE",
                using: Int.init
            )

            return PublicConfiguration(
                oneTimePreKeysCount: oneTimePreKeysCount,
                oneTimePreKeysInitialCount: oneTimePreKeysInitialCount,
                longTimePreKeyMaximumMaxAge: longTimePreKeyMaximumMaxAge,
                longTimePreKeyDefaultMaxAge: longTimePreKeyDefaultMaxAge
            )

        } catch {
            fatalError("Failed to load configuration because: \(error)")
        }
    }()

    public let oneTimePreKeysCount: Int
    public let oneTimePreKeysInitialCount: Int
    public let longTimePreKeyMaximumMaxAge: Int
    public let longTimePreKeyDefaultMaxAge: Int
}
