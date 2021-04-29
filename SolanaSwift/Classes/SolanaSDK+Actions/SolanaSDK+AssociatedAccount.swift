//
//  SolanaSDK+AssociatedAccount.swift
//  SolanaSwift
//
//  Created by Chung Tran on 29/04/2021.
//

import Foundation
import RxSwift

extension SolanaSDK {
    public func getOrCreateAssociatedTokenAccount(
        owner: PublicKey,
        tokenMint: PublicKey
    ) -> Single<PublicKey> {
        guard let associatedAddress = try? PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: tokenMint
        ) else {
            return .error(Error.other("Could not create associated token account"))
        }
        
        // check if token account exists
        return getAccountInfo(
            account: associatedAddress.base58EncodedString,
            decodedTo: AccountInfo.self
        )
            .map {$0 as BufferInfo<AccountInfo>?}
            .catchAndReturn(nil)
            .flatMap {info in
                // if associated token account has been created
                if info?.owner == PublicKey.tokenProgramId.base58EncodedString &&
                    info?.data.value != nil
                {
                    return .just(associatedAddress)
                }
                
                // if not, create one
                return self.createAssociatedTokenAccount(
                    for: owner,
                    tokenMint: tokenMint
                )
                    .map {_ in associatedAddress}
            }
    }
    
    func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        payer: Account? = nil,
        isSimulation: Bool = false
    ) -> Single<TransactionID> {
        // get account
        guard let payer = payer ?? accountStorage.account else {
            return .error(Error.unauthorized)
        }
        
        // generate address
        do {
            let associatedAddress = try PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint
            )
            
            // create instruction
            let instruction = AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    associatedProgramId: .splAssociatedTokenAccountProgramId,
                    programId: .tokenProgramId,
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: owner,
                    payer: payer.publicKey
                )
            
            // send transaction
            return serializeAndSend(
                instructions: [instruction],
                signers: [payer],
                isSimulation: isSimulation
            )
            
        } catch {
            return .error(error)
        }
    }
}
