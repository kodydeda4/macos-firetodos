//
//  Firebase+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/4/21.
//

import SwiftUI
import Combine
import Firebase
import AuthenticationServices

/// Firebase Errors.
struct FirebaseError: Error, Equatable {
  static func == (lhs: FirebaseError, rhs: FirebaseError) -> Bool {
    lhs.error.localizedDescription == rhs.error.localizedDescription
  }
  
  var error: Error
  
  init(_ error: Error) {
    self.error = error
  }
}

struct Firebase {
  
  /// Sign into Firebase anonymously.
  static func signIn() -> AnyPublisher<Result<Bool, FirebaseError>, Never> {
    let rv = PassthroughSubject<Result<Bool, FirebaseError>, Never>()
    
    Auth.auth().signInAnonymously { result, error in
      print(result.debugDescription)
      
      if let error = error {
        rv.send(.failure(FirebaseError(error)))
      } else {
        rv.send(.success(true))
      }
    }
    
    return rv.eraseToAnyPublisher()
  }
  
  /// Sign into Firebase using an email & password.
  static func signIn(with email: String, and password: String) -> AnyPublisher<Result<Bool, FirebaseError>, Never> {
    let rv = PassthroughSubject<Result<Bool, FirebaseError>, Never>()
    
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
      if let error = error {
        rv.send(.failure(FirebaseError(error)))
      } else {
        rv.send(.success(true))
      }
    }
    
    return rv.eraseToAnyPublisher()
  }
  
  /// Sign into Firebase after using appleID and nonce.
  ///
  /// - Parameters:
  ///   - appleID: Credential from a successful Apple ID authentication.
  ///   - nonce:   String that associates client session with ID token.
  
  static func signIn(
    using appleID: ASAuthorizationAppleIDCredential,
    and nonce: String
    
  ) -> AnyPublisher<Result<Bool, FirebaseError>, Never> {
    
    let rv = PassthroughSubject<Result<Bool, FirebaseError>, Never>()
    
    guard let appleIDToken = appleID.identityToken,
          let idTokenString = String(data: appleIDToken, encoding: .utf8)
            
    else { fatalError("FatalError: Apple authenticatication failed.") }
    
    Auth.auth().signIn(
      with: OAuthProvider.credential(
        withProviderID: "apple.com",
        idToken: idTokenString,
        rawNonce: nonce
        
      )) { authResult, error in
        
        switch error {
          
        case .none:
          rv.send(.success(true))
          
        case let .some(error):
          rv.send(.failure(FirebaseError(error)))
        }
      }
    
    return rv.eraseToAnyPublisher()
  }
  
  /// Sign out of Firebase.
  static func signOut() -> AnyPublisher<Result<Bool, FirebaseError>, Never> {
    let rv = PassthroughSubject<Result<Bool, FirebaseError>, Never>()
    
    do {
      try Auth.auth().signOut()
      rv.send(.success(true))
    } catch {
      rv.send(.failure(FirebaseError(error)))
    }
    
    return rv.eraseToAnyPublisher()
  }
}
