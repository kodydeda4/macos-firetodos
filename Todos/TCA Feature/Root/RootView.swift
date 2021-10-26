//
//  RootView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct RootView: View {
  let store: Store<RootState, RootAction>
  
  var body: some View {
    SwitchStore(store) {
      CaseLet(state: /RootState.authentication, action: RootAction.authentication) {
        AuthenticationView(store: $0)
      }
      CaseLet(state: /RootState.user, action: RootAction.user) {
        UserView(store: $0)
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(store: RootState.defaultStore)
  }
}
