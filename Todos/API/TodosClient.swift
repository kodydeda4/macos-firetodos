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
  let attachListener: ()     -> Effect<[TodoState], APIError>
  let create:  ()            -> Effect<Never, Error>
  let update:  (TodoState)   -> Effect<Never, Error>
  let delete:  (TodoState)   -> Effect<Never, Error>
  let deleteX: ([TodoState]) -> Effect<Never, Error>
}

extension TodosClient {
  static let live = Self(
    attachListener: {
      let rv = PassthroughSubject<[TodoState], APIError>()
      Firestore.firestore()
        .collection("todos")
        .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
        .addSnapshotListener { querySnapshot, error in
          if let values = querySnapshot?.documents.compactMap({ snapshot in try? snapshot.data(as: TodoState.self) }) {
            rv.send(values)
          } else {
            rv.send(completion: .failure(.init(error)))
          }
        }
      return rv.eraseToEffect()
    },
    create: {
      .future { callback in
        do {
          let _ = try Firestore.firestore()
            .collection("todos")
            .addDocument(from: TodoState(
              timestamp: Date(),
              userID: Auth.auth().currentUser!.uid,
              text: "Untitled")
            )
          
        } catch {
          callback(.failure(error))
        }
      }
    },
    update: { todo in
      .future { callback in
        do {
          try Firestore.firestore()
            .collection("todos")
            .document(todo.id!)
            .setData(from: todo)
          
        } catch {
          callback(.failure(error))
        }
      }
    },
    delete: { todo in
      .future { callback in
        Firestore.firestore()
          .collection("todos")
          .document(todo.id!)
          .delete { error in if let error = error { callback(.failure(error)) } }
      }
    },
    deleteX: { todos in
      .future { callback in
        todos.compactMap(\.id).forEach {
          Firestore.firestore()
            .collection("todos")
            .document($0)
            .delete { error in if let error = error { callback(.failure(error)) } }
        }
      }
    }
  )
}
