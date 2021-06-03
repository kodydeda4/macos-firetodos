//
//  String+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/3/21.
//

import CryptoKit
import AuthenticationServices

// String+Extensions
extension String {
    
    static func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    static func hash(input: String) -> String {
        let inputData = Data(input.utf8)
        
        let hashString = SHA256
            .hash(data: inputData)
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        return hashString
    }
}
