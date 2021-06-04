//
//  Firebase+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import Firebase
import Combine
import AuthenticationServices
import SwiftUI

/*------------------------------------------------------------------------------------------
 
 SwiftUI: Fetching Data from Firestore in Real Time (April 2020)
 https://peterfriese.dev/swiftui-firebase-fetch-data/
 
 SwiftUI: Mapping Firestore Documents using Swift Codable (May 2020)
 https://peterfriese.dev/swiftui-firebase-codable/
 
 Mapping Firestore Data in Swift (March 2021)
 https://peterfriese.dev/firestore-codable-the-comprehensive-guide/
 
 ------------------------------------------------------------------------------------------*/

struct FirestoreError: Error, Equatable {
    static func == (lhs: FirestoreError, rhs: FirestoreError) -> Bool {
        lhs.error.localizedDescription == rhs.error.localizedDescription
    }
    
    var error: Error
    
    init(_ error: Error) {
        self.error = error
    }

}

/// MARK:- Collections
extension Firestore {

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
}

/// MARK:- SignIn Methods
extension Firestore {
    
    /// Sign into Firebase using an email & password.
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
    
    /// Sign into Firebase anonymously.
    static func signIn() -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
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
    
    
    /// Sign into Firebase using an AppleIDCredential.
    static func signIn(
        using appleIDCredental: ASAuthorizationAppleIDCredential
    ) -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
        
        let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
        
        guard let appleIDToken = appleIDCredental.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8)
        
        else { fatalError("FatalError: Apple authenticatication failed.") }
        
        Auth.auth().signIn(
            with: OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: SignInWithAppleButton.currentNonce
                
            )) { authResult, error in
            
            switch error {
            
            case .none:
                rv.send(.success(true))
                
            case let .some(error):
                rv.send(.failure(FirestoreError(error)))
            }
        }
        
        return rv.eraseToAnyPublisher()
    }
    
    /// Sign out of Firebase.
    static func signOut() -> AnyPublisher<Result<Bool, FirestoreError>, Never> {
        let rv = PassthroughSubject<Result<Bool, FirestoreError>, Never>()
        
        do {
            try Auth.auth().signOut()
            rv.send(.success(true))
        } catch {
            rv.send(.failure(FirestoreError(error)))
        }
            
        return rv.eraseToAnyPublisher()
    }
}



