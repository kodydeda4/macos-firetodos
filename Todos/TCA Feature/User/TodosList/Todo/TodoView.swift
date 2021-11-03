//
//  TodoView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import SFSafeSymbols

struct TodoView: View {
  let store: Store<TodoState, TodoAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        HStack {
          Toggle("", isOn: viewStore.binding(get: \.done, send: TodoAction.setDone))
          TextField("Description", text: viewStore.binding(get: \.text, send: TodoAction.setText))
            .opacity(viewStore.done ? 0.25 : 1)
          
          Button("delete") {
            viewStore.send(.delete)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
      }
      .padding(.bottom, 4)
    }
  }
}

struct TodoView_Previews: PreviewProvider {
  static var previews: some View {
    TodoView(store: .default)
  }
}
