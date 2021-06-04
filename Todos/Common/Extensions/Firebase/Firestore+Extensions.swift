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

/// MARK:- Manage Collections
extension Firestore {

    /// Fetch user documents from Firestore collection.
    func fetchData<A>(ofType: A.Type, from collection: String, for userID: String) -> AnyPublisher<Result<[A], FirestoreError>, Never> where A: Codable {
        let rv = PassthroughSubject<Result<[A], FirestoreError>, Never>()
        
        self.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { querySnapshot, error in
            
            if let values = querySnapshot?
                .documents
                .compactMap({ try? $0.data(as: A.self) }) {
                
                rv.send(.success(values))
                
            } else if let error = error {
                rv.send(.failure(FirestoreError(error)))
                print(error.localizedDescription)
            }
        }
        return rv.eraseToAnyPublisher()
    }
    
    /// Add document to Firestore collection.
    func add<A>(_ value: A, to collection: String) -> AnyPublisher<Result<Bool, FirestoreError>, Never> where A: Codable {
        let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
        
        do {
            let _ = try self.collection(collection).addDocument(from: value)
            rv.send(.success(true))
        }
        catch {
            rv.send(.failure(FirestoreError(error)))
        }
        
        return rv.eraseToAnyPublisher()
    }
    
    /// Remove a document from a Firestore collection.
    func remove(_ documentID: String, from collection: String) -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
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
    
    /// Remove [document]'s from a Firestore collection.
    func remove(_ documentIDs: [String], from collection: String) -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
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
    
    /// Set the value of a Firestore document.
    func set<A>(_ documentID: String, to value: A, in collection: String) -> AnyPublisher<Result<Bool, FirestoreError>, Never> where A: Codable {
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
