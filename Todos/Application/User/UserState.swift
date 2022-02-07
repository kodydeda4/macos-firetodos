import Firebase
import ComposableArchitecture

struct UserState: Equatable {
  var user: User
  var isPremiumUser = false
  var todosList = TodoListState()
  var alert: AlertState<UserAction>?
}

enum UserAction: Equatable {
  case todosList(TodoListAction)
  case signout
  case createSignoutAlert
  case dismissAlert
  case buyPremiumButtonTapped
}

struct UserEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let userClient: UserClient
  let authClient: AuthenticationClient
  let todoListClient: TodoListClient
  let todoClient: TodoClient
}

let userReducer = Reducer<UserState, UserAction, UserEnvironment>.combine(
  todoListReducer.pullback(
    state: \.todosList,
    action: /UserAction.todosList,
    environment: { .init(mainQueue: $0.mainQueue, todoListClient: $0.todoListClient, todoClient: $0.todoClient) }
  ),
  Reducer { state, action, environment in
    
    switch action {
      
    case .todosList:
      return .none
      
    case .createSignoutAlert:
      state.alert = AlertState(
        title: TextState("Are you sure?"),
        primaryButton: .default(TextState("Confirm"), action: .send(.signout)),
        secondaryButton: .cancel(TextState("Cancel"))
      )
      return .none
      
    case .signout:
      return environment.userClient.signOut()
        .fireAndForget()
      
    case .dismissAlert:
      state.alert = nil
      return .none
      
    case .buyPremiumButtonTapped:
      return .none
    }
  }
).debug()

struct UserStore {
  static let `default` = Store(
    initialState: UserState(user: Auth.auth().currentUser!),
    reducer: userReducer,
    environment: UserEnvironment(
      mainQueue: .main,
      userClient: .live,
      authClient: .live,
      todoListClient: .live,
      todoClient: .live
    )
  )
}

