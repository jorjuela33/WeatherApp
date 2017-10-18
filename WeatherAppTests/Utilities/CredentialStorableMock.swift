//
//  CredentialStorableMock.swift
//  KountyTests
//
//  Created by Jorge Orjuela on 9/15/17.
//  Copyright © 2017 Kounty. All rights reserved.
//

import Foundation
@testable import Kounty

class CredentialStorableMock: CredentialStorable {
    
    private var credential: URLCredential?
    
    // MARK: CredentialStorable
    
    func defaultCredential(for space: URLProtectionSpace) -> URLCredential? {
        return credential
    }
    
    func set(_ credential: URLCredential, for space: URLProtectionSpace) {
        self.credential = credential
    }
}
