//
//  SignIn.swift
//  Todos
//
//  Created by Kody Deda on 6/4/21.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

extension SignInWithAppleButton {
    
    init(action loginUsing: @escaping (((ASAuthorizationAppleIDCredential), String) -> Void)) {
        self.init(
            onRequest: SignInWithAppleButton.handleRequest,
            onCompletion: {
                if let credental = SignInWithAppleButton.getAppleIDCredential(authorization: $0) {
                    loginUsing(credental, SignInWithAppleButton.currentNonce)
                }
            }
        )
    }
}

extension SignInWithAppleButton {
    static private(set) var currentNonce = SignInWithAppleButton.randomNonce()
    
    static func handleRequest(_ request: ASAuthorizationAppleIDRequest) {
        SignInWithAppleButton.currentNonce = SignInWithAppleButton.randomNonce()
        request.requestedScopes = [.fullName, .email]
        request.nonce = SignInWithAppleButton.hash(input: SignInWithAppleButton.currentNonce)
    }
        
    static func getAppleIDCredential(
        authorization: Result<ASAuthorization, Error>
    ) -> ASAuthorizationAppleIDCredential? {
        
        var authResults: ASAuthorization? {
            switch authorization {
            
            case let .success(authResults):
                return authResults
                
            case .failure:
                return nil
                
            }
        }
        
        var credential: ASAuthorizationAppleIDCredential? {
            switch authResults?.credential {
            
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                return appleIDCredential
                
            default:
                return nil
            }
        }
        
        return credential
    }
    
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



