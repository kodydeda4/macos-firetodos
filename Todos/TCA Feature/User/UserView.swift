//
//  UserView.swift
//  Todos
//
//  Created by Kody Deda on 10/26/21.
//

import SwiftUI
import ComposableArchitecture

struct UserView: View {
  let store: Store<UserState, UserAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TodoListView(store: store.scope(
        state: \.todosList,
        action: UserAction.todosList
      ))
//        .toolbar {
//          Button("Sign Out") {
//            viewStore.send(.signOut)
//          }
//        }
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    UserView(store: .default)
  }
}
