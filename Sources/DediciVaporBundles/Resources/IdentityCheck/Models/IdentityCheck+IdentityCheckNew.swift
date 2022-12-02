//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import DediciVaporToolbox
import Foundation
import Vapor

extension IdentityCheck {
    convenience init(id: UUIDv4, newIdentityCheck: IdentityCheckNew) {
        self.init(
            id: id,
            identityId: newIdentityCheck.identityId,
            material: newIdentityCheck.material,
            materialSignature: newIdentityCheck.materialSignature,
            isSignatureValid: true
        )
    }
}
