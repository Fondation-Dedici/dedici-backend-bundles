//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import Foundation
import Vapor

internal enum SpecificError: DediciVaporToolbox.SpecificError {
    case consistencyCheckFailed(debugMessage: String)

    var rawValue: String {
        switch self {
        case .consistencyCheckFailed: return "consistencyCheckFailed"
        }
    }

    func body() throws -> Response.Body {
        switch self {
        case .consistencyCheckFailed(let debugMessage):
            return .init(data: try ContentConfiguration.jsonEncoder.encode(debugMessage))
        }
    }
}
