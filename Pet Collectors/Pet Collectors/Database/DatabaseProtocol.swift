//
//  DatabaseProtocol.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import Foundation


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
    //func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero])
    //func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero])
    //func onTeamsChange(change: DatabaseChange, teams: [Team])
}

protocol DatabaseProtocol: AnyObject {
    
    var breedList: [String] { get }
    //var startDateTime: Date? { get set }
    //var endDateTime: Date? { get set }

    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addCard(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String )
    -> Card
    func addBreed(breedName: String) -> BreedFirebase
    func setDates(startDate: Date, endDate: Date)
    func removeTimers()
    func fetchTimer() -> [PackTimer]
    
}

