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
  let signInApple: (SignInWithAppleToken) -> Effect<User, APIError>
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
//      Effect.task {
//        try await Auth.auth().signIn(with: OAuthProvider.credential(
//          withProviderID: "apple.com",
//          idToken: token.appleID.description,
//          rawNonce: token.nonce
//        ))
//        .user
//      }
//    },
    
    signInApple: { token in
      let rv = PassthroughSubject<User, APIError>()
      Auth.auth().signIn(with: OAuthProvider.credential(
        withProviderID: "apple.com",
        idToken: token.appleID.description,
        rawNonce: token.nonce
      )) { _, error in
        if let user = Auth.auth().currentUser {
          rv.send(user)
        } else {
          rv.send(completion: .failure(.init(error)))
        }
      }
      return rv.eraseToEffect()
    }
  )
}
