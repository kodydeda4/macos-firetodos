import Foundation

struct LoginCredential {
  let email: String
  let password: String
  
  init(_ email: String, _ password: String) {
    self.email = email
    self.password = password
  }
}


