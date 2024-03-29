//
//  RootView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: Store<Root.State, Root.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            if viewStore.authentication.signedIn {
                TodosListView(store: store.scope(state: \.todosList, action: Root.Action.todosList))
                    .navigationTitle("")

            } else {
                AuthenticationView(store: store.scope(state: \.authentication, action: Root.Action.authentication))
            }
        }
    }
}

// MARK:- SwiftUI_Previews
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: Root.defaultStore)
    }
}



