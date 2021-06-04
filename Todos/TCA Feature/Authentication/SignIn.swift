//
//  SignIn.swift
//  Todos
//
//  Created by Kody Deda on 6/4/21.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import CryptoKit
import AuthenticationServices

extension SignInWithAppleButton {
    static var currentNonce = String.randomNonce()
    
    init(
        _ f: @escaping (Result<Bool, FirestoreError>) -> Void
    ) {
        self.init(
            onRequest: SignInWithAppleButton.handleRequest,
            onCompletion: { f(handleAppleSignInResult(currentNonce: SignInWithAppleButton.currentNonce, result: $0.mapError(FirestoreError.init))) }
            
        )
    }
    
    static func handleRequest(_ request: ASAuthorizationAppleIDRequest) {
        SignInWithAppleButton.currentNonce = "ok"
        request.requestedScopes = [.fullName, .email]
        request.nonce = String.hash(input: SignInWithAppleButton.currentNonce)
        
    }
}





import Combine
import Firebase

func handleAppleSignInResult(
    currentNonce: String,
    result: Result<ASAuthorization, Error>

) -> Result<Bool, FirestoreError> {

//    let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
    var rv: Result<Bool, FirestoreError>?
    

    switch result {

    case let .success(authResults):

        switch authResults.credential {

        case let appleIDCredential as ASAuthorizationAppleIDCredential:

            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8)

             else { fatalError("FatalError: Apple authenticatication failed.") }


            Auth.auth().signIn(
                with: OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: currentNonce

                )) { authResult, error in

                switch error {

                case .none:
                    rv = .success(true)
                    //rv.send(.success(true))

                case let .some(error):
                    rv = .failure(FirestoreError(error))
                    //rv.send(.failure(FirestoreError(error)))
                }
            }

        default:
            break

        }

    case let .failure(error):
        print(error.localizedDescription)
        break
    }
    
    if let rv = rv {
        return rv
    } else {
        return .success(false)
    }
    

    
//    return rv
}

extension SignInWithAppleButton {
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
