//
//  TodoView.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture

struct TodoView: View {
    let store: Store<Todo.State, Todo.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Button<Image>(viewStore.completed ? .largecircleFillCircle : .circle) {
                        viewStore.send(.toggleCompleted)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                    
                    TextField("Description", text: viewStore.binding(get: \.description, send: Todo.Action.updateText))
                        .opacity(viewStore.completed ? 0.25 : 1)
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
        TodoView(store: Todo.defaultStore)
    }
}
