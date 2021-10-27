//
//  TodosApp.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import ComposableArchitecture
import Firebase

@main
struct TodosApp: App {
  init() {
    FirebaseApp.configure()
  }
  var body: some Scene {
    WindowGroup {
      RootView(store: RootState.defaultStore)
    }
//    .windowStyle(HiddenTitleBarWindowStyle())
  }
}


struct ContentView: View {
  var body: some View {
    Form {
      Text("Hello world")
    }
    .frame(width: 300, height: 300)
  }
}
