//
//  InfoViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 10/5/2023.
//

import UIKit

class InfoViewController: UIViewController {
    
    var selectedCard: Card?
    let image = UIImageView()
    let detailsLabel = UITextView()
    let statisticsLabel = UILabel()
    // let tradeVC: TradeViewController = TradeViewController()
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setup()
    }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        title = selectedCard?.breed
        
        detailsLabel.showsVerticalScrollIndicator = true
        detailsLabel.text = "Description: \n" + (selectedCard?.details ?? "")
        detailsLabel.font = .systemFont(ofSize: 16)
        detailsLabel.isEditable = false
        detailsLabel.textContainerInset = .zero
        
        if let statistics = selectedCard?.statistics, statistics != "" {
            statisticsLabel.text = "Statistics: \n" + (selectedCard?.statistics ?? "")
        }
        else {
            statisticsLabel.text = "Statistics unavaliable for this dog breed 😕"
        }
        statisticsLabel.font = .systemFont(ofSize: 16)
        statisticsLabel.numberOfLines = 0
        statisticsLabel.adjustsFontSizeToFitWidth = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageClick))
        image.addGestureRecognizer(tapGesture)
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = true
        
        view.addSubview(detailsLabel)
        view.addSubview(statisticsLabel)
        view.addSubview(image)
        
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        statisticsLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            image.widthAnchor.constraint(equalToConstant: (view.frame.width - 30)),
            image.heightAnchor.constraint(equalToConstant: 200),
            
            detailsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailsLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
            detailsLabel.widthAnchor.constraint(equalToConstant: (view.frame.width - 20)),
            detailsLabel.heightAnchor.constraint(equalToConstant: 150),
            
            statisticsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            statisticsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            statisticsLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: -10),
            statisticsLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
            
        ])
        ApiUtil.loadImageFromURL(urlString: selectedCard?.imageURL ?? "") { image in
            if let image = image {
                self.image.image = image.roundedImage(cornerRadius: 15)
            } else {
                self.image.image = UIImage(named: "PlaceholderPaw")
            }
        }
    }
    
    /**
     Handles the click event on an image and performs a segue to another view controller.

     This method is invoked when an image is clicked or tapped. It triggers a segue with the identifier "imageSegue" to transition to another view controller.

     - Note: This method is typically used to navigate to a different view controller or present additional information when an image is clicked.

     - SeeAlso: `performSegue(withIdentifier:sender:)`
     */
    @objc func imageClick() {
        performSegue(withIdentifier: "imageSegue", sender: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller
        if segue.identifier == "imageSegue" {
            if let destinationVC = segue.destination as? ImageViewController {
                // Pass any necessary data to the destination view controller
                destinationVC.dogBreed = selectedCard?.breed
                destinationVC.imageURL = selectedCard?.imageURL
            }
        }
        
    }
    
    /**
     Adds a selected card to the trade collection.

     This method is invoked when the user wants to add a selected card to the trade collection. It displays a confirmation message to ensure the user wants to proceed with adding the card. If the user confirms, the selected card's ID is retrieved and passed to the `addCardToTradeCollection(cardID:sender:)` method of the `databaseController` to add the card to the trade collection.

     - Important: The `UIUtil.displayMessageContinueCancel(_:message:completion:)` method is used to display the confirmation message dialog. The method expects a closure that is executed based on the user's choice. The `UIUtil.displayMessageDimiss(_:message:controller:)` method is used to display a success message after the card is added to the trade collection.

     - Parameters:
       - sender: The sender of the action, typically a button or UI control.

     - Note: This method is typically used in conjunction with user interactions to add a card to a trade collection. It provides a confirmation step to prevent accidental additions.
     */
    @IBAction func addCardForTrade(_ sender: Any) {
        UIUtil.displayMessageContinueCancel("Add card to trade", "Are you sure you want to add this card to trade?", self) { isContinue in
            if isContinue {
                guard let cardID = self.selectedCard?.cardID else {
                    return
                }
                self.databaseController?.addCardToTradeCollection(cardID: cardID, self)
                UIUtil.displayMessageDimiss("Success!", "Card added successfully!", self)
            } else {}
        }
    }
}
