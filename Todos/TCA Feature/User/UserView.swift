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
      NavigationView {
        List {
          NavigationLink(
            destination: {
              TodoListView(store: store.scope(
                state: \.todosList,
                action: UserAction.todosList
              ))
            },
            label: {
              Label("Todos", systemSymbol: .checkmarkSquareFill)
            }
          )
          NavigationLink(
            destination: {
              ProfileView(store: store)
            },
            label: {
              Label("Profile", systemSymbol: .personCircleFill)
            }
          )
        }
        .listStyle(SidebarListStyle())
        TodoListView(store: store.scope(
          state: \.todosList,
          action: UserAction.todosList
        ))
      }
    }
  }
}

struct UserView_Previews: PreviewProvider {
  static var previews: some View {
    UserView(store: .default)
  }
}

