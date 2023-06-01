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
    let image = UIImageView()
    let countdownLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView()
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
        currentTimer = databaseController?.fetchTimer()
        timerSetup()
        
        // Do any additional setup after loading the view.
    }
    
    func timerSetup() {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        //print(currentTimer?.count)
        
        let calendar = Calendar.current
        //let startDate = // The start date
        //let endDate = // The end date
        
        if (currentTimer?.count ?? 0 < 1) {
            
            if let futureDate = futureDate {
                print(futureDate)
                databaseController?.setDates(startDate: currentDate, endDate: futureDate)
                
            } else {
                print("Failed to calculate future date")
                // Handle the case where future date calculation fails
            }
        }
        else {
            if let futureDate = futureDate {
                let components = calendar.dateComponents([.second], from: currentDate, to: currentTimer?[0].endDate ?? futureDate)
                //print(currentTimer?[0].startDate)
                //print(currentTimer?[0].endDate)
                if let seconds = components.second {
                    if seconds <= 0 {
                        databaseController?.removeTimers()
                        databaseController?.setDates(startDate: currentDate, endDate: futureDate)
                    } else {
                        print(seconds)
                        countdownTime = TimeInterval(seconds)
                    }
                    
                }
            }

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
        createbreeds.isEnabled = false
        createbreeds.isHidden = true
        
        countdownLabel.text = "Come back in for your next pack!"
        countdownLabel.font = .boldSystemFont(ofSize: 36)
        
        countdownLabel.numberOfLines = 0
        countdownLabel.adjustsFontSizeToFitWidth = true
        countdownLabel.textAlignment = .center
        
        placeHolderCard.backgroundColor = .lightGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
        placeHolderCard.addGestureRecognizer(tapGesture)
        placeHolderCard.layer.cornerRadius = 15
        
        activityIndicator.color = .black
        
        view.addSubview(placeHolderCard)
        view.addSubview(countdownLabel)
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
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
            placeHolderCard.heightAnchor.constraint(equalToConstant: 500),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        countdownLabel.isHidden = true
        
    }
    func changeCard() {
        
        DispatchQueue.main.async {
            self.placeHolderCard.backgroundColor = CardUtil.setColor(rarity: self.currentCard?.cardRarity.rawValue ?? 0)
        }

        ApiUtil.loadImageFromURL(urlString: currentCard?.imageURL ?? "") { picture in
            if let picture = picture {
                self.image.image = picture
            } else {
                self.image.image = UIImage(named: "PlaceholderPaw")
            }
            
        }
        DispatchQueue.main.async {
            self.image.contentMode = .scaleAspectFit
            self.placeHolderCard.addSubview(self.image)
            self.image.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.image.centerXAnchor.constraint(equalTo: self.placeHolderCard.centerXAnchor),
                self.image.centerYAnchor.constraint(equalTo: self.placeHolderCard.centerYAnchor),
                self.image.widthAnchor.constraint(equalTo: self.placeHolderCard.widthAnchor),
                self.image.heightAnchor.constraint(equalTo: self.placeHolderCard.widthAnchor)
            ])
        }

    }
    
    @objc func onClick() {
        cardTaps -= 1
        if(cardTaps == 1) {
            activityIndicator.startAnimating()

            CardUtil.createCard { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    }
                switch result {
                case .success(let cardData):
                    self.currentCard = self.databaseController?.addCard(breed: cardData["breed"] as! String, statistics: cardData["statistics"] as! String, rarity: cardData["rarity"] as! Rarity, details: cardData["details"] as! String, imageURL: cardData["imageURL"] as! String)
                    print(cardData)
                    self.changeCard()
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
    
    @IBAction func addCard(_ sender: Any) {
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
    
//    func temp () {
//        BreedUtil.getAllBreeds { result in
//            switch result {
//            case .success(let message):
//                print("List of all dog breeds: \(message)")
//
//                let data = message.data(using: .utf8)
//                print(data)
//                do {
//                    let breeds = try JSONDecoder().decode(DogBreeds.self, from: data!)
//                    let breedArray = breeds.message.flatMap { breed in
//                        breed.value.map { "\($0)" }
//                    }
//
//                    for breedName in breedArray {
//                        ApiUtil.wikipideaAPI(for: breedName) { result in
//                            switch result {
//                            case .success( _):
//                                self.databaseController?.addBreed(breedName: breedName)
//
//                            case .failure(let error):
//                                print("Error fetching data: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//
//                    print(breedArray)
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//
//            case .failure(let error):
//                print("Error fetching data: \(error.localizedDescription)")
//                // Handle the error here
//            }
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
