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

enum FirebaseError: Error, Equatable {
  case signInAnonymously
  case signInEmailPassword
  case signInApple
  case signout
}

