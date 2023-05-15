//
//  FirebaseController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 13/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject {
    
    //var cardFetchedResultsController: NSFetchedResultsController<Card>?
    //var persistentContainer: NSPersistentContainer
    var breedList: [Breed]
    var authController: Auth
    var database: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
    var breedRef: CollectionReference?
    var currentUser: FirebaseAuth.User?

    
    override init() {
            FirebaseApp.configure()
            authController = Auth.auth()
            database = Firestore.firestore()
            breedList = [Breed]()
            //defaultTeam = Team()
            super.init()
        }

    
    func cleanup() {
    }
    
    func addListener(listener: DatabaseListener) {
//        listeners.addDelegate(listener)
//        if listener.listenerType == .card || listener.listenerType == .all {
//            listener.onCardsChange(change: .update, cards: fetchAllCards())
//        }
    }
    
    func removeListener(listener: DatabaseListener) {
        
    }
    
//    func addCard(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String) -> Card {
//
//    }
    

}
