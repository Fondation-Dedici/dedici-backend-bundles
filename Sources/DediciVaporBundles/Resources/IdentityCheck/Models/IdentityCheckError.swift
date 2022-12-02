//
// Copyright (c) 2022 Dediĉi
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

internal enum IdentityCheckError: Error {
    case signatureVerificationFailed
    case materialHasBeenUsedBefore
    case missingPublicKeyToCreateNewIdentity
}
