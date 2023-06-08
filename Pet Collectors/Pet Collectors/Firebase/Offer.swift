//
//  User.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import Firebase

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


