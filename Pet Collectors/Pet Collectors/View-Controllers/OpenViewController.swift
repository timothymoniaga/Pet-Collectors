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
    
    
    /**
     Performs the initial setup for the timer.

     This method calculates the future date by adding one day to the current date and sets up the timer based on the current state.

     If `currentTimer` is empty, it sets the start and end dates in the database controller and creates unopened cards.

     If `currentTimer` is not empty, it checks if the end date has passed. If it has, it removes the existing timers, sets the start and end dates in the database controller, and creates unopened cards.

     If the end date hasn't passed, it calculates the remaining seconds and starts the countdown.
     
     - Warning: In case of failure to calculate the future date, an error message is printed and the method returns.

     - Important: The method relies on the `createUnopenedCards()` and `startCountdown()` methods for creating unopened cards and starting the countdown, respectively.
     */
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
    
    /**
     Creates unopened card views and adds them to the view hierarchy.

     This method creates three instances of `CardView` and appends them to the `cards` array. It then adds a tap gesture recognizer to each card and adds them to the view.

     - Important: The method relies on the `onClick` method for handling the tap event.

     - SeeAlso: `onClick(_:)`
     */
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
                card.heightAnchor.constraint(equalToConstant: CGFloat(card.height)),
                card.widthAnchor.constraint(equalToConstant: CGFloat(card.width))
            ])
        }
    }
    
    /**
     Starts the countdown timer and updates the countdown label.

     This method reveals the countdown label and invalidates any existing timer. It creates a new timer that fires every second. On each timer tick, it decrements the `countdownTime` property, formats the countdown time as a string in hours, minutes, and seconds, and updates the countdown label with the formatted string. When the countdown reaches zero, it stops the timer and hides the countdown label.

     - Warning: The method assumes the existence of the `timer` property as an instance variable of type `Timer?` to manage the countdown timer.

     - Note: The `countdownTime` property represents the remaining time in seconds.
     */
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
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    func setup() {
        ///enable and hidden for dubgging
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
    
    /**
     Handles the tap gesture on the top card in the card stack.

     When the top card is tapped, this method brings the blur view and activity indicator to the front, starts the activity indicator animation, and initiates the card creation process.

     If the top card is not flipped, it calls the `createCard` method to create a new card asynchronously. Upon success, it adds the new card to the persistent storage and updates the top card's content. It then marks the top card as flipped and adds the new card to Firestore.

     If the top card is already flipped, it removes the top card from the view and the `cards` array.

     If all the cards are removed from the stack, it starts the countdown for the next pack.

     - Note: The `CardUtil.createCard` method is used to create a new card asynchronously. The `CardView` class is assumed to be a custom subclass of `UIView` representing a card.

     - SeeAlso: `createCard(completion:)`, `databaseController`
     */
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
                    topCard.changeCard(card: newCard ?? Card())
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
    
    /**
     Creates a list of dog breeds using an external API and adds them to the Firestore database.

     This method retrieves a list of all dog breeds from an external API using the `BreedUtil.getAllBreeds` method. Upon success, it decodes the response into a `DogBreeds` object and extracts the breed names. It then makes an API request to fetch additional information for each breed using the `ApiUtil.wikipediaAPI(for:)` method. Upon success, it adds the breed to the Firestore database using the `databaseController?.addBreed(breedName:)` method.

     - Note: This method is not used any longed and was used for creating a list of breeds

     - Important: This method is intended for creating a list of dog breeds and may not be directly related to the main functionality of the application.
     */
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
}
