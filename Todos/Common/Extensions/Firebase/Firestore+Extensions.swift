//
//  Firebase+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import Combine
import Firebase

struct FirestoreError: Error, Equatable {
  static func == (lhs: FirestoreError, rhs: FirestoreError) -> Bool {
    lhs.error.localizedDescription == rhs.error.localizedDescription
  }
  
  var error: Error
  
  init(_ error: Error) {
    self.error = error
  }
  
}


/*------------------------------------------------------------------------------------------
 
 Extra Notes.
 
 SwiftUI: Fetching Data from Firestore in Real Time (April 2020)
 https://peterfriese.dev/swiftui-firebase-fetch-data/
 
 SwiftUI: Mapping Firestore Documents using Swift Codable (May 2020)
 https://peterfriese.dev/swiftui-firebase-codable/
 
 Mapping Firestore Data in Swift (March 2021)
 https://peterfriese.dev/firestore-codable-the-comprehensive-guide/
 
 ------------------------------------------------------------------------------------------*/
