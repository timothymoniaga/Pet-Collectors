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
    var firestoreDatabase: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
    var breedRef: CollectionReference?
    var usersRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var timerFetchedResultsController: NSFetchedResultsController<PackTimer>?
    var cardFetchedResultsController: NSFetchedResultsController<Card>?
    var persistentContainer: NSPersistentContainer
    var userUID: String?
    
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
    
    /**
     Sets the start and end dates for a pack timer.

     This method is used to set the start and end dates for a pack timer. It creates a new `PackTimer` object and assigns the provided start and end dates to its `startDate` and `endDate` properties, respectively.

     - Parameters:
        - startDate: The start date of the pack timer.
        - endDate: The end date of the pack timer.

     - Note: The `PackTimer` object is created and persisted using the Core Data context associated with the `persistentContainer`.
    */
    func setDates(startDate: Date, endDate: Date) {
        let packTimer = NSEntityDescription.insertNewObject(forEntityName: "PackTimer", into: persistentContainer.viewContext) as! PackTimer
        packTimer.startDate = startDate
        packTimer.endDate = endDate
        
    }
    
    /**
     Removes all pack timers from persistent storage.

     This method deletes all `PackTimer` objects from the persistent storage. It creates a fetch request to retrieve all `PackTimer` objects and then deletes each timer using the Core Data context. Finally, it saves the context to persist the changes.

     - Note: This method should be called when you want to remove all pack timers from the persistent storage.
     */
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
    
    
    /**
     Adds a new card to the persistent storage.

     This method is used to add a new card to the persistent storage. It creates a new `Card` object and sets the provided values for its `breed`, `statistics`, `cardRarity`, `details`, and `imageURL` properties. The created card object is then returned.

     - Parameters:
        - breed: The breed of the card.
        - statistics: The statistics of the card.
        - rarity: The rarity of the card.
        - details: The details of the card.
        - imageURL: The URL of the card's image.

     - Returns: The created `Card` object.

     - Note: The `Card` object is created and persisted using the Core Data context associated with the `persistentContainer`.
     */
    func addCardPersistentStorage(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String) -> Card {
        let card = NSEntityDescription.insertNewObject(forEntityName: "Card", into: persistentContainer.viewContext) as! Card
        card.breed = breed
        card.statistics = statistics
        card.cardRarity = rarity
        card.details = details
        card.imageURL = imageURL
        
        return card
    }
    
    
    /**
     Adds a card to the Firestore database under the user's collection.

     This method is used to add a card to the Firestore database. It requires a valid authenticated user to associate the card with the user's collection. The card's properties such as breed, statistics, rarity, details, and imageURL are stored in the Firestore document under the user's collection. The method prints an error message if adding the card fails.

     - Parameters:
        - card: The card object to be added to the Firestore database.

     - Note: The card's `cardID` property is updated with the ID of the newly added card document in Firestore.
     */
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
    
    
    /**
     Adds a card to the trades collection in the Firestore database.

     This method is used to add a card to the trades collection in the Firestore database. It checks if the card has already been added to the trades collection by querying for documents with the same card reference. If no matching documents are found, the card is added to the trades collection under a new trade document. If a matching document exists, an error message is displayed.

     - Parameters:
        - cardID: The ID of the card to be added to the trades collection.
        - viewController: The view controller to display an error message if the card has already been added.

     - Note: The card reference consists of the user ID and the card ID in the format "users/{userID}/cards/{cardID}".
     */
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

    /**
     Creates an offer document in the Firestore database.

     This method is used to create an offer document in the Firestore database. It checks if an offer document already exists with the same field values (tradeRef, card, and for), and displays an error message if a matching document is found. If no matching document is found, a new offer document is created with the provided field values.

     - Parameters:
        - cardReference: The document reference of the card involved in the trade.
        - tradeCardReference: The ID of the trade card.
        - viewController: The view controller to display an error message if a matching offer document already exists.

     - Note: The offer document is created in the "offers" collection in Firestore.
     */
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
    
    /**
     Listens for offers in the Firestore database.

     This method sets up a listener to listen for changes in the "offers" collection in the Firestore database. It retrieves the offers that belong to the currently authenticated user and returns them through the completion handler. If an error occurs while listening for offers, the error is returned through the completion handler.

     - Parameters:
        - completion: A closure that is called when the offers are retrieved or an error occurs. The closure receives an optional array of offers and an optional error as parameters.

     - Note: The offers are filtered based on the current user ID.
     */
    func listenForOffers(completion: @escaping ([Offer]?, Error?) -> Void) {
        let collectionRef = firestoreDatabase.collection("offers")
        
        if let userID = Auth.auth().currentUser?.uid {

        // Listen for realtime updates
            collectionRef.addSnapshotListener { (snapshot, error) in
                if let error = error {
                    // Error occurred
                    completion(nil, error)
                    return
                }
                
                var offers: [Offer] = []
                
                for document in snapshot!.documents {
                    let documentData = document.data()
                    
                    if let cardRef = documentData["card"] as? DocumentReference,
                       let offeredCardRef = documentData["for"] as? DocumentReference,
                       let tradeRef = documentData["tradeRef"] as? DocumentReference {
                        
                        print(cardRef.path)
                        print(userID)
                        
                        if(cardRef.path.contains(userID ?? "")) {
                            let offer = Offer(card: cardRef, offeredCard: offeredCardRef, tradeRef: tradeRef)
                            offer.id = document.documentID
                            offers.append(offer)
                        }
                    }
                }
                
                
                completion(offers, nil)
            }
        }
    }

    /**
     Converts a Firestore document to a TradeCard object.

     This method retrieves a document from Firestore using the provided document reference and converts it into a TradeCard object. It extracts the necessary data fields from the document and creates a TradeCard instance with the extracted data. If the document doesn't exist or the data format is invalid, it returns `nil` through the completion handler.

     - Parameters:
        - documentReference: The Firestore document reference to convert to a TradeCard.
        - completion: A closure that is called when the conversion is completed or an error occurs. The closure receives an optional TradeCard object and an optional error as parameters.

     - Note: The TradeCard object is created using the extracted data fields from the Firestore document.
     */
    func convertToTradeCard(from documentReference: DocumentReference, completion: @escaping (TradeCard?, Error?) -> Void) {
        documentReference.getDocument { (document, error) in
            if let error = error {
                // Handle the error
                completion(nil, error)
                return
            }

            guard let document = document, document.exists else {
                // Document doesn't exist
                completion(nil, nil)
                return
            }

            // Extract the data from the document
            guard let data = document.data(),
                  let breed = data["breed"] as? String,
                  let statistics = data["statistics"] as? String,
                  let rarityRawValue = data["rarity"] as? Int32,
                  let rarity = Rarity(rawValue: rarityRawValue),
                  let details = data["details"] as? String,
                  let imageURL = data["imageURL"] as? String
            else {
                // Invalid data format
                completion(nil, nil)
                return
            }

            // Create the TradeCard object
            let tradeCard = TradeCard(breed: breed, statistics: statistics, rarity: rarity, details: details, imageURL: imageURL, cardReference: documentReference)

            // Pass the TradeCard object to the completion handler
            completion(tradeCard, nil)
        }
    }


    /**
     Removes all cards from the persistent storage.

     This method deletes all Card entities from the persistent storage using Core Data. It fetches all the existing Card entities and iterates over them to delete each entity. Any errors encountered during the deletion process are logged to the console.
     */
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
    
    
    /**
     Completes an offer and performs a trade.

     This method completes an offer by swapping the card documents between the users involved in the trade. It takes an Offer object as input, which contains references to the card documents and the trade document. It retrieves the card documents using the provided references, swaps their necessary fields, and updates the card documents in Firestore. Then, it deletes the offer document and the trade document from Firestore. If any error occurs during the process, the completion closure is called with the corresponding error. Otherwise, completion is called with a `nil` error, indicating a successful trade completion.

     - Parameters:
        - offer: The Offer object representing the trade offer to be completed.
        - completion: A closure that is called when the offer completion and trade process is finished or an error occurs. The closure receives an optional error as a parameter.
     */
    func completeOfferAndPerformTrade(_ offer: Offer, completion: @escaping (Error?) -> Void) {
        let cardRef1 = offer.card // card that the other user offered
        let cardRef2 = offer.offeredCard //card that the current user offered
        let tradeRef = offer.tradeRef
        
        // Retrieve the card documents using the provided card references
        cardRef1.getDocument { (snapshot1, error) in
            if let error = error {
                completion(error)
                return
            }
            
            cardRef2.getDocument { (snapshot2, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Swap the card documents
                if let cardDocument1 = snapshot1, let cardDocument2 = snapshot2 {
                    // Update the document fields for each card document to swap their locations
                    let cardData1 = cardDocument1.data()
                    let cardData2 = cardDocument2.data()
                    
                    // Swap the necessary fields or update as per your requirements
                    // For example, you can swap the "users" field or any other relevant fields
                    let updatedCardData1: [String: Any] = [
                        "breed": cardData2?["breed"],
                        "details": cardData2?["details"],
                        "imageURL": cardData2?["imageURL"],
                        "rarity": cardData2?["rarity"],
                        "statistics": cardData2?["statistics"]
                    ]
                    
                    let updatedCardData2: [String: Any] = [
                        "breed": cardData1?["breed"],
                        "details": cardData1?["details"],
                        "imageURL": cardData1?["imageURL"],
                        "rarity": cardData1?["rarity"],
                        "statistics": cardData1?["statistics"]
                    ]
                    
                    // Save the updated card documents back to Firestore
                    cardRef1.updateData(updatedCardData1) { (error) in
                        if let error = error {
                            completion(error)
                            return
                        }
                        
                        cardRef2.updateData(updatedCardData2) { (error) in
                            if let error = error {
                                completion(error)
                                return
                            }
                            
                            // Delete the offer document
                            self.firestoreDatabase.collection("offers").document(offer.id!).delete { (error) in
                                if let error = error {
                                    completion(error)
                                    return
                                }
                                
                                // Delete the trade document
                                tradeRef.delete { (error) in
                                    if let error = error {
                                        completion(error)
                                    } else {
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    /**
     Deletes an offer document from Firestore.

     This function deletes the offer document associated with the provided Offer object from the Firestore database. It takes an Offer object as input and uses its `id` property to identify and delete the corresponding offer document. If the deletion is successful, the completion closure is not called. Otherwise, if an error occurs during the deletion process, the completion closure is called with the corresponding error.

     - Parameter offer: The Offer object representing the offer document to be deleted.
     */
    func deleteOfferDocument(offer: Offer) {
        firestoreDatabase.collection("offers").document(offer.id!).delete { error in
            if let error = error {
                print("Error deleting offer document: \(error)")
            } else {
                print("Offer document deleted successfully.")
            }
        }
    }

    
    /**
     Adds a breed to Firestore.

     This function adds a breed to Firestore using the provided breed name. It creates a new `BreedFirebase` object, sets its breed property to the provided breed name, and attempts to add the breed document to Firestore. If the breed document is successfully added, the `id` property of the `BreedFirebase` object is set to the generated document ID. If an error occurs during the serialization or addition process, an error message is printed.

     - Parameter breedName: The name of the breed to be added.

     - Returns: The `BreedFirebase` object representing the added breed.
     
     - Note: This function is no longer used since the Wikipedia API is no longer in use.
     */
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
    
    /**
     Notifies listeners about changes in the fetched results controller.

     This function is called when changes occur in the `NSFetchedResultsController` for the `Card` entity. It notifies the registered listeners by invoking their respective callback methods. If a listener's `listenerType` is `.card` or `.all`, the `onCardsChange` method is called with the `.update` change type and the fetched cards.

     - Parameter controller: The `NSFetchedResultsController` that triggered the change event.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == cardFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .card || listener.listenerType == .all {
                    listener.onCardsChange(change: .update, cards: fetchAllCards())
                }
            }
        }
    }
    
    /**
     Saves changes to Core Data and performs cleanup.

     This function saves any pending changes in the `persistentContainer.viewContext` and performs cleanup tasks. If there are changes in the view context, the changes are saved. If saving fails, a fatal error is triggered with the corresponding error message.
     */
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    /**
     Adds a database listener.

     This function adds a new listener to the `listeners` set. It adds the provided `DatabaseListener` object as a delegate to the `listeners` set. If the listener's `listenerType` is `.card` or `.all`, it immediately calls the `onCardsChange` method of the listener with the `.update` change type and all the fetched cards.
     
     - Parameter listener: The `DatabaseListener` object to be added as a listener.
     */
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .card || listener.listenerType == .all {
            listener.onCardsChange(change: .update, cards: fetchAllCards())
        }
    }
    
    /**
     Removes a database listener.

     This function removes a listener from the `listeners` set. It removes the provided `DatabaseListener` object as a delegate from the `listeners` set.

     - Parameter listener: The `DatabaseListener` object to be removed as a listener.
     */
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    /**
     Fetches pack timers from Core Data.

     This function retrieves the pack timers stored in Core Data. If the `timerFetchedResultsController` is `nil`, it creates a new `NSFetchedResultsController` and performs the fetch request. The pack timers are sorted in ascending order based on their start dates. If the fetch request fails, an error message is printed.

     - Returns: An array of `PackTimer` objects representing the fetched pack timers. If no pack timers are found, an empty array is returned.
     */
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
    
    
    /**
     Fetches all cards from Core Data.

     This function retrieves all the cards stored in Core Data. If the `cardFetchedResultsController` is `nil`, it creates a new `NSFetchedResultsController` and performs the fetch request. The cards are sorted in ascending order based on their breed names. If the fetch request fails, an error message is printed.

     - Returns: An array of `Card` objects representing the fetched cards. If no cards are found, an empty array is returned.
     */
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
    
    
    /**
     Copies user cards from Firestore to persistent storage.

     This function retrieves the cards associated with a user from Firestore and copies them to the persistent storage using Core Data. It first removes any existing cards from the persistent storage by calling the `removeAllCards()` function. Then, it fetches the user's card documents from Firestore and processes them.

     If an error occurs while fetching the user's cards or processing the documents, the function prints an error message and calls the completion handler with a `false` value. If there are no cards to copy, the completion handler is called with a `true` value. If the cards are successfully copied to the persistent storage, the completion handler is called with a `true` value.

     - Parameters:
        - userUID: The UID of the user whose cards will be copied.
        - completion: A closure to be called when the operation is completed. It receives a boolean value indicating whether the copying process was successful (`true`) or not (`false`).

     */
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


    /**
     Authenticates a user and retrieves their cards upon successful login.

     This function attempts to log in the user with the provided email and password using the `authController.signIn(withEmail:password:)` method. Upon successful authentication, the user's existing cards in persistent storage are cleared by calling the `removeAllCards()` function. Then, the function fetches the user's cards from Firestore and processes them.

     If an error occurs during the login process, the function prints an error message and calls the completion handler with an optional error message string. If the login is successful and the user's cards are fetched successfully, the completion handler is called with a `nil` value to indicate successful login without any error message.

     - Parameters:
        - email: The email address of the user.
        - password: The password for the user's account.
        - completion: A closure to be called when the login operation is completed. It receives an optional string parameter, which is an error message in case of login failure, or `nil` if the login is successful without any error.

     */
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

    
    /**
     Registers a new user and initializes their data upon successful signup.

     This function creates a new user account using the provided email and password by calling the `authController.createUser(withEmail:password:)` method. Upon successful account creation, the user's existing cards in persistent storage are cleared by calling the `removeAllCards()` function. The function then proceeds to create a new user document in Firestore's "users" collection, with the user's UID as the document ID. Additional user data can be added to the `userData` dictionary before saving it to the document.

     Subsequently, the function creates an empty subcollection named "cards" within the user's document to store their cards. An empty document is initially added to the "cards" subcollection to facilitate future operations. The function then removes any existing documents from the "cards" subcollection using the `removeDocumentsFromSubcollection(collectionRef:)` method.

     If an error occurs during the signup process, the function prints an error message and calls the completion handler with an optional error message string. If the signup is successful and the user's data is initialized successfully, the completion handler is called with a `nil` value to indicate successful signup without any error message.

     - Parameters:
        - email: The email address for the new user's account.
        - password: The password for the new user's account.
        - completion: A closure to be called when the signup operation is completed. It receives an optional string parameter, which is an error message in case of signup failure, or `nil` if the signup is successful without any error.

     */
    func signup(email: String, password: String, completion: @escaping (String?) -> Void) {
        removeAllCards()
        
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
    
    /**
     Logs out the current user.

     This function signs out the currently authenticated user by calling the `authController.signOut()` method. If the logout operation is successful, the completion handler is called with a value of `true`. If an error occurs during the logout process, the function prints an error message and calls the completion handler with a value of `false`.

     - Parameter completion: A closure to be called when the logout operation is completed. It receives a boolean parameter that indicates whether the logout was successful (`true`) or failed (`false`).
     */
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

    
    /**
     Removes all documents from a Firestore subcollection.

     This function retrieves all documents from the provided `collectionRef` and deletes each document using the `delete()` method of its reference. If any error occurs during the retrieval or deletion process, an error message is printed. If the retrieval is successful but no documents are found in the subcollection, a corresponding message is printed.

     - Parameter collectionRef: A reference to the Firestore subcollection from which the documents should be removed.
     */
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
