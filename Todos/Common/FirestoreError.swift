//
//  FirestoreError.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import Foundation

struct FirestoreError: Error, Equatable {
    static func == (lhs: FirestoreError, rhs: FirestoreError) -> Bool {
        lhs.error.localizedDescription == rhs.error.localizedDescription
    }
    
    var error: Error
    
    init(_ error: Error) {
        self.error = error
    }
}
