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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        
        let labelText = "Description: \n" + (selectedCard?.details ?? "")
        let attributedText = NSMutableAttributedString(string: labelText)

        // Set font and size for the first word
        let range1 = (labelText as NSString).range(of: "Description:")
        let font1 = UIFont.boldSystemFont(ofSize: 18)
        attributedText.addAttribute(.font, value: font1, range: range1)
        
        title = selectedCard?.breed
        
        detailsLabel.attributedText = attributedText
        //detailsLabel.numberOfLines = 0
        //detailsLabel.adjustsFontSizeToFitWidth = true
        detailsLabel.layer.borderColor = UIColor.black.cgColor
        detailsLabel.layer.borderWidth = 0.5
        detailsLabel.font = .systemFont(ofSize: 16)

        
        statisticsLabel.text = selectedCard?.statistics
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
            //image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: (view.frame.width - 20)),
            image.heightAnchor.constraint(equalToConstant: 200),
            
            detailsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailsLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 20),
            detailsLabel.widthAnchor.constraint(equalToConstant: (view.frame.width - 20)),
            //detailsLabel.heightAnchor.constraint(equalToConstant: 300),
            
            statisticsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            statisticsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            statisticsLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 10),
            statisticsLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
            
        ])
        // countdownLabel.isHidden = true
        
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
    

}
