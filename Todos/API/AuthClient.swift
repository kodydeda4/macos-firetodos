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
  let signInAnonymously:   ()                                                        -> Effect<Bool, FirebaseError>
  let signInEmailPassword: (_ email: String, _ password: String)                     -> Effect<Bool, FirebaseError>
  let signInApple:         (_ id: ASAuthorizationAppleIDCredential, _ nonce: String) -> Effect<Bool, FirebaseError>
}

extension AuthClient {
  static let live = AuthClient(
    signInAnonymously: {
      let rv = PassthroughSubject<Bool, FirebaseError>()
      
      Auth.auth().signInAnonymously { result, error in
        print(result.debugDescription)
        
        if let error = error {
          rv.send(completion: .failure(FirebaseError(error)))
        } else {
          rv.send(true)
        }
      }
      
      return rv.eraseToEffect()
    },
    signInEmailPassword: { email, password in
      let rv = PassthroughSubject<Bool, FirebaseError>()
      
      Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
          rv.send(completion: .failure(FirebaseError(error)))
        } else {
          rv.send(true)
        }
      }
      
      return rv.eraseToEffect()
    },
    signInApple: { appleID, nonce in
      let rv = PassthroughSubject<Bool, FirebaseError>()
      
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
            rv.send(true)
          case let .some(error):
            rv.send(completion: .failure(FirebaseError(error)))
          }
        }
      return rv.eraseToEffect()
    }
  )
}
