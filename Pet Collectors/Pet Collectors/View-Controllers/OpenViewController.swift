//
//  OpenViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 1/5/2023.
// TODO: creat func that allows user to 'open' 3 cards when timer runs out.

import UIKit

class OpenViewController: UIViewController {
    
    let countdownLabel = UILabel()
    var countdownTime: TimeInterval = 24 * 60 * 60
    var timer: Timer?
    var cardTaps = 2
    let placeHolderCard = UIView()
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        setup()
        // Do any additional setup after loading the view.
    }
    
    func startCountdown() {
        countdownLabel.isHidden = false
        // Invalidate the timer if it's already running
        timer?.invalidate()

        // Create a new timer that will fire every second
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            // Decrement the countdown time
            self?.countdownTime -= 1
            
            // Format the countdown time as a string
            let hours = Int(self?.countdownTime ?? 0) / 3600
            let minutes = (Int(self?.countdownTime ?? 0) / 60) % 60
            let seconds = Int(self?.countdownTime ?? 0) % 60
            let countdownString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // Update the countdown label
            self?.countdownLabel.text = "Come back in \(countdownString) for your next pack!"
            
            
            // Stop the timer when the countdown reaches 0
            if self?.countdownTime == 0 {
                self?.timer?.invalidate()
                self?.timer = nil
                self?.countdownLabel.isHidden = true
            }
        }
    }
    
    func setup() {
        countdownLabel.text = "Come back in 24:00:00 for your next pack!"
        countdownLabel.font = .boldSystemFont(ofSize: 36)
        
        countdownLabel.numberOfLines = 0
        countdownLabel.adjustsFontSizeToFitWidth = true
        countdownLabel.textAlignment = .center
        
        placeHolderCard.backgroundColor = .lightGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
        placeHolderCard.addGestureRecognizer(tapGesture)
        placeHolderCard.layer.cornerRadius = 15
        
        view.addSubview(placeHolderCard)
        view.addSubview(countdownLabel)
        
        placeHolderCard.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 300),
            countdownLabel.heightAnchor.constraint(equalToConstant: 150),
            
            placeHolderCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeHolderCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeHolderCard.widthAnchor.constraint(equalToConstant: 300),
            placeHolderCard.heightAnchor.constraint(equalToConstant: 500)
        ])
        countdownLabel.isHidden = true
        
    }
    
    @objc func onClick() {
        cardTaps -= 1
        if(cardTaps == 1) {
            CardUtil.createCard { result in
                switch result {
                case .success(let cardData):
                    self.databaseController?.addCard(breed: cardData["breed"] as! String, statistics: cardData["statistics"] as! String, rarity: cardData["rarity"] as! Rarity, details: cardData["details"] as! String, imageURL: cardData["imageURL"] as! String)
                    print(cardData)
                case .failure(let error):
                    // Handle the error here
                    print(error)
                }
            }
        } else if (cardTaps == 0) {
            placeHolderCard.isHidden = true
            startCountdown()
        }
        
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
