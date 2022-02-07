import Firebase
import ComposableArchitecture
import AuthenticationServices

struct AuthenticationState: Equatable {
  @BindableState var email = String()
  @BindableState var password = String()
  var error: AppError?
  var route: Route = .login
  var alert: AlertState<AuthenticationAction>? = nil
  
  enum Route {
    case login
    case signup
  }
}

enum AuthenticationAction: BindableAction, Equatable {
  case binding(BindingAction<AuthenticationState>)
  case updateRoute(AuthenticationState.Route)
  case createSignupAlert
  case dismissAlert
  case signInAnonymously
  case signInWithEmail
  case signInWithApple(SignInWithAppleToken)
  case signInResult(Result<Firebase.User, AppError>)
  case signUpWithEmail
  case signupResult(Result<Firebase.User, AppError>)
}

struct AuthenticationEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let authClient: AuthenticationClient
}

let authenticationReducer = Reducer<
  AuthenticationState,
  AuthenticationAction,
  AuthenticationEnvironment
> { state, action, environment in
  
  switch action {
    
  case .binding:
    return .none
    
  case .signInAnonymously:
    return environment.authClient.signInAnonymously()
      .receive(on: environment.mainQueue)
      .catchToEffect(AuthenticationAction.signInResult)
    
  case .signInWithEmail:
    return environment.authClient.signInEmailPassword(LoginCredential(state.email, state.password))
      .receive(on: environment.mainQueue)
      .catchToEffect(AuthenticationAction.signInResult)
    
  case let .signInWithApple(credential):
    return environment.authClient.signInApple(credential)
      .receive(on: environment.mainQueue)
      .catchToEffect(AuthenticationAction.signInResult)
    
  case .signInResult(.success):
    return .none
    
  case let .signInResult(.failure(error)):
    state.error = error
    return .none
    
  case let .signupResult(.success(user)):
    state.alert = AlertState(
      title: TextState("Success"),
      message: TextState("Welcome to FireTodos!"),
      primaryButton: .default(TextState("Okay"), action: .send(.dismissAlert)),
      secondaryButton: .cancel(TextState("Cancel"))
    )
    return .none
    
  case let .signupResult(.failure(error)):
    state.alert = AlertState(
      title: TextState("The email or password you provided cannot be used."),
      primaryButton: .default(TextState("Okay"), action: .send(.dismissAlert)),
      secondaryButton: .cancel(TextState("Cancel"))
    )
    return .none
    
  case .signUpWithEmail:
    return environment.authClient.signup(LoginCredential(state.email, state.password))
      .receive(on: environment.mainQueue)
      .catchToEffect(AuthenticationAction.signupResult)
    
  case let .updateRoute(route):
    state.route = route
    state.email = ""
    state.password = ""
    state.alert = nil
    return .none
    
  case .dismissAlert:
    state.alert = nil
    return .none
    
  case .createSignupAlert:
    state.alert = AlertState(
      title: TextState("Signup Alert"),
      primaryButton: .default(TextState("Okay"), action: .send(.dismissAlert)),
      secondaryButton: .cancel(TextState("Cancel"))
    )
    return .none
  }
}
.binding()
.debug()

struct AuthenticationStore {
  static let `default` = Store(
    initialState: AuthenticationState(),
    reducer: authenticationReducer,
    environment: AuthenticationEnvironment(
      mainQueue: .main,
      authClient: .live
    )
  )
}
