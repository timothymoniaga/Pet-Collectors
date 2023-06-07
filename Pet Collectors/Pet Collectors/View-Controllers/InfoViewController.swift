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
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setup()
    }
    
    func setup() {
        
        let labelText = "Description: \n" + (selectedCard?.details ?? "")
        print(labelText.debugDescription)
        let attributedText = NSMutableAttributedString(string: labelText)
        
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
        //image.image.layer.cornerRadius = 15
        
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
        loadImageFromURL(urlString: selectedCard?.imageURL ?? "")
        
    }
    
    
    func loadImageFromURL(urlString: String) {
        image.image = UIImage(named: "PlaceholderPaw")
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let dogImage = UIImage(data: imageData)
                    let roundedImage = dogImage?.roundedImage(cornerRadius: 10)
                    self.image.image = roundedImage
                    
                }
            }
        }
    }
    
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
    
    @IBAction func addCardForTrade(_ sender: Any) {
        UIUtil.displayMessageContinueCancel("Add card to trade", "Are you sure you want to add this card to trade?", self) { isContinue in
            if isContinue {
                guard let cardID = self.selectedCard?.cardID else {
                    return
                }
                self.databaseController?.addCardToTradeCollection(cardID: cardID, self)
            } else {}
        }
        
    }
}
