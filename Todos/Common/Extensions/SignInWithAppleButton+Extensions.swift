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
  static var currentNonce = Nonce()
  
  init(onCompletion handleLogin: @escaping ((SignInWithAppleToken) -> Void)) {
    self.init(
      onRequest: {
        $0.requestedScopes = [.fullName, .email]
        $0.nonce = SignInWithAppleButton.currentNonce.rawValue.hash()
      },
      onCompletion: {
        if let token = getSignInToken(from: $0) {
          handleLogin(token)
        }
      }
    )
  }
}

struct SignInWithAppleToken: Equatable {
  let appleID: ASAuthorizationAppleIDCredential
  let nonce: Nonce
}

struct Nonce: Equatable {
  var rawValue: String {
    
    func createNonce(length: Int = 32) -> String {
      precondition(length > 0)
      let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
    return createNonce()
  }
}


// MARK: - Helpers
private extension String {
  func hash() -> String {
    SHA256
      .hash(data: Data(self.utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}


// MARK: - Supporting Methods
fileprivate func getSignInToken(from authorization: Result<ASAuthorization, Error>) -> SignInWithAppleToken? {
  
  var authResults: ASAuthorization? {
    switch authorization {
      
    case let .success(value):
      return value
      
    case .failure:
      return nil
    }
  }
  var credential: ASAuthorizationAppleIDCredential? {
    switch authResults?.credential {
      
    case let value as ASAuthorizationAppleIDCredential:
      return value
      
    default:
      return nil
    }
  }
  
  if let c = credential {
    return SignInWithAppleToken(
      appleID: c,
      nonce: SignInWithAppleButton.currentNonce
    )
  }
  return nil
}

//import Combine
//// MARK: - Supporting Methods
//fileprivate func getSignInToken2(from authorization: Result<ASAuthorization, Error>) -> SignInWithAppleToken? {
////  guard let authResults = authorization.map(\.credential)
////  else { return nil }
//
//  let a = Just(authorization)
//    .compactMap { $0 as? ASAuthorizationAppleIDCredential }
//    .map { SignInWithAppleToken(id: $0, nonce: SignInWithAppleButton.currentNonce) }
//    .eraseToAnyPublisher()
//
//
//
//  return nil
//}





