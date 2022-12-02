//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import Vapor

internal struct IdentitySignature: Content {
    var signature: Signature
}
