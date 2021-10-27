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
import CoreMedia

struct AuthClient {
  let signInAnonymously:   ()                                                        -> Effect<User, FirebaseError>
  let signInEmailPassword: (_ email: String, _ password: String)                     -> Effect<User, FirebaseError>
  let signInApple:         (_ id: ASAuthorizationAppleIDCredential, _ nonce: String) -> Effect<User, FirebaseError>
}

extension AuthClient {
  static let live = AuthClient(
    signInAnonymously: {
      let rv = PassthroughSubject<User, FirebaseError>()
      
      Auth.auth().signInAnonymously { _, _ in
        if let user = Auth.auth().currentUser {
          rv.send(user)
          return
        }
        rv.send(completion: .failure(.signInAnonymously))
      }
      
      return rv.eraseToEffect()
    },
    signInEmailPassword: { email, password in
      let rv = PassthroughSubject<User, FirebaseError>()
      
      Auth.auth().signIn(withEmail: email, password: password) { _, _ in
        if let user = Auth.auth().currentUser {
          rv.send(user)
          return
        }
        rv.send(completion: .failure(.signInEmailPassword))
      }
      
      return rv.eraseToEffect()
    },
    signInApple: { appleID, nonce in
      let rv = PassthroughSubject<User, FirebaseError>()
      
      guard let appleIDToken = appleID.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
              
      else { fatalError("FatalError: Apple authenticatication failed.") }
      
      Auth.auth().signIn(
        with: OAuthProvider.credential(
          withProviderID: "apple.com",
          idToken: idTokenString,
          rawNonce: nonce
        )
      ) { _, _ in
        if let user = Auth.auth().currentUser {
          rv.send(user)
          return
        }
        rv.send(completion: .failure(.signInApple))
      }
      return rv.eraseToEffect()
    }
  )
}
