//
//  OfferViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 3/5/2023.
//

import UIKit

class OfferViewController: UIViewController {

    var offerCard: TradeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = offerCard?.breed ?? "Offer"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
