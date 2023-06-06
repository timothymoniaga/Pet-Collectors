//
//  OpenViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 1/5/2023.
// TODO: creat func that allows user to 'open' 3 cards when timer runs out.

import UIKit

struct DogBreeds: Codable {
    let message: [String: [String]]
    let status: String
}

class OpenViewController: UIViewController {
    
    @IBOutlet weak var createbreeds: UIBarButtonItem!
    
    var packTimer: PackTimer?
    var currentTimer: [PackTimer]?
    var currentCard: Card?
    let countdownLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    var countdownTime: TimeInterval = 24 * 60 * 60
    var timer: Timer?
    var cardTaps = 2
    var cards: [CardView] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        currentTimer = databaseController?.fetchTimer()
        setup()
        }
    
    func timerSetup() {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = 1
        guard let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) else {
            print("Failed to calculate future date")
            return
        }
        
        if currentTimer?.isEmpty ?? true {
            databaseController?.setDates(startDate: currentDate, endDate: futureDate)
            
            // Adding cards into the array
            createUnopenedCards()
        } else if let endDate = currentTimer?[0].endDate {
            let seconds = Int(endDate.timeIntervalSince(currentDate))
            if seconds <= 0 {
                databaseController?.removeTimers()
                databaseController?.setDates(startDate: currentDate, endDate: futureDate)
                
                // Adding cards into the array
                createUnopenedCards()
                
            } else {
                countdownTime = TimeInterval(seconds)
                print(countdownTime)
                startCountdown()
            }
        }
    }
    
    func createUnopenedCards() {
        var cardViews: [CardView] = []
        
        for _ in 1...3 {
            let card = CardView()
            cardViews.append(card)
        }
        
        cards = cardViews
        
        for (i, card) in cards.enumerated() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
            card.addGestureRecognizer(tapGesture)
            view.addSubview(card)
            
            card.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                card.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: CGFloat(i) * 7.5),
                card.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CGFloat(i) * -7.5),
                card.heightAnchor.constraint(equalToConstant: CGFloat(card.HEIGHT)),
                card.widthAnchor.constraint(equalToConstant: CGFloat(card.WIDTH))
            ])
        }
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
        //enable and hidden for dubgging
        createbreeds.isEnabled = false
        createbreeds.isHidden = true
        
        countdownLabel.text = "Come back in for your next pack!"
        countdownLabel.font = .boldSystemFont(ofSize: 36)
        
        countdownLabel.numberOfLines = 0
        countdownLabel.adjustsFontSizeToFitWidth = true
        countdownLabel.textAlignment = .center
        
        activityIndicator.color = .white
        
        blurView.isHidden = true
        blurView.alpha = 0.2
        
        view.addSubview(countdownLabel)
        view.addSubview(activityIndicator)
        view.addSubview(blurView)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 300),
            countdownLabel.heightAnchor.constraint(equalToConstant: 150),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        countdownLabel.isHidden = true
        
        timerSetup()
        
    }
    
    @objc func onClick() {
        view.bringSubviewToFront(blurView)
        view.bringSubviewToFront(activityIndicator)
        let topCard = cards[cards.count - 1]
        if(!topCard.isFlipped) {
            activityIndicator.startAnimating()
            blurView.isHidden = false
            //view.isUserInteractionEnabled = false
            
            CardUtil.createCard { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.blurView.isHidden = true
                    //self.view.isUserInteractionEnabled = true

                }
                switch result {
                case .success(let cardData):
                    let newCard = self.databaseController?.addCardPersistentStorage(breed: cardData["breed"] as! String, statistics: cardData["statistics"] as! String, rarity: cardData["rarity"] as! Rarity, details: cardData["details"] as! String, imageURL: cardData["imageURL"] as! String)
                    self.currentCard = newCard
                    print(cardData)
                    topCard.changeCard(card: self.currentCard ?? Card())
                    topCard.isFlipped = true
                    
                    self.databaseController?.addCardFirestore(card: newCard ?? Card())
                case .failure(let error):
                    // Handle the error here
                    print(error)
                }
            }
        } else if (topCard.isFlipped) {
            topCard.isHidden = true
            topCard.removeFromSuperview()
            cards.removeLast()
        }
        if (cards.isEmpty) {
            startCountdown()
        }
        
    }
    
    // Was used for creating a list of breeds for wikipidea.
    @IBAction func createListOfBreeds(_ sender: Any) {
        /// Remove timers for dubgging
        //databaseController?.removeTimers()

        BreedUtil.getAllBreeds { result in
            switch result {
            case .success(let message):
                print("List of all dog breeds: \(message)")

                let data = message.data(using: .utf8)
                print(data)

                do {
                    let decoder = JSONDecoder()
                    let breeds = try decoder.decode(DogBreeds.self, from: data!)

                    var masterBreedArray = []
                    for (key, _) in breeds.message {
                        masterBreedArray.append(key)
                    }
                    print(masterBreedArray)

                    for breedName in masterBreedArray {
                        ApiUtil.wikipideaAPI(for: breedName as! String) { result in
                            switch result {
                            case .success( _):
                                self.databaseController?.addBreed(breedName: breedName as! String)

                            case .failure(let error):
                                print("Error fetching data: \(error.localizedDescription)")
                            }
                        }
                    }
                    //print(resultArray)
                }

                catch {
                    print("Error decoding JSON: \(error)")
                }

            case .failure(let error):
                print("Error fetching data: \(error.localizedDescription)")
                // Handle the error here
            }
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
