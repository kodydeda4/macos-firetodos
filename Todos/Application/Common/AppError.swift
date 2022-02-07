import Foundation

struct AppError: Error, Equatable {
  let rawValue: String
  
  init(_ error: Error) {
    self.rawValue = error.localizedDescription
  }
}
