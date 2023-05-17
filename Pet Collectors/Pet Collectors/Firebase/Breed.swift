//
//  Breed.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 13/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

class BreedFirebase: NSObject, Codable {

    @DocumentID var id: String?
    var breed: String?
    
}
