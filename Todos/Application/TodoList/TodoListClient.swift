import Firebase
import ComposableArchitecture

struct TodoListClient {
  let fetch  : ()            -> Effect<[TodoState], AppError>
  let create : ()            -> Effect<Never, AppError>
  let remove : ([TodoState]) -> Effect<Never, AppError>
}

extension TodoListClient {
  static let live = Self(
    fetch: {
      Firestore
        .firestore()
        .collection("todos")
        .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
        .snapshotPublisher()
        .map({ $0.documents.compactMap({ try? $0.data(as: TodoState.self) }) })
        .mapError(AppError.init)
        .eraseToEffect()
    },
    create: {
      Effect.future { callback in
        do {
          let _ = try Firestore
            .firestore()
            .collection("todos")
            .addDocument(from: TodoState(userID: Auth.auth().currentUser!.uid, timestamp: Date()))
        } catch {
          callback(.failure(.init(error)))
        }
      }
    },
    remove: { todos in
      Effect.future { callback in
        todos.compactMap(\.id).forEach {
          Firestore
            .firestore()
            .collection("todos")
            .document($0)
            .delete { if let error = $0 { callback(.failure(.init(error))) } }
        }
      }
    }
  )
}
