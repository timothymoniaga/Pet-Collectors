//
//  UserViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 3/5/2023.
//

import UIKit

class UserViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var profilePicture = UIImageView()
    var offerButton = UIButton()
    
    var user: Offer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        offerButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        view.addSubview(profilePicture)
        view.addSubview(offerButton)
        
        NSLayoutConstraint.activate([
            profilePicture.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            profilePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePicture.widthAnchor.constraint(equalToConstant: 60),
            profilePicture.heightAnchor.constraint(equalToConstant: 60),
            
            collectionView.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500),
            
            offerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            offerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            offerButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -75),

            offerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.layer.borderColor = #colorLiteral(red: 0.6719612479, green: 0.3691940308, blue: 0.9197270274, alpha: 1)
        collectionView.layer.borderWidth = 3
        
        offerButton.backgroundColor = .systemBlue
        offerButton.setTitleColor(.white, for: .normal)
        offerButton.setTitle("Make Offer", for: .normal)
        offerButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        offerButton.layer.cornerRadius = 10
        offerButton.addTarget(self, action: #selector(didTapOfferButton), for: .touchUpInside)
        
    }
    
    /**
     Handles the tap gesture on the offer button.

     This method is invoked when the user taps the offer button. It triggers a segue with the identifier "offerSegue" to transition to the next screen for making an offer.

     - Important: Ensure that the segue with the identifier "offerSegue" is properly set up in the storyboard.

     - SeeAlso: `performSegue(withIdentifier:sender:)`
     */
    @objc func didTapOfferButton() {
        performSegue(withIdentifier: "offerSegue", sender: self)
    }
}
