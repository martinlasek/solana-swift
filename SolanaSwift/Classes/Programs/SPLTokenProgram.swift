//
//  SPLTokenProgram.swift
//  SolanaSwift
//
//  Created by Chung Tran on 11/6/20.
//

import Foundation

public extension SolanaSDK {
    struct SPLTokenProgram {
        // MARK: - Nested type
        private enum Index: UInt32 {
            case create                 = 0
            case assign                 = 1
            case transfer               = 2
            case createWithSeed         = 3
            case advanceNonceAccount    = 4
            case withdrawNonceAccount   = 5
            case initializeNonceAccount = 6
            case authorizeNonceAccount  = 7
            case allocate               = 8
            case allocateWithSeed       = 9
            case sssignWithSeed         = 10
        }
        
        // MARK: - Constants
        public static let splTokenProgramId = try! PublicKey(string: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        public static let programId = try! PublicKey(string: "11111111111111111111111111111111")
        public static let sysvarRent = try! PublicKey(string: "SysvarRent111111111111111111111111111111111")
        
        // MARK: - Instructions
        public static func createAccount(
            from fromPublicKey: PublicKey,
            toNewPubkey newPubkey: PublicKey,
            lamports: UInt64,
            space: UInt64 = AccountLayout.span,
            programPubkey: PublicKey = splTokenProgramId
        ) -> TransactionInstruction
        {
            let keys = [
                Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                Account.Meta(publicKey: newPubkey, isSigner: true, isWritable: true)
            ]
            
            let data = Index.create.encode([
                lamports,
                space,
                programPubkey
            ])
            return TransactionInstruction(keys: keys, programId: programId, data: data.bytes)
        }
        
        public static func initializeAccount(account: PublicKey, mint: PublicKey, owner: PublicKey) -> TransactionInstruction
        {
            let keys = [
                Account.Meta(publicKey: account, isSigner: false, isWritable: true),
                Account.Meta(publicKey: mint, isSigner: false, isWritable: false),
                Account.Meta(publicKey: owner, isSigner: false, isWritable: false),
                Account.Meta(publicKey: sysvarRent, isSigner: false, isWritable: false)
            ]
            
            let data: [UInt8] = [1]
            return TransactionInstruction(keys: keys, programId: splTokenProgramId, data: data)
        }
        
        public static func transfer(from fromPublicKey: PublicKey, to toPublicKey: PublicKey, lamports: UInt64) -> TransactionInstruction {
            let keys = [
                Account.Meta(publicKey: fromPublicKey, isSigner: true, isWritable: true),
                Account.Meta(publicKey: toPublicKey, isSigner: false, isWritable: true)
            ]
            
            let data = Index.transfer.encode([
                lamports
            ])
            return TransactionInstruction(keys: keys, programId: programId, data: data.bytes)
        }
    }
}

extension SolanaSDK.SPLTokenProgram {
    
}