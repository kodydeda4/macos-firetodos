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
  
  /// String associating client session with ID token
  static private var currentNonce = randomNonce()
  
  /// Attempts Apple sign-in and passes id and nonce to `onCompletion` for API validation.
  init(onCompletion loginUsing: @escaping (((ASAuthorizationAppleIDCredential), String) -> Void)) {
    self.init(
      onRequest: { request in
        
        /// 1. update current nonce
        SignInWithAppleButton.currentNonce = randomNonce()
        
        /// 2. update request
        request.requestedScopes = [.fullName, .email]
        request.nonce = hash(input: SignInWithAppleButton.currentNonce)
      },
      
      onCompletion: { authorizationToken in
        
        /// 3. unwrap appleID
        if let credental = getAppleIDCredential(from: authorizationToken) {
          
          /// 4. pass appleID & nonce to `onCompletion`
          loginUsing(credental, SignInWithAppleButton.currentNonce)
        }
      }
    )
  }
}

// MARK:- Supporting Methods

/// Given `Result<ASAuthorization, Error>`,
/// returns `ASAuthorizationAppleIDCredential?`

fileprivate func getAppleIDCredential(
  from authorization: Result<ASAuthorization, Error>
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


/// Generates random `nonce` String that associates client session with ID token.
fileprivate func randomNonce(length: Int = 32) -> String {
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

/// Hash a String
fileprivate func hash(input: String) -> String {
  let inputData = Data(input.utf8)
  
  let hashString = SHA256
    .hash(data: inputData)
    .compactMap { String(format: "%02x", $0) }
    .joined()
  
  return hashString
}
