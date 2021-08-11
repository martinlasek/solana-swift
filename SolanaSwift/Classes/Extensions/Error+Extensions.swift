//
//  Error+Extensions.swift
//  p2p_wallet
//
//  Created by Chung Tran on 10/03/2021.
//

import Foundation

extension Error {
    public var readableDescription: String {
        (self as? LocalizedError)?.errorDescription ?? localizedDescription
    }
    
    var isCouldNotRetrieveAccountInfoError: Bool {
        (self as? SolanaSDK.Error) == SolanaSDK.Error.other("Could not retrieve account info")
    }
}
