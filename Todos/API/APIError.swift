//
//  APIError.swift
//  Todos
//
//  Created by Kody Deda on 10/31/21.
//

import Foundation

enum APIError: Error, Equatable {
  case firebase(String?)
}
