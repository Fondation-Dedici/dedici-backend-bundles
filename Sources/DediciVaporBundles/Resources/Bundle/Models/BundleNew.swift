//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import DediciVaporToolbox
import Fluent
import Foundation
import Vapor

internal struct BundleNew {
    var describedIdentityId: UUIDv4
}

extension BundleNew: ResourceCreateOneRequestBody {
    typealias Resource = Bundle

    func asResource(considering request: Request) throws -> EventLoopFuture<Resource> {
        let authResult: ForwardedAuthResult = try request.auth.require()
        let bundles: BundlesRepository = request.repositories.get()

        let identities: DefaultRepository<Identity> = request.repositories.get()
        let otPreKeys: OneTimePreKeysRepository = request.repositories.get()
        let ltPreKeys: LongTermPreKeysRepository = request.repositories.get()

        let initiatorIdentityId = authResult.identityId
        let describedIdentityId = describedIdentityId

        guard initiatorIdentityId != describedIdentityId else {
            let id = initiatorIdentityId
            throw Abort(.badRequest, reason: "The identity of the initiator cannot be the described identity \(id)")
        }

        return request.db.transaction { database -> EventLoopFuture<Resource> in
            let bundle = bundles.findFirstValid(
                for: initiatorIdentityId.value,
                describing: describedIdentityId.value,
                from: database
            )

            return bundle.flatMap {
                if let existingBundle = $0 { return database.eventLoop.makeSucceededFuture(existingBundle) }

                let describedIdentity = identities.find(describedIdentityId.value, from: database)
                    .unwrap(or: Abort(.badRequest, reason: "Described identity not found"))
                let ltPreKey = ltPreKeys.findFirstValid(for: describedIdentityId.value, database: database)
                    .unwrap(or: Abort(.badRequest, reason: "Failed to get a valid long-term key"))
                let otPreKey = otPreKeys.findFirstValid(for: describedIdentityId.value, database: database)

                return describedIdentity.and(ltPreKey).and(otPreKey)
                    .flatMapThrowing { meta, otPreKey throws -> (Bundle, OneTimePreKey?) in
                        let bundle = Bundle(
                            id: .init(),
                            expirationDate: try meta.1.expirationDate.require(),
                            initiatorIdentityId: initiatorIdentityId,
                            describedIdentityId: describedIdentityId,
                            otPreKey: try otPreKey.flatMap {
                                try (UUIDv4(value: $0.id.require()), PublicKey(from: $0.publicKey))
                            },
                            ltPreKeyId: try UUIDv4(value: meta.1.id.require()),
                            ltPreKeyPublicKey: try PublicKey(from: meta.1.publicKey),
                            ltPreKeyPublicKeySignature: try Signature(from: meta.1.publicKeySignature)
                        )
                        return (bundle, otPreKey)
                    }
                    .flatMap { (bundle: Bundle, preKey: OneTimePreKey?) -> EventLoopFuture<Bundle> in
                        if let preKey = preKey {
                            return otPreKeys.delete(preKey, on: database).map { bundle }
                        } else {
                            return database.eventLoop.makeSucceededFuture(bundle)
                        }
                    }
            }
        }
    }
}

extension BundleNew: ResourceCreateListRequestBodyItem {
    var resourceId: UUID { describedIdentityId.value }
}
