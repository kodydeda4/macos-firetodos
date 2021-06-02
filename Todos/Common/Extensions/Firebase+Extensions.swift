//
//  Firebase+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import Firebase
import Combine

/*------------------------------------------------------------------------------------------
 
 SwiftUI: Fetching Data from Firestore in Real Time (April 2020)
 https://peterfriese.dev/swiftui-firebase-fetch-data/
 
 SwiftUI: Mapping Firestore Documents using Swift Codable (May 2020)
 https://peterfriese.dev/swiftui-firebase-codable/
 
 Mapping Firestore Data in Swift
 https://peterfriese.dev/firestore-codable-the-comprehensive-guide/
 
 ------------------------------------------------------------------------------------------*/


extension Firestore {

    func fetchData<A>(ofType: A.Type, from collection: String) -> AnyPublisher<Result<[A], FirestoreError>, Never> where A: Codable {
        let rv = PassthroughSubject<Result<[A], FirestoreError>, Never>()
        
        self.collection(collection).addSnapshotListener { querySnapshot, error in
            if let values = querySnapshot?
                .documents
                .compactMap({ try? $0.data(as: A.self) }) {
                
                rv.send(.success(values))
                
            } else if let error = error {
                rv.send(.failure(FirestoreError(error)))
            }
        }
        return rv.eraseToAnyPublisher()
    }
    
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
    
    static func signIn(_ email: String, _ password: String) -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
        let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                rv.send(.failure(FirestoreError(error)))
            } else {
                rv.send(.success(true))
            }
        }
        
        return rv.eraseToAnyPublisher()
    }
    
    static func signInAnonymously() -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
        let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
        
        Auth.auth().signInAnonymously { result, error in
            print(result.debugDescription)
            
            if let error = error {
                rv.send(.failure(FirestoreError(error)))
            } else {
                rv.send(.success(true))
            }
        }

        return rv.eraseToAnyPublisher()
    }
}



