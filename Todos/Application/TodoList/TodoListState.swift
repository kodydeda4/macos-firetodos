import Combine
import ComposableArchitecture
import IdentifiedCollections

struct TodoListState: Equatable {
  var todos: IdentifiedArrayOf<TodoState> = []
  var alert: AlertState<TodoListAction>?
}

enum TodoListAction: Equatable {
  case todos(id: TodoState.ID, action: TodoAction)
  case fetch
  case create
  case clearCompleted
  case createAlert
  case dismissAlert
  case didFetch(Result<[TodoState], AppError>)
  case didCreate(Result<Never, AppError>)
  case didClearCompleted(Result<Never, AppError>)
}

struct TodoListEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let todoListClient: TodoListClient
  let todoClient: TodoClient
}

let todoListReducer = Reducer<TodoListState, TodoListAction, TodoListEnvironment>.combine(
  todoReducer.forEach(
    state: \.todos,
    action: /TodoListAction.todos(id:action:),
    environment: { .init(mainQueue: $0.mainQueue, todoClient: $0.todoClient) }
  ),
  Reducer { state, action, environment in
    
    switch action {
      
    case .todos:
      return .none
      
    case .fetch:
      return environment.todoListClient.fetch()
        .receive(on: environment.mainQueue)
        .catchToEffect(TodoListAction.didFetch)
      
    case .create:
      return environment.todoListClient.create()
        .receive(on: environment.mainQueue)
        .catchToEffect(TodoListAction.didCreate)
      
    case .clearCompleted:
      return environment.todoListClient.remove(state.todos.filter(\.done))
        .receive(on: environment.mainQueue)
        .catchToEffect(TodoListAction.didClearCompleted)
      
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case .createAlert:
      state.alert = AlertState(
        title: TextState("Clear completed?"),
        primaryButton: .default(TextState("Okay"), action: .send(.clearCompleted)),
        secondaryButton: .cancel(TextState("Cancel"))
      )
      return .none
      
    case let .didFetch(.success(todos)):
      state.todos = IdentifiedArray(uniqueElements: todos)
      return .none
      
    case let .didFetch(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
      
    case let .didCreate(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
      
    case let .didClearCompleted(.failure(error)):
      state.alert = AlertState(title: TextState("\(error.localizedDescription)"))
      return .none
    }
  }
)

struct TodoListStore {
  static let `default` = Store(
    initialState: TodoListState(),
    reducer: todoListReducer,
    environment: TodoListEnvironment(
      mainQueue: .main,
      todoListClient: .live,
      todoClient: .live
    )
  )
}
