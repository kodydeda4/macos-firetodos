//
//  SignIn.swift
//  Todos
//
//  Created by Kody Deda on 6/4/21.
//

import SwiftUI
import ComposableArchitecture
import Combine
import AuthenticationServices
import CryptoKit
import Firebase


extension SignInWithAppleButton {
    static var currentNonce = SignInWithAppleButton.randomNonce()
    
    // v1
    init(
        action: @escaping ((Result<ASAuthorization, Error>) -> Void)
    ) {
        self.init(
            onRequest: SignInWithAppleButton.handleRequest,
            onCompletion: action
        )
    }
    
    // v2
    init(
        action: @escaping ((ASAuthorizationAppleIDCredential) -> Void)
    ) {
        self.init(
            onRequest: SignInWithAppleButton.handleRequest,
            onCompletion: {
                if let credental = getASAuthorizationAppleIDCredential(result: $0) {
                    action(credental)
                }
                
//                action(getASAuthorizationAppleIDCredential(result: $0))
                
            }
        )
    }
}


func getAuthResults(_ result: Result<ASAuthorization, Error>) -> ASAuthorization? {
    switch result {
    
    case let .success(authResults) : return authResults
    case     .failure              : return nil
        
    }
}


func getCred(_ auth: ASAuthorization?) -> ASAuthorizationAppleIDCredential? {
    switch auth?.credential {
    
    case let appleIDCredential as ASAuthorizationAppleIDCredential:
        return appleIDCredential
        
    default:
        return nil
        
    }

//    ASAuthorizationAppleIDCredential
}


func getASAuthorizationAppleIDCredential(
    result: Result<ASAuthorization, Error>
    
) -> ASAuthorizationAppleIDCredential? {
    
//    let rv2 = PassthroughSubject<Result<ASAuthorizationAppleIDCredential, Error>, Never>()
    

    let auth = getAuthResults(result)
    let cred = getCred(auth)
    
    return cred
}
    


//    switch result {
//
//    case let .success(authResults):
//
//        switch authResults.credential {
//
//        case let appleIDCredential as ASAuthorizationAppleIDCredential:
//            return .success(appleIDCredential)
//
//        default:
//            return .failure(error)
//
//        }
//
//    case let .failure(error):
//        rv2.send(.failure(error))
//        break
//    }
//
//    return
//    return rv2.eraseToAnyPublisher()
//}













extension SignInWithAppleButton {
    static func handleRequest(_ request: ASAuthorizationAppleIDRequest) {
        SignInWithAppleButton.currentNonce = SignInWithAppleButton.randomNonce()
        request.requestedScopes = [.fullName, .email]
        request.nonce = SignInWithAppleButton.hash(input: SignInWithAppleButton.currentNonce)
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



