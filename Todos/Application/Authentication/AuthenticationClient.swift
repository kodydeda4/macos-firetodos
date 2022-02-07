import Firebase
import Combine
import ComposableArchitecture

struct AuthenticationClient {
  let signup              :  (LoginCredential)      -> Effect<User, AppError>
  let signInEmailPassword :  (LoginCredential)      -> Effect<User, AppError>
  let signInApple         :  (SignInWithAppleToken) -> Effect<User, AppError>
  let signInAnonymously   :  ()                     -> Effect<User, AppError>
}

extension AuthenticationClient {
  static let live = Self(
    signup: { credential in
      Effect
        .task { try await Auth.auth().createUser(withEmail: credential.email, password: credential.password) }
        .map(\.user)
        .mapError(AppError.init)
        .eraseToEffect()
    },
    signInEmailPassword: { credential in
      Effect
        .task { try await Auth.auth().signIn(withEmail: credential.email, password: credential.password) }
        .map(\.user)
        .mapError(AppError.init)
        .eraseToEffect()
    },
    signInApple: { token in
      Effect.task { try await Auth.auth().signIn(with: OAuthProvider.credential(
        withProviderID: "apple.com",
        idToken: token.appleID,
        rawNonce: token.nonce
      )) }
      .map(\.user)
      .mapError(AppError.init)
      .eraseToEffect()
    },
    signInAnonymously: {
      Effect
        .task { try await Auth.auth().signInAnonymously() }
        .map(\.user)
        .mapError(AppError.init)
        .eraseToEffect()
    }
  )
}
