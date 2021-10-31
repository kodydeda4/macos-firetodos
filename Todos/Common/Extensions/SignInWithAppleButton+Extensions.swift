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
        if let credential = try? $0.map(\.credential).get() as? ASAuthorizationAppleIDCredential {
          handleLogin(SignInWithAppleToken(
            appleID: credential,
            nonce: SignInWithAppleButton.currentNonce
          ))
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






