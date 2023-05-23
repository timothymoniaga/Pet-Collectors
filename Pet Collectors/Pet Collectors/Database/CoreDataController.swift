//
//  CoreDataController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import UIKit
import CoreData
import Firebase
import FirebaseFirestoreSwift

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var breedList: [String] = []
    var authController: Auth
    var database: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
    var breedRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var cardFetchedResultsController: NSFetchedResultsController<Card>?
    var persistentContainer: NSPersistentContainer
    //var listeners = MulticastDelegate<DatabaseListener>()

    override init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        breedRef = database.collection("breeds")
        
        authController.signInAnonymously { authResult, error in
            if let error = error {
                // Handle the error
                print("Anonymous sign-in failed: \(error.localizedDescription)")
                return
            }
            
            // Anonymous sign-in successful
            // You can access the anonymous user's information from `authResult.user`
            guard let user = authResult?.user else {
                print("Anonymous user not available")
                return
            }
            
            // Use the anonymous user's information as needed
            let uid = user.uid
            print("Anonymous user ID: \(uid)")
            
            // Proceed with further operations, such as writing to Firestore
            // or accessing protected resources

        }

        super.init()
        self.copyBreedsToArray()

    }
    
    private func copyBreedsToArray() {
        breedRef?.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            // Clear the existing breedList array
            self.breedList.removeAll()
            
            // Iterate over the documents in the breeds collection
            for document in querySnapshot!.documents {
                // Extract the breed field from each document
                if let breed = document.data()["breed"] as? String {
                    // Create a new Breed object and add it to the breedList array
//                    let newBreed = Breed()
//                    newBreed.name = breed
                    self.breedList.append(breed)
                }
            }
            
            // Notify listeners or perform any additional tasks
            // ...
        }
    }
    
    private func addBreed(name: String) -> Breed{
        let breed = NSEntityDescription.insertNewObject(forEntityName: "Breed", into: persistentContainer.viewContext) as! Breed
        breed.name = name
        return breed
    }
    
    func addCard(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String) -> Card {
        let card = NSEntityDescription.insertNewObject(forEntityName:
        "Card", into: persistentContainer.viewContext) as! Card
            card.breed = breed
            card.statistics = statistics
            card.cardRarity = rarity
            card.details = details
            card.imageURL = imageURL
        
        
        return card
    }
    
    
    func addBreed(breedName: String) -> BreedFirebase {
        let breed = BreedFirebase()
        breed.breed = breedName
        do {
            if let breedRef = try breedRef?.addDocument(from: breed) {
                breed.id = breedRef.documentID
            }
        } catch {
            print("Failed to serialize breed")
        }
        return breed
    }
    
    
    func controllerDidChangeContent(_ controller:
    NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == cardFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .card || listener.listenerType == .all {
                        listener.onCardsChange(change: .update, cards: fetchAllCards())
                }
            }
        }
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .card || listener.listenerType == .all {
            listener.onCardsChange(change: .update, cards: fetchAllCards())
        }
        
//        if listener.listenerType == .user || listener.listenerType == .all {
//            listener.onTeamChange(change: .update, teamHeroes: fetchTeamHeroes())
//        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllCards() -> [Card] {
        if cardFetchedResultsController == nil {
            let request: NSFetchRequest<Card> = Card.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "breed", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            cardFetchedResultsController =
            NSFetchedResultsController<Card>(fetchRequest: request,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
            cardFetchedResultsController?.delegate = self
            
            do {
                try cardFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let heroes = cardFetchedResultsController?.fetchedObjects {
            return heroes
        }
        return [Card]()
    }
    
//    private func breedListInit () {
//        breedRef?.getDocuments { (querySnapshot, error) in
//            if let error = error {
//                // Handle the error
//                print("Error retrieving documents: \(error.localizedDescription)")
//                return
//            }
//
//            // Iterate through the documents
//            for document in querySnapshot!.documents {
//                // Retrieve the "breed" attribute from each document
//                if let name = document.data()["breed"] as? String {
//                    // Add the breed to the array
//                    let breed = NSEntityDescription.insertNewObject(forEntityName: "Breed", into: self.persistentContainer.viewContext) as! Breed
//                    breed.name = name
//                    self.breedList.append(breed)
//                }
//            }
//
//            // The breedArray now contains the breeds from the collection
//            // print("Retrieved breeds: \(breedArray)")
//        }
//    }
    

}
