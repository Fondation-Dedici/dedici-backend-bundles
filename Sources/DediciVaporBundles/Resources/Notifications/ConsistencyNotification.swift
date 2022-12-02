//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import FCM
import Fluent
import Foundation
import Vapor

internal struct ConsistencyNotification: Notification {
    static let type: UInt8 = 1

    let topic: String
    let identityId: UUID

    var data: [String: String]? {
        ["identityId": identityId.uuidString]
    }

    static func make(
        from content: ExtraAuthRequest<IdentityCheckNew>,
        considering request: Request
    ) throws -> EventLoopFuture<[Notification]> {
        request.db.query(Identity.self)
            .filter(\.$ownerId == content.userId.value)
            .all()
            .flatMapThrowing { (identities: [Identity]) throws -> [ConsistencyNotification] in
                try identities
                    .filter {
                    let id = try $0.id.require()
                    guard id != content.content.identityId.value else { return false }

                    do {
                        try IdentitiesRepository.check(id, isConsistentFor: identities, logger: request.logger)
                    } catch {
                        return false
                    }
                    return true
                }
                .map {
                    let topic = Self.topicForIdentity(withId: try $0.id.require())
                    return ConsistencyNotification(topic: topic, identityId: content.content.identityId.value)
                }
            }
    }
}
