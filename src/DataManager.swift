import Foundation
import CoreData

//DataManager class containing persistent container to save and access local storage
final class DataManager: ObservableObject {

    //Loading container with name DataModel
    let container = NSPersistentContainer(name: "DataModel")
    
    //Initializer tries to load local stores into container
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load persistent container: \(error.localizedDescription)")
            }
        }
    }
}