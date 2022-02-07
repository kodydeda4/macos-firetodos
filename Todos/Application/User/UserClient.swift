import Firebase
import ComposableArchitecture

struct UserClient {
  let signOut: () -> Effect<Never, Never>
}

extension UserClient {
  static let live = Self(
    signOut: {
      Effect.fireAndForget { try! Auth.auth().signOut() }
    }
  )
}
