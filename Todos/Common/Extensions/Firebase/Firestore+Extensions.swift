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

/// MARK:- Manage Firestore Collections
extension Firestore {
  
  /// Fetch user-documents from collection.
  func fetchData<Document>(
    ofType: Document.Type,
    from collection: String,
    for userID: String
    
  ) -> AnyPublisher<Result<[Document], FirestoreError>, Never> where Document: Codable {
    
    let rv = PassthroughSubject<Result<[Document], FirestoreError>, Never>()
    
    self.collection(collection)
      .whereField("userID", isEqualTo: userID)
      .addSnapshotListener { querySnapshot, error in
        
        if let values = querySnapshot?
            .documents
            .compactMap({ try? $0.data(as: Document.self) }) {
          
          rv.send(.success(values))
          
        } else if let error = error {
          rv.send(.failure(FirestoreError(error)))
          print(error.localizedDescription)
        }
      }
    return rv.eraseToAnyPublisher()
  }
  
  /// Add document to collection.
  func add<Document>(
    _ document: Document,
    to collection: String
    
  ) -> AnyPublisher<Result<Bool, FirestoreError>, Never> where Document: Codable {
    
    let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
    
    do {
      let _ = try self.collection(collection).addDocument(from: document)
      rv.send(.success(true))
    }
    catch {
      rv.send(.failure(FirestoreError(error)))
    }
    
    return rv.eraseToAnyPublisher()
  }
  
  /// Remove document from collection.
  func remove(
    _ documentID: String,
    from collection: String
    
  ) -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
    
    let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
    
    self.collection(collection).document(documentID).delete { error in
      if let error = error {
        rv.send(.failure(FirestoreError(error)))
      } else {
        rv.send(.success(true))
      }
    }
    return rv.eraseToAnyPublisher()
  }
  
  /// Remove [document]'s from collection.
  func remove(
    _ documentIDs: [String],
    from collection: String
    
  ) -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
    
    let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
    
    documentIDs.forEach { id in
      self.collection(collection).document(id).delete { error in
        if let error = error {
          rv.send(.failure(FirestoreError(error)))
        } else {
          rv.send(.success(true))
        }
      }
    }
    
    return rv.eraseToAnyPublisher()
  }
  
  /// Set document to value.
  func set<Document>(
    _ documentID: String,
    to value: Document,
    in collection: String
    
  ) -> AnyPublisher<Result<Bool, FirestoreError>, Never> where Document: Codable {
    
    let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
    do {
      try self
        .collection(collection)
        .document(documentID)
        .setData(from: value)
      rv.send(.success(true))
    }
    catch {
      print(error)
      rv.send(.failure(FirestoreError(error)))
    }
    return rv.eraseToAnyPublisher()
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
