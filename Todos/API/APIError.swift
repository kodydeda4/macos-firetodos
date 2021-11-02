//
//  APIError.swift
//  Todos
//
//  Created by Kody Deda on 10/31/21.
//

import Foundation

struct APIError: Error, Equatable {
  let rawValue: String
  
  init(_ error: Error?) {
    self.rawValue = error?.localizedDescription ?? "Unknown"
  }
  
  init(rawValue: String) {
    self.rawValue = rawValue
  }
}
