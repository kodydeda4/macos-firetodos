//
//  SignIn.swift
//  Todos
//
//  Created by Kody Deda on 6/4/21.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

struct SignInWithAppleToken: Equatable {
  let appleID: String
  let nonce: String
}

extension SignInWithAppleButton {
  init(onCompletion handleLogin: @escaping ((SignInWithAppleToken) -> Void)) {
    let currentNonce = SignInWithAppleButton.generateRandomNonce()
    
    self.init(
      onRequest: {
        $0.requestedScopes = [.fullName, .email]
        $0.nonce = currentNonce.hash()
      },
      onCompletion: {
        if let credential = SignInWithAppleToken.from($0, currentNonce) {
          handleLogin(credential)
        }
      }
    )
  }
}

extension SignInWithAppleToken {
  static func from(_ result: Result<ASAuthorization, Error>, _ nonce: String) -> SignInWithAppleToken? {
    try? (result.map(\.credential).get() as? ASAuthorizationAppleIDCredential)
      .flatMap(\.identityToken)
      .flatMap({ String(data: $0, encoding: .utf8) })
      .map({ SignInWithAppleToken(appleID: $0, nonce: nonce) })
  }
}

// MARK: - Helpers
private extension SignInWithAppleButton {
  static func generateRandomNonce(length: Int = 32) -> String {
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
}

extension String {
  func hash() -> String {
    SHA256
      .hash(data: Data(self.utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}
