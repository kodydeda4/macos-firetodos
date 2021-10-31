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

struct TodosClient {
  let fetch:   ()            -> Effect<[TodoState], APIError>
  let create:  ()            -> Effect<Bool, APIError>
  let update:  (TodoState)   -> Effect<Bool, APIError>
  let delete:  (TodoState)   -> Effect<Bool, APIError>
  let deleteX: ([TodoState]) -> Effect<Bool, APIError>
}

extension TodosClient {
  static var firestore: Self {
    let db = Firestore.firestore()
    let userID = Auth.auth().currentUser!.uid
    
    return Self(
      fetch: {
        let rv = PassthroughSubject<[TodoState], APIError>()
        db.collection("todos")
          .whereField("userID", isEqualTo: userID)
          .addSnapshotListener { querySnapshot, error in
            if let values = querySnapshot?.documents.compactMap({ try? $0.data(as: TodoState.self) }) {
              rv.send(values)
            }
            if let error = error {
              rv.send(completion: .failure(.init(error)))
            }
          }
        return rv.eraseToEffect()
      },
      create: {
        let rv = PassthroughSubject<Bool, APIError>()
        
        do {
          let _ = try
          db.collection("todos")
            .addDocument(from: TodoState(
              timestamp: Date(),
              userID: userID,
              text: "Untitled")
            )
          
          rv.send(true)
        }
        catch {
          rv.send(completion: .failure(.init(error)))
        }
        
        return rv.eraseToEffect()
      },
      update: { todo in
        let rv = PassthroughSubject<Bool, APIError>()
        let id = todo.id!
        do {
          try
          db.collection("todos")
            .document(id)
            .setData(from: todo)
          rv.send(true)
        }
        catch {
          print(error)
          rv.send(completion: .failure(.init(error)))
        }
        return rv.eraseToEffect()
      },
      delete: { todo in
        let rv = PassthroughSubject<Bool, APIError>()
        
        Firestore.firestore().collection("todos").document(todo.id!).delete { error in
          if let error = error {
            rv.send(completion: .failure(.init(error)))
          } else {
            rv.send(true)
          }
        }
        return rv.eraseToEffect()
      },
      deleteX: { todos in
        let rv = PassthroughSubject<Bool, APIError>()
        
        todos.compactMap(\.id).forEach {
          Firestore.firestore().collection("todos").document($0).delete { error in
            if let error = error {
              rv.send(completion: .failure(.init(error)))
            } else {
              rv.send(true)
            }
          }
        }
        return rv.eraseToEffect()
      }
    )
  }
}
