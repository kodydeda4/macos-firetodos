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
  let id: ASAuthorizationAppleIDCredential
  let nonce: String
}

extension SignInWithAppleButton {
  init(onCompletion handleLogin: @escaping ((SignInWithAppleToken) -> Void)) {
    self.init(
      onRequest: { request in
        request.requestedScopes = [.fullName, .email]
        request.nonce = Nonce.rawValue.hash()
      },
      onCompletion: { authorization in
        guard let token = getSignInToken(from: authorization)
        else { return }
        handleLogin(token)
      }
    )
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
    return SignInWithAppleToken(id: c, nonce: Nonce.rawValue)
  }
  return nil
}

private struct Nonce {
  static var rawValue: String {
    func generate(length: Int = 32) -> String {
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
    return generate()
  }
}

/// Hash a String
private extension String {
  func hash() -> String {
    SHA256
      .hash(data: Data(self.utf8))
      .compactMap { String(format: "%02x", $0) }
      .joined()
  }
}
