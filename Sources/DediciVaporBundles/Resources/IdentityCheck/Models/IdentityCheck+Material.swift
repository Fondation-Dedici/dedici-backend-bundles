//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import Foundation

extension IdentityCheck {
    struct SignatureMaterial: Hashable, Codable, DataRepresentable {
        enum Error: Swift.Error {
            case wrongLength(expectedLength: Int = SignatureMaterial.length, actualLength: Int)
        }

        static var length: Int = 32

        let rawRepresentation: Data

        init<Bytes: Sequence>(from bytes: Bytes) throws where Bytes.Element == UInt8 {
            let data = Data(bytes)
            guard data.count == Self.length else {
                throw Error.wrongLength(actualLength: data.count)
            }

            self.rawRepresentation = data
        }
    }
}
