//
//  TodoView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct TodoView: View {
  let store: Store<TodoState, TodoAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        HStack {
          Button<Image>(viewStore.done ? .largecircleFillCircle : .circle) {
            viewStore.send(.toggleCompleted)
          }
          .buttonStyle(PlainButtonStyle())
          .foregroundColor(.appColor)
          
          TextField("Description", text: viewStore.binding(get: \.text, send: TodoAction.updateText))
            .opacity(viewStore.done ? 0.25 : 1)
          
//          Toggle("", isOn: viewStore.binding(\.$done))
          
//          TextField("Description", text: viewStore.binding(\.$text))
//            .opacity(viewStore.done ? 0.25 : 1)
          
          Button("delete") {
            viewStore.send(.deleteButonTapped)
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
    TodoView(store: TodoState.defaultStore)
  }
}
