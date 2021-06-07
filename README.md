# 🔥 Firetodos

![banner](https://user-images.githubusercontent.com/45678211/121033999-aac66b80-c77a-11eb-85ac-21761193f177.png)

## About

`Firetodos` is a Todo's app for macOS that implements Firebase authentication and the Cloud Firestore database.
It features Anonymous, Email, and Apple Sign In methods, as well as simplified and abstracted Firestore methods that are mapped to TCA Effects.

<img width="1039" alt="onboard" src="https://user-images.githubusercontent.com/45678211/121011965-3af9b600-c765-11eb-9797-cbd90dea2195.png">

## TCA Effects & Firebase

The Effect type encapsulates a unit of work that can be run in the outside world, and can feed data back to the Store. It is the perfect place to do side effects, such as network requests, saving/loading from disk, creating timers, interacting with dependencies, and more.

### Implementation

Firetodos features custom Firebase methods which return `AnyPublisher<Result, Never>` types that get mapped to TCA Effects.

1. Actions are sent to the Reducer through the UI.
2. The Reducer switches over the action and returns method in the environment.
3. The environment executes a Firestore function which returns an AnyPublisher<Result, Never>.
4. The Publisher gets mapped to an action and erased to an Effect.
5. The Effect is returned by the environment and handled in the Reducer.

## 🔥 Firebase Authentication

<img width="1039" alt="done" src="https://user-images.githubusercontent.com/45678211/121011961-39c88900-c765-11eb-959f-c9e2a283f7f7.png">

### TCA Implementation

```swift
struct Authentication {
    struct State: Equatable {
        var signedIn = false
        var error: FirebaseError?
    }
    
    enum Action: Equatable {
        case signInWithAppleButtonTapped(id: ASAuthorizationAppleIDCredential, nonce: String)
        case signInResult(Result<Bool, FirebaseError>)
    }
    
    struct Environment {
        func signIn(
            _ appleID: ASAuthorizationAppleIDCredential,
            _ nonce: String
        ) -> Effect<Action, Never> {
            Firebase.signIn(using: appleID, and: nonce)
                .map(Action.signInResult)
                .eraseToEffect()
        }
    }
}

extension Authentication {
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        
        switch action {
            
        case let .signInWithAppleButtonTapped(appleID, nonce):
            return environment.signIn(appleID, nonce)
            
        case .signInResult(.success):
            state.signedIn.toggle()
            return .none
            
        case let .signInResult(.failure(error)):
            state.error = error
            return .none
        }
    }
}

struct AuthenticationView: View {
    let store: Store<Authentication.State, Authentication.Action>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            SignInWithAppleButton() {
                viewStore.send(.signInWithAppleButtonTapped(id: $0, nonce: $1))
            }
        }
    }
}
```

## 📝 Firestore CreateTodo

<img width="1039" alt="todos" src="https://user-images.githubusercontent.com/45678211/121011959-392ff280-c765-11eb-96bc-7ed6a68201a5.png">

### TCA Implementation

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

## Important

Firebase projects require a GoogleServiceInfo.plist file to run. You'll have to create your own project in Firebase console and then copy the generated file into your project in Xcode.
