import Firebase
import ComposableArchitecture

struct TodoClient {
  let update   : (TodoState)   -> Effect<Never, AppError>
  let remove   : (TodoState)   -> Effect<Never, AppError>
}

extension TodoClient {
  static let live = Self(
    update: { todo in
      Effect.future { callback in
        do {
          try Firestore
            .firestore()
            .collection("todos")
            .document(todo.id!)
            .setData(from: todo)
        } catch {
          callback(.failure(.init(error)))
        }
      }
    },
    remove: { todo in
      Effect.future { callback in
        Firestore
          .firestore()
          .collection("todos")
          .document(todo.id!)
          .delete { if let error = $0 { callback(.failure(.init(error))) } }
      }
    }
  )
}
