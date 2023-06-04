//
//  User.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class User: NSObject{
    
    @DocumentID var id: String?
    var image: UIImage?
    var userName: String?
    var details: String?
    
    init(image: UIImage?, userName: String?, details: String?) {
        self.image = image
        self.userName = userName
        self.details = details
    }
}


