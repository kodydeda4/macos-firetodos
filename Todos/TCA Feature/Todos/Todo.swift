//
//  Todo.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Todo {
    struct State: Equatable, Identifiable, Codable {
        @DocumentID var id: String?
        @ServerTimestamp var createdAt: Date?
        var description: String = "Untitled"
        var completed: Bool = false
    }
    
    enum Action: Equatable {
        case toggleCompleted
        case updateText(String)
    }
}

extension Todo {
    static let reducer = Reducer<State, Action, Void> { state, action, _ in
        switch action {
                    
        case .toggleCompleted:
            state.completed.toggle()
            return .none
            
        case let .updateText(text):
            state.description = text
            return .none
        }
    }
}

extension Todo {
    static let defaultStore = Store(
        initialState: .init(),
        reducer: reducer,
        environment: ()
    )
}

// MARK:- TodoView

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

        }
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(store: Todo.defaultStore)
    }
}
