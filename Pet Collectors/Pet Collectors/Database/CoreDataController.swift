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
    var userUID: String?
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
        
        super.init()
        self.copyBreedsToArray()
        
    }
    
    // Function that was used when wikipidea api was in use. Now useless
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
                    self.breedList.append(breed)
                }
            }
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
    
    func addCardPersistentStorage(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String) -> Card {
        let card = NSEntityDescription.insertNewObject(forEntityName: "Card", into: persistentContainer.viewContext) as! Card
        card.breed = breed
        card.statistics = statistics
        card.cardRarity = rarity
        card.details = details
        card.imageURL = imageURL
        
        return card
    }
    
    func addCardFirestore(card: Card) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            // Handle the case when the user is not logged in
            return
        }
        
        let userDocRef = firestoreDatabase.collection("users").document(userUID)
        let rarityValue = Int(card.rarity) // Convert Int32 to Int
        
        let newCardRef = userDocRef.collection("cards").addDocument(data: [
            "breed": card.breed,
            "statistics": card.statistics,
            "rarity": rarityValue,
            "details": card.details,
            "imageURL": card.imageURL
        ]) { error in
            if let error = error {
                print("Error adding card to subcollection: \(error)")
            } else {
                print("Card added successfully")
            }
        }
        
        // Access the ID of the newly added card document
        let newCardID = newCardRef.documentID
        print("Newly added card ID: \(newCardID)")
        card.cardID = newCardID
    }
    
    func addCardToTradeCollection(cardID: String, _ viewController: UIViewController) {
        //let db = Firestore.firestore()
        if let userID = Auth.auth().currentUser?.uid {
            // Construct the card reference path
            let cardRefPath = "users/\(userID)/cards/\(cardID)"
            
            // Get the Firestore document reference for the card
            let cardRef = firestoreDatabase.document(cardRefPath)
            
            // Query the "trades" collection for documents with the same card reference
            firestoreDatabase.collection("trades").whereField("cardReference", isEqualTo: cardRef).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error querying trades collection: \(error)")
                    return
                }
                
                // Check if any matching documents were found
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    print("Card reference already exists in trades collection")
                    
                    UIUtil.displayMessageDimiss("Error", "Card has already been added", viewController)
                    return
                }
                
                // No repeat reference found, proceed to add the card to the trades collection
                let tradeDocument = self.firestoreDatabase.collection("trades").document()
                
                // Set the user and card reference fields in the trade document
                tradeDocument.setData([
                    "user": userID,
                    "cardReference": cardRef
                ]) { error in
                    if let error = error {
                        print("Error adding card to trade collection: \(error)")
                    } else {
                        print("Card added to trade collection successfully")
                    }
                }
            }
        } else {
            print("User ID not available")
        }
    }

    
    func createOfferDocument(with cardReference: DocumentReference, for tradeCardReference: String, viewController: UIViewController) {
        
        if let userID = Auth.auth().currentUser?.uid {
            // Construct the card reference path
            let cardRefPath = "users/\(userID)/cards/\(tradeCardReference)"
            let forCardRef = firestoreDatabase.document(cardRefPath)
            
            cardReference.getDocument { (document, error) in
                if let error = error {
                    print("Error fetching document: \(error)")
                    return
                }

                guard let document = document, document.exists else {
                    print("Document does not exist")
                    return
                }

                // Access the field values
                if let wantCardRef = document.get("cardReference") as? DocumentReference {
                    
                    let query = self.firestoreDatabase.collection("offers")
                        .whereField("tradeRef", isEqualTo: cardReference)
                        .whereField("card", isEqualTo: wantCardRef)
                        .whereField("for", isEqualTo: forCardRef)
                    
                    query.getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error querying documents: \(error)")
                            return
                        }
                        
                        if let snapshot = snapshot, !snapshot.isEmpty {
                            // A matching document already exists
                            print("Offer document already exists with the same field values.")
                            UIUtil.displayMessageDimiss("Error", "You have already made this offer", viewController)
                            
                            return
                        }
                        
                        let offerData: [String: Any] = [
                            "tradeRef": cardReference,
                            "card": wantCardRef,
                            "for": forCardRef
                        ]
                        
                        self.firestoreDatabase.collection("offers").addDocument(data: offerData) { error in
                            if let error = error {
                                print("Error creating offer document: \(error)")
                            } else {
                                print("Offer document created successfully.")
                            }
                        }
                    }
                }
            }
        }
    }

    // Removes all cards
    func removeAllCards() {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            let cards = try persistentContainer.viewContext.fetch(fetchRequest)
            
            for card in cards {
                persistentContainer.viewContext.delete(card)
            }
        } catch {
            print("Error removing cards: \(error)")
        }
    }

    
    
    // Function that was used when wikipidea api was in use. Now useless
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
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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
    
    func copyUserCardsToPersistentStorage(userUID: String, completion: @escaping (Bool) -> Void) {
        
        // Clear existing cards from persistent storage
        removeAllCards()
        
        let userDocRef = firestoreDatabase.collection("users").document(userUID)
        let cardsCollectionRef = userDocRef.collection("cards")
        
        cardsCollectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching user cards: \(error)")
                completion(false) // Copying user cards failed
            } else {
                // Process the fetched documents
                guard let documents = querySnapshot?.documents else {
                    completion(true) // No cards to copy
                    return
                }
                
                for document in documents {
                    // Extract card data from Firestore document
                    let cardID = document.documentID
                    let data = document.data()
                    let breed = data["breed"] as? String ?? ""
                    let statistics = data["statistics"] as? String ?? ""
                    let rarity = Rarity(rawValue: data["rarity"] as! Int32) as! Rarity
                    let details = data["details"] as? String ?? ""
                    let imageURL = data["imageURL"] as? String ?? ""
                    
                    // Create and store the card in persistent storage
                    let card = self.addCardPersistentStorage(breed: breed, statistics: statistics, rarity: rarity, details: details, imageURL: imageURL)
                    
                    // Store the card ID in the card object
                    card.cardID = cardID
                    
                }
                
                completion(true) // Copying user cards successful
            }
        }
    }


    
    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let authResult = try await authController.signIn(withEmail: email, password: password)
                
                // Clear existing cards from persistent storage
                removeAllCards()
                
                let userUID = authResult.user.uid
                let userDocRef = firestoreDatabase.collection("users").document(userUID)
                let cardsCollectionRef = userDocRef.collection("cards")
                
                // Fetch the user's cards from Firestore
                cardsCollectionRef.getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error fetching user cards: \(error)")
                        completion("Failed to fetch user cards.")
                    } else {
                        // Process the fetched documents
                        guard let documents = querySnapshot?.documents else {
                            completion(nil) // Login successful, no error message
                            return
                        }
                        
                        for document in documents {
                            // Extract card data from Firestore document
                            let data = document.data()
                            let breed = data["breed"] as? String ?? ""
                            let statistics = data["statistics"] as? String ?? ""
                            let rarity = Rarity(rawValue: data["rarity"] as! Int32) as! Rarity
                            let details = data["details"] as? String ?? ""
                            let imageURL = data["imageURL"] as? String ?? ""
                            
                            // Create and store the card in persistent storage
                            let card = self.addCardPersistentStorage(breed: breed, statistics: statistics, rarity: rarity, details: details, imageURL: imageURL)
                            // Process the card as needed
                        }
                        
                        completion(nil) // Login successful, no error message
                    }
                }
            } catch {
                print("User login failed with error \(error)")
                let errorDescription = (String(describing: error))
                if let startRange = errorDescription.range(of: "NSLocalizedDescription=") {
                    let startIndex = startRange.upperBound
                    if let endRange = errorDescription[startIndex...].range(of: ".") {
                        let endIndex = endRange.lowerBound
                        let result = String(errorDescription[startIndex..<endIndex])
                        completion(result) // Login failed, pass error message
                    }
                }
            }
        }
    }

    func signup(email: String, password: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let authResult = try await authController.createUser(withEmail: email, password: password)
                let userUID = authResult.user.uid // Get the user's UID
                
                self.userUID = userUID
                
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
                                self.removeDocumentsFromSubcollection(collectionRef: cardsCollectionRef)
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
    
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try authController.signOut()
            // Logout successful
            
            completion(true)
        } catch {
            print("Logout failed with error: \(error)")
            completion(false) // Logout failed
        }
        
    }

    
    func removeDocumentsFromSubcollection(collectionRef: CollectionReference) {
        collectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in the subcollection")
                return
            }
            
            for document in documents {
                document.reference.delete()
            }
            
            print("All documents removed from the subcollection")
        }
    }
    
    
    
}
