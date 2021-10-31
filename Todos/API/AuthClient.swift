//
//  UserClient.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import ComposableArchitecture
import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import AuthenticationServices

struct AuthClient {
  let signInAnonymously: () -> Effect<User, APIError>
  let signInEmailPassword: (_ email: String, _ password: String) -> Effect<User, APIError>
  let signInApple: (SignInWithAppleToken) -> Effect<User, APIError>
}

extension AuthClient {
  static var firebase: Self {
    let auth = Auth.auth()
    
    return Self(
      signInAnonymously: {
        let rv = PassthroughSubject<User, APIError>()
        auth.signInAnonymously { _, error in
          if let user = Auth.auth().currentUser {
            rv.send(user)
          } else {
            rv.send(completion: .failure(.firebase(error?.localizedDescription)))
          }
        }
        return rv.eraseToEffect()
      },
      signInEmailPassword: { email, password in
        let rv = PassthroughSubject<User, APIError>()
        
        auth.signIn(withEmail: email, password: password) { _, error in
          if let user = Auth.auth().currentUser {
            rv.send(user)
          } else {
            rv.send(completion: .failure(.firebase(error?.localizedDescription)))
          }
        }
        return rv.eraseToEffect()
      },
      signInApple: { token in
        let rv = PassthroughSubject<User, APIError>()
        let credential = OAuthProvider.credential(
          withProviderID: "apple.com",
          idToken: token.appleID.description,
          rawNonce: token.nonce
        )
        auth.signIn(with: credential) { _, error in
          if let user = Auth.auth().currentUser {
            rv.send(user)
          } else {
            rv.send(completion: .failure(.firebase(error?.localizedDescription)))
          }
        }
        return rv.eraseToEffect()
      }
    )
  }
}
