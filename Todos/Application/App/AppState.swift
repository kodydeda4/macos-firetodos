import Firebase
import ComposableArchitecture

enum AppState: Equatable {
  case authentication(AuthenticationState)
  case user(UserState)
}

enum AppAction: Equatable {
  case authentication(AuthenticationAction)
  case user(UserAction)
}

struct AppEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let authClient: AuthenticationClient
  let userClient: UserClient
  let todoListClient: TodoListClient
  let todoClient: TodoClient
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  authenticationReducer.pullback(
    state: /AppState.authentication,
    action: /AppAction.authentication,
    environment: { .init(mainQueue: $0.mainQueue, authClient: $0.authClient) }
  ),
  userReducer.pullback(
    state: /AppState.user,
    action: /AppAction.user,
    environment: { .init(mainQueue: $0.mainQueue, userClient: $0.userClient, authClient: $0.authClient, todoListClient: $0.todoListClient, todoClient: $0.todoClient) }
  ),
  Reducer { state, action, environment in
    switch action {
      
    case let .authentication(.signInResult(.success(user))):
      state = .user(.init(user: user))
      return .none
      
    case .user(.signout):
      state = .authentication(.init())
      return .none
      
    case .authentication, .user:
      return .none
    }
  }
).debug()

struct AppStore {
  static let `default` = Store(
    initialState: .authentication(
      AuthenticationState.init(
        email: "test@email.com",
        password: "123123"
      )),
    reducer: appReducer,
    environment: AppEnvironment(
      mainQueue: .main,
      authClient: .live,
      userClient: .live,
      todoListClient: .live,
      todoClient: .live
    )
  )
}
