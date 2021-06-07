# 🔥 Firetodos

![banner](https://user-images.githubusercontent.com/45678211/119984333-48f24e80-bf8f-11eb-858f-32b666702f6a.png)


## About Firetodos

`Firetodos` is a Todo's app for macOS that implements Firebase authentication and the Cloud Firestore database.
It features Anonymous, Email, and Apple Sign In methods, as well as simplified and abstracted Firestore methods.

<img width="1039" alt="onboard" src="https://user-images.githubusercontent.com/45678211/121011965-3af9b600-c765-11eb-9797-cbd90dea2195.png">

<img width="1039" alt="done" src="https://user-images.githubusercontent.com/45678211/121011961-39c88900-c765-11eb-959f-c9e2a283f7f7.png">

<img width="1039" alt="todos" src="https://user-images.githubusercontent.com/45678211/121011959-392ff280-c765-11eb-96bc-7ed6a68201a5.png">

## TCA Effects & Firebase

The Effect type encapsulates a unit of work that can be run in the outside world, and can feed data back to the Store. It is the perfect place to do side effects, such as network requests, saving/loading from disk, creating timers, interacting with dependencies, and more.

### Implementation

Firetodos features custom Firebase methods which return `AnyPublisher<Result, Never>` types that get mapped to TCA Effects.

1. Actions are sent to the Reducer through the UI.
2. The Reducer switches over the action and returns method in the environment.
3. The environment executes a Firestore function which returns an AnyPublisher<Result, Never>.
4. The Publisher gets mapped to an action and erased to an Effect.
5. The Effect is returned by the environment and handled in the Reducer.

### Example

#### State

```swift
struct TodosList {
    struct State: Equatable {
        var todos: [Todo.State] = []
        var error: FirestoreError?
    }
    
    enum Action: Equatable {
        case createTodo
        case didCreateTodo(Result<Bool, FirestoreError>)
    }
    
    struct Environment {
        let db = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
                
        func createTodo(_ todo: Todo.State) -> Effect<Action, Never> {
            db.add(todo, to: "todos")
                .map(Action.didCreateTodo)
                .eraseToEffect()
        }
    }
}

extension TodosList {
    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer { state, action, environment in
            
            switch action {
                            
            case .createTodo:
                return environment.createTodo(Todo.State())
                                
            case .didCreateTodo(.success),
                return .none

            case let .didCreateTodo(.failure(error)),
                state.error = error
                return .none
            }
        }
    )
}
```

#### View

```swift
// View
struct TodosListView: View {
    let store: Store<TodosList.State, TodosList.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Button("Add") {
                 viewStore.send(.createTodo) 
            }
        }
    }
}
```





## Code



****
## Reset Defaults

Switch back to default icons at any time. Click "Select Modified", then "Reset".
