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

struct UserClient {
  let signInAnonymously:   ()                                                        -> Effect<Bool, FirebaseError>
  let signInEmailPassword: (_ email: String, _ password: String)                     -> Effect<Bool, FirebaseError>
  let signInApple:         (_ id: ASAuthorizationAppleIDCredential, _ nonce: String) -> Effect<Bool, FirebaseError>
  
  let fetchTodos: () -> Effect<[TodoState], FirestoreError>
  let createTodo: ()          -> Effect<Bool, FirestoreError>
  let updateTodo: (TodoState) -> Effect<Bool, FirestoreError>
  let removeTodo: (TodoState) -> Effect<Bool, FirestoreError>
  let removeTodos: ([TodoState]) -> Effect<Bool, FirestoreError>
}

extension UserClient {
  static let live = UserClient(
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
    },
    fetchTodos: {
      let rv = PassthroughSubject<[TodoState], FirestoreError>()
      Firestore.firestore()
        .collection("todos")
        .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
        .addSnapshotListener { querySnapshot, error in
          if let values = querySnapshot?.documents.compactMap({ snapshot in try? snapshot.data(as: TodoState.self) }) {
            rv.send(values)
          } else if let error = error {
            rv.send(completion: .failure(FirestoreError(error)))
          }
        }
      return rv.eraseToEffect()
    },
    createTodo: {
      let rv = PassthroughSubject<Bool, FirestoreError>()
      
      do {
        let _ = try Firestore.firestore()
          .collection("todos")
          .addDocument(from: TodoState())
        
        rv.send(true)
      }
      catch {
        rv.send(completion: .failure(FirestoreError(error)))
      }
      
      return rv.eraseToEffect()
    },
    updateTodo: { todo in
      let rv = PassthroughSubject<Bool, FirestoreError>()
      do {
        try Firestore.firestore()
          .collection("todos")
          .document(todo.id!)
          .setData(from: todo)
        rv.send(true)
      }
      catch {
        print(error)
        rv.send(completion: .failure(FirestoreError(error)))
      }
      return rv.eraseToEffect()
    },
    removeTodo: { todo in
      let rv = PassthroughSubject<Bool, FirestoreError>()
      
      Firestore.firestore().collection("todos").document(todo.id!).delete { error in
        if let error = error {
          rv.send(completion: .failure(FirestoreError(error)))
        } else {
          rv.send(true)
        }
      }
      return rv.eraseToEffect()
    },
    removeTodos: { todos in
      let rv = PassthroughSubject<Bool, FirestoreError>()
      
      todos.map(\.id).forEach { id in
        Firestore.firestore().collection("todos").document(id!).delete { error in
          if let error = error {
            rv.send(completion: .failure(FirestoreError(error)))
          } else {
            rv.send(true)
          }
        }
      }
      return rv.eraseToEffect()
    }
  )
}
