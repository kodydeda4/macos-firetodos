//
//  Firebase+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/4/21.
//

import SwiftUI
import Combine
import Firebase
import AuthenticationServices

/// Firebase Errors.
struct FirebaseError: Error, Equatable {
  static func == (lhs: FirebaseError, rhs: FirebaseError) -> Bool {
    lhs.error.localizedDescription == rhs.error.localizedDescription
  }
  
  var error: Error
  
  init(_ error: Error) {
    self.error = error
  }
}
