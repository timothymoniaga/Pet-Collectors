//
//  DatabaseProtocol.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import Foundation
import Firebase

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case card
    case user
    case timer
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onCardsChange(change: DatabaseChange, cards: [Card])
    func onTimerChange(change: DatabaseChange, timer: PackTimer)
}

protocol DatabaseProtocol: AnyObject {
    
    var breedList: [String] { get }
    var authController: Auth { get }
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addCardPersistentStorage(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String ) -> Card
    func addCardFirestore(card: Card)
    func addCardToTradeCollection(cardID: String, _ viewController: UIViewController)
    func addBreed(breedName: String) -> BreedFirebase
    func setDates(startDate: Date, endDate: Date)
    func removeTimers()
    func fetchTimer() -> [PackTimer]
    
    func login(email: String, password: String, completion: @escaping (String?) -> Void)
    func signup(email: String, password: String, completion: @escaping (String?) -> Void)
    func logout(completion: @escaping (Bool) -> Void)
    func copyUserCardsToPersistentStorage(userUID: String, completion: @escaping (Bool) -> Void)
    func createOfferDocument(with cardReference: DocumentReference, for tradeCardReference: String)
}

