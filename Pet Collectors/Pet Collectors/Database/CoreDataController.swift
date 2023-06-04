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
    var firestoreDatabase: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
    var breedRef: CollectionReference?
    var usersRef: CollectionReference?
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
        firestoreDatabase = Firestore.firestore()
        breedRef = firestoreDatabase.collection("breeds")
        
//        authController.signInAnonymously { authResult, error in
//            if let error = error {
//                // Handle the error
//                print("Anonymous sign-in failed: \(error.localizedDescription)")
//                return
//            }
//
//            // Anonymous sign-in successful
//            // You can access the anonymous user's information from `authResult.user`
//            guard let user = authResult?.user else {
//                print("Anonymous user not available")
//                return
//            }
//
//            // Use the anonymous user's information as needed
//            let uid = user.uid
//            print("Anonymous user ID: \(uid)")
//
//            // Proceed with further operations, such as writing to Firestore
//            // or accessing protected resources
//
//        }

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
    
//    func setupCardListener() {
//        usersRef = database.collection("users")
//        usersRef?.addSnapshotListener() { (querySnapshot, error) in
//            guard let querySnapshot = querySnapshot else {
//                print("Failed to fetch documents with error: \(String(describing: error))")
//                return
//            }
//            self.parseUsersSnapshot(snapshot: querySnapshot)
//            if self.usersRef == nil {
//                self.setupCardListener()
//            }
//        }
//    }
//
//    func parseUsersSnapshot(snapshot: QuerySnapshot) {
//        snapshot.documentChanges.forEach { (change) in
//            var user: User
//            do {
//                user = try change.document.data(as: User.self)
//            } catch {
//                fatalError("Unable to decode hero: \(error.localizedDescription)")
//            }
//            if change.type == .added {
//                heroList.insert(hero, at: Int(change.newIndex))
//            }
//            else if change.type == .modified {
//                heroList.remove(at: Int(change.oldIndex))
//                heroList.insert(hero, at: Int(change.newIndex))
//            }
//            else if change.type == .removed {
//                heroList.remove(at: Int(change.oldIndex))
//            }
//
//        }
//        listeners.invoke { (listener) in
//            if listener.listenerType == ListenerType.heroes ||
//                listener.listenerType == ListenerType.all {
//                listener.onAllHeroesChange(change: .update, heroes: heroList)
//            }
//        }
//
//    }
    
    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let authResult = try await authController.signIn(withEmail: email, password: password)
                completion(nil) // login successful, no error message
            } catch {
                print("User creation failed with error \(String(describing: error))")
                let errorDescription = (String(describing: error))
                if let startRange = errorDescription.range(of: "NSLocalizedDescription=") {
                    let startIndex = startRange.upperBound
                    if let endRange = errorDescription[startIndex...].range(of: ".") {
                        let endIndex = endRange.lowerBound
                        let result = String(errorDescription[startIndex..<endIndex])
                        completion(result) // login failed, pass error message
                    }
                }
            }
            //self.setupCardListener()

        }
    }
    
    func signup(email: String, password: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let authResult = try await authController.createUser(withEmail: email, password: password)
                let userUID = authResult.user.uid // Get the user's UID
                
                let userData: [String: Any] = [
                    "email": email, // Add any additional user data here
                    // ...
                ]
                
                // Reference to the "users" collection
                let usersRef = firestoreDatabase.collection("users")
                
                // Create a new document with the user's UID as the document ID
                let userDocRef = usersRef.document(userUID)
                userDocRef.setData(userData) { error in
                    if let error = error {
                        print("Error creating user document: \(error)")
                        completion("Failed to create user document.")
                    } else {
                        // Create an empty subcollection "cards" within the user's document
                        let cardsCollectionRef = userDocRef.collection("cards")
                        cardsCollectionRef.addDocument(data: [:]) { error in
                            if let error = error {
                                print("Error creating cards subcollection: \(error)")
                                completion("Failed to create cards subcollection.")
                            } else {
                                completion(nil) // Signup successful, no error message
                            }
                        }
                    }
                }
            } catch {
                print("User creation failed with error \(error)")
                let errorDescription = (String(describing: error))
                if let startRange = errorDescription.range(of: "NSLocalizedDescription=") {
                    let startIndex = startRange.upperBound
                    if let endRange = errorDescription[startIndex...].range(of: ".") {
                        let endIndex = endRange.lowerBound
                        let result = String(errorDescription[startIndex..<endIndex])
                        completion(result) // Signup failed, pass error message
                    }
                }
            }
        }
    }



    

}
