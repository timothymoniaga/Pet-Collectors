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
    
    //var startDateTime: Date?
    //var endDateTime: Date?
    var breedList: [String] = []
    var authController: Auth
    var database: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
    var breedRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var timerFetchedResultsController: NSFetchedResultsController<PackTimer>?
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
    
    func setDates(startDate: Date, endDate: Date) {
        let packTimer = NSEntityDescription.insertNewObject(forEntityName: "PackTimer", into: persistentContainer.viewContext) as! PackTimer
        packTimer.startDate = startDate
        packTimer.endDate = endDate
        
    }
    
    func removeTimers() {
        let fetchRequest: NSFetchRequest<PackTimer> = PackTimer.fetchRequest()
        
        do {
            let timers = try persistentContainer.viewContext.fetch(fetchRequest)
            
            for timer in timers {
                persistentContainer.viewContext.delete(timer)
            }
            
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to remove PackTimer objects: \(error)")
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
    
    func fetchTimer() -> [PackTimer] {
        if timerFetchedResultsController == nil {
            let request: NSFetchRequest<PackTimer> = PackTimer.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            timerFetchedResultsController = NSFetchedResultsController<PackTimer>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            timerFetchedResultsController?.delegate = self
            
            do {
                try timerFetchedResultsController?.performFetch()
            } catch {
                print("Timer fetch Request Failed: \(error)")
            }
        }
        if let timer = timerFetchedResultsController?.fetchedObjects {
            return timer
        }
        return [PackTimer]()
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
                print("Card fetch Request Failed: \(error)")
            }
        }
        if let card = cardFetchedResultsController?.fetchedObjects {
            return card
        }
        return [Card]()
    }
    

}
