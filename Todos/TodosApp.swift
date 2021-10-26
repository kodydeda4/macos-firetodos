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
      RootView(store: Root.defaultStore)
    }
    .windowStyle(HiddenTitleBarWindowStyle())
  }
}

