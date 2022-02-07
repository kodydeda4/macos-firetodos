import SwiftUI
import ComposableArchitecture

struct AppView: View {
  var store: Store<AppState, AppAction> = AppStore.default
  
  var body: some View {
    SwitchStore(store) {
      CaseLet(
        state: /AppState.authentication,
        action: AppAction.authentication,
        then: AuthenticationView.init(store:)
      )
      CaseLet(
        state: /AppState.user,
        action: AppAction.user,
        then: UserView.init(store:)
      )
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: AppStore.default)
  }
}
