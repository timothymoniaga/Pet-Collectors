//
//  CoreDataController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var cardFetchedResultsController: NSFetchedResultsController<Card>?
    var persistentContainer: NSPersistentContainer
    var listeners = MulticastDelegate<DatabaseListener>()

    override init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
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
    

}
