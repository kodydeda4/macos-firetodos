import Firebase
import FirebaseFirestoreSwift
import ComposableArchitecture

struct TodoState: Equatable, Identifiable, Codable {
  @DocumentID var id: String?
  let userID: String
  var timestamp = Date()
  var text: String = "Untitled"
  var done: Bool = false
}

enum TodoAction: Equatable {
  case setText(String)
  case setDone
  case delete
  case updateAPI
  case didUpdateAPI(Result<Never, AppError>)
}

struct TodoEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let todoClient: TodoClient
}

let todoReducer = Reducer<TodoState, TodoAction, TodoEnvironment> { state, action, environment in
  switch action {
    
  case let .setText(text):
    state.text = text
    return Effect(value: .updateAPI)
    
  case .setDone:
    state.done.toggle()
    return Effect(value: .updateAPI)
    
  case .delete:
    return environment.todoClient.remove(state)
      .receive(on: environment.mainQueue)
      .catchToEffect(TodoAction.didUpdateAPI)
    
  case .updateAPI:
    return environment.todoClient.update(state)
      .receive(on: environment.mainQueue)
      .catchToEffect(TodoAction.didUpdateAPI)
    
  case let .didUpdateAPI(.failure(error)):
    print(error.localizedDescription)
    return .none
  }
}.debug()


struct TodoStore {
  static let `default` = Store(
    initialState: .init(
      userID: "GxscCXP9odUQucq6A5cBXJEiTBd2",
      timestamp: Date(),
      text: "Untitled"
    ),
    reducer: todoReducer,
    environment: .init(
      mainQueue: .main,
      todoClient: .live
    )
  )
}
