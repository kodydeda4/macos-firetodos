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
  let create:  ()            -> Effect<Never, APIError>
  let update:  (TodoState)   -> Effect<Never, APIError>
  let remove:  (TodoState)   -> Effect<Never, APIError>
  let removeX: ([TodoState]) -> Effect<Never, APIError>
}

extension TodosClient {
  static let live = Self(
    fetch: {
      Firestore.firestore()
        .collection("todos")
        .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
        .snapshotPublisher()
        .map({ $0.documents.compactMap({ try? $0.data(as: TodoState.self) }) })
        .mapError(APIError.init)
        .eraseToEffect()
    },
    create: {
      .future { callback in
        do {
          let _ = try Firestore.firestore()
            .collection("todos")
            .addDocument(from: TodoState(
              userID: Auth.auth().currentUser!.uid,
              timestamp: Date()
            ))
          
        } catch {
          callback(.failure(.init(error)))
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
          callback(.failure(.init(error)))
        }
      }
    },
    remove: { todo in
      .future { callback in
        Firestore.firestore()
          .collection("todos")
          .document(todo.id!)
          .delete { if let error = $0 { callback(.failure(.init(error))) } }

      }
    },
    removeX: { todos in
      .future { callback in
        todos.compactMap(\.id).forEach {
          Firestore.firestore()
            .collection("todos")
            .document($0)
            .delete { if let error = $0 { callback(.failure(.init(error))) } }
        }
      }
    }
  )
}

// MARK: - Extensions
private extension Query {
  func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<QuerySnapshot, Error> {
    let publisher = PassthroughSubject<QuerySnapshot, Error>()
    
    let snapshotListener = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
      if let error = error {
        publisher.send(completion: .failure(error))
      } else if let snapshot = snapshot {
        publisher.send(snapshot)
      } else {
        fatalError()
      }
    }
    return publisher
      .handleEvents(receiveCancel: snapshotListener.remove)
      .eraseToAnyPublisher()
  }
}
