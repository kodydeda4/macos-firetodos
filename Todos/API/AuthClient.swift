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
  let signup: (_ email: String, _ password: String) -> Effect<User, Error>
  let signInAnonymously: () -> Effect<User, Error>
  let signInEmailPassword: (_ email: String, _ password: String) -> Effect<User, Error>
  let signInApple: (SignInWithAppleToken) -> Effect<User, Error>
}

extension AuthClient {
  static let live = AuthClient(
    signup: { email, password in
      .task {
        try await Auth.auth().createUser(withEmail: email, password: password).user
      }
    },
    signInAnonymously: {
      .task {
        try await Auth.auth().signInAnonymously().user
      }
    },
    signInEmailPassword: { email, password in
      .task {
        try await Auth.auth().signIn(withEmail: email, password: password).user
      }
    },
//    signInApple: { token in
//      .task {
//        try await Auth.auth().signIn(with: OAuthProvider.credential(
//          withProviderID: "apple.com",
//          idToken: token.appleID,
//          rawNonce: token.nonce
//        ))
//      }
//    }
    
    signInApple: { token in
      .future { callback in
        Auth.auth().signIn(with: OAuthProvider.credential(
          withProviderID: "apple.com",
          idToken: token.appleID,
          rawNonce: token.nonce
        )) { _, error in
          if let user = Auth.auth().currentUser {
            callback(.success(user))
          } else if let error = error {
            callback(.failure(error))
          } else {
            fatalError()
          }
        }
      }
    }
    
    // MARK: - END
  )
}
