//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporToolbox
import Foundation
import Vapor

internal struct IdentityCheckNew: Hashable, Content {
    struct BundleKeys: Hashable, Content {
        let ltPreKey: LongTermPreKeyNew
        let otPreKeys: [OneTimePreKeyNew]

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let ltPreKey = try container.decode(LongTermPreKeyNew.self, forKey: .ltPreKey)
            let otPreKeys = try container.decode([OneTimePreKeyNew].self, forKey: .otPreKeys)

            guard !otPreKeys.isEmpty else {
                throw Abort(.badRequest, reason: "otPreKeys must contain at least 1 key")
            }
            let maxOtKeyCount = PublicConfiguration.current.oneTimePreKeysInitialCount
            guard otPreKeys.count <= maxOtKeyCount else {
                throw Abort(
                    .badRequest,
                    reason: "otPreKeys count cannot exceed \(maxOtKeyCount) (as specified in the configuration)"
                )
            }

            if let maxAge = ltPreKey.maxAge, maxAge > PublicConfiguration.current.longTimePreKeyMaximumMaxAge {
                throw Abort(
                    .badRequest,
                    reason: "maxAge cannot exceed \(maxAge) (as specified in the configuration)"
                )
            }

            self.ltPreKey = ltPreKey
            self.otPreKeys = otPreKeys
        }

        func storableLtPreKey(identityId: UUIDv4) -> LongTermPreKey {
            LongTermPreKey(
                id: ltPreKey.id ?? .init(),
                identityId: identityId,
                publicKey: ltPreKey.publicKey,
                publicKeySignature: ltPreKey.publicKeySignature,
                maxAge: ltPreKey.maxAge ?? PublicConfiguration.current.longTimePreKeyDefaultMaxAge
            )
        }

        func storableOtPreKeys(identityId: UUIDv4) -> [OneTimePreKey] {
            otPreKeys
                .reduce(into: [OneTimePreKey]()) { keys, key in
                    let storableKey = OneTimePreKey(
                        id: key.id ?? .init(),
                        identityId: identityId,
                        publicKey: key.publicKey
                    )
                    keys.append(storableKey)
                }
        }
    }

    let identityId: UUIDv4
    let publicKey: PublicKey?
    let material: IdentityCheck.SignatureMaterial
    let materialSignature: Signature
    let deviceName: String?
    let deviceModel: String?
    let consistencySignature: IdentityResponse.ConsistencySignature?
    let bundleKeys: BundleKeys?
}
