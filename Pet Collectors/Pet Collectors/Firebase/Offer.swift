//
//  User.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

// Firebase Document for offers

class Offer: NSObject{
    
    @DocumentID var id: String?
    var card: DocumentReference
    var offeredCard: DocumentReference
    var tradeRef: DocumentReference
    
    init(card: DocumentReference, offeredCard: DocumentReference, tradeRef: DocumentReference) {
        self.card = card
        self.offeredCard = offeredCard
        self.tradeRef = tradeRef
    }
}


