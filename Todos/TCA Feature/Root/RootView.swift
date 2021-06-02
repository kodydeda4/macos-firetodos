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
            NavigationView {
                List {}
                TodosListView(
                    store: store.scope(
                        state: \.todosList,
                        action: Root.Action.todosList
                    )
                )
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

