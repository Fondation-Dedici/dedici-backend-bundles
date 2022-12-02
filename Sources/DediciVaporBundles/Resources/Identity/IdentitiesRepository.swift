//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciC25519
import DediciVaporFluentToolbox
import Fluent
import Foundation
import Vapor

internal typealias IdentitiesRepository = DefaultRepository<Identity>

extension IdentitiesRepository {
    func check(_ identityId: Identity.IDValue, isConsistentFor userId: UUID) -> EventLoopFuture<Void> {
        Identity.query(on: database)
            .filter(\.$ownerId == userId)
            .all()
            .flatMapThrowing { try Self.check(identityId, isConsistentFor: $0, logger: self.database.logger) }
    }

    static func check(_ identityId: Identity.IDValue, isConsistentFor identities: [Identity], logger: Logger) throws {
        guard let identity = identities.first(where: { $0.id == identityId }) else {
            throw Abort(.notFound)
        }
        let sortedIdentities = identities.sorted(by: { $0.creationDate < $1.creationDate })
        guard
            let signature = identity.consistencySignature,
            let authorId = identity.consistencySignatureAuthorIdentityId
        else {
            let isMissingBoth = identity.consistencySignature == nil
                && identity.consistencySignatureAuthorIdentityId == nil
            guard isMissingBoth else {
                throw SpecificError.consistencyCheckFailed(
                    debugMessage: "Identity has an invalid consistency signature."
                )
            }
            guard sortedIdentities.first?.id == identity.id else {
                throw SpecificError.consistencyCheckFailed(
                    debugMessage: "Identity doesn't have a consistency signature and is not the first."
                )
            }
            return
        }

        guard let authorIdentity = identities.first(where: { $0.id == authorId }) else {
            logger
                .warning(
                    "Could not find consistency signature author's identity (\(authorId)) amongst available ids [\(identities.compactMap { $0.id?.uuidString }.joined(separator: ", "))]."
                )
            throw SpecificError.consistencyCheckFailed(
                debugMessage: "Could not find consistency signature author's identity."
            )
        }

        guard authorIdentity.publicKey != identity.publicKey else {
            throw SpecificError.consistencyCheckFailed(
                debugMessage: "Consistency signature was self-made!"
            )
        }

        try authorIdentity.verifyThatItMade(Signature(from: signature), for: identity)
    }
}
