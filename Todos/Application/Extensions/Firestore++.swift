import CoreMedia
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import ComposableArchitecture

extension Query {
  func snapshotPublisher(includeMetadataChanges: Bool = false) -> AnyPublisher<QuerySnapshot, Error> {
    let publisher = PassthroughSubject<QuerySnapshot, Error>()
    
    let snapshotListener = addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
      if let error = error {
        publisher.send(completion: .failure(error))
      } else if let snapshot = snapshot {
        publisher.send(snapshot)
      } else {
        fatalError()
      }
    }
    return publisher
      .handleEvents(receiveCancel: snapshotListener.remove)
      .eraseToAnyPublisher()
  }
}
