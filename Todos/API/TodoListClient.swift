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
import CoreMedia

struct TodoListClient {
  let fetch:   ()            -> Effect<[TodoState], FirestoreError>
  let create:  ()            -> Effect<Bool, FirestoreError>
  let update:  (TodoState)   -> Effect<Bool, FirestoreError>
  let delete:  (TodoState)   -> Effect<Bool, FirestoreError>
  let deleteX: ([TodoState]) -> Effect<Bool, FirestoreError>
}

extension TodoListClient {
  static let live = TodoListClient(
    fetch: {
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
    create: {
      let rv = PassthroughSubject<Bool, FirestoreError>()
      
      do {
        let _ = try Firestore.firestore()
          .collection("todos")
          .addDocument(from: TodoState(
            timestamp: Date(),
            userID: Auth.auth().currentUser!.uid,
            text: "Untitled")
          )
        
        rv.send(true)
      }
      catch {
        rv.send(completion: .failure(FirestoreError(error)))
      }
      
      return rv.eraseToEffect()
    },
    update: { todo in
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
    delete: { todo in
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
    deleteX: { todos in
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
