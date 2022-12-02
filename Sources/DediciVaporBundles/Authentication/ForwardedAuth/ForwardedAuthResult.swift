//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import Foundation
import Vapor

internal struct ForwardedAuthResult: Content, Authenticatable {
    let ownerId: UUIDv4
    let identityId: UUIDv4
    let identity: Identity
}
