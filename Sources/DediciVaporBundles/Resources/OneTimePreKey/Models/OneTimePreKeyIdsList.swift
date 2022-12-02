//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporFluentToolbox
import DediciVaporToolbox
import Foundation
import Vapor

internal struct OneTimePreKeyIdsList: Content {
    var ids: [UUID]

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(ids)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.ids = try container.decode([UUIDv4].self).map(\.value)
    }

    init<S: Sequence>(ids: S) where S.Element == UUID {
        self.ids = ids.map { $0 }
    }
}
