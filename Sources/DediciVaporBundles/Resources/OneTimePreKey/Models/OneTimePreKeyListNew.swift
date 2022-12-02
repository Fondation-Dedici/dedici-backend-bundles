//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct OneTimePreKeyListNew: ResourceCreateListRequestBody {
    typealias Item = OneTimePreKeyNew
    typealias Resource = OneTimePreKey
    typealias Element = Item

    var items: [OneTimePreKeyNew]
}
