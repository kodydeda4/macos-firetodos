import SwiftUI
import Firebase
import ComposableArchitecture

@main
struct TodosApp: App {
  init() {
    FirebaseApp.configure()
  }
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}
