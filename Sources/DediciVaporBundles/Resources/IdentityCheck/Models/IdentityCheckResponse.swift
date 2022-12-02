//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import Foundation
import Vapor

internal struct IdentityCheckResponse: Content, Hashable {
    let identityId: UUIDv4

    init(identityCheck: IdentityCheck) throws {
        self.identityId = try .init(value: identityCheck.identityId)
    }
}
