//
//  ViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 24/4/2023.
// ✅ TODO: Move card creating functionality to Open View controller, add core data and persistent storage to pass data along from Open to Collection view.
// ✅ TODO: Make collection view 'zoomable'
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DatabaseListener {
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    var allBreeds: [Breed] = []
    var listenerType = ListenerType.card
    var imageURL: String?
    var data: Data?
    private let REUSE_IDENTIFIER = CardViewCell.reuseIdentifier
    private var collectionView: UICollectionView!
    var allCards: [Card] = []
    var currentDog: Card?
    var selectedImage: String?
    weak var databaseController: DatabaseProtocol?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        setup()
        //getRandomDogAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CardViewCell
        let card = allCards[indexPath.row]
        cell.configure(with: card)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let currentCellSize = layout.itemSize
            if currentCellSize.width <= 300 && currentCellSize.height <= 500 {
                return currentCellSize
            } else {
                return CGSize(width: 300, height: 500)
            }
        }
        
        // Default size if the layout is not a UICollectionViewFlowLayout
        return CGSize(width: 300, height: 500)
    }


    // Centres the card on initial view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    // Gap inbetween the cards
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentDog = allCards[indexPath.row]
        performSegue(withIdentifier: "moreInfoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfoSegue" {
            if let destinationVC = segue.destination as? InfoViewController {
                // Pass any necessary data to the destination view controller
                destinationVC.selectedCard = currentDog
            }
        }
    }
    
    func onCardsChange(change: DatabaseChange, cards: [Card]) {
        allCards = cards
        collectionView.reloadData()
    }
    
    
    func setup() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // Set the initial size of the collection view cells
            layout.itemSize = CGSize(width: 300, height: 500)
        }
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGestureRecognizer)
        
        // collectionView.backgroundColor = .gray
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
        
    }
    
    func onTimerChange(change: DatabaseChange, timer: PackTimer) {
    }
    
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .changed {
            let pinchScale = gestureRecognizer.scale
            let currentCellSize = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: 0))
            
            // Calculate the new width and height based on the pinch scale and the desired ratio of 3:5
            let newWidth = currentCellSize.width * pinchScale
            let newHeight = newWidth * (5 / 3)
            
            // Update the cell size in the collection view layout
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            layout?.itemSize = CGSize(width: newWidth, height: newHeight)
            
            // Reload the collection view to apply the new cell size
            collectionView.reloadData()
            
            // Reset the gesture scale to 1 to avoid cumulative scaling
            gestureRecognizer.scale = 1.0
        }
    }

    
    
    @IBAction func logOut(_ sender: Any) {
        print("Hello, Logout button pressed")
        
        do {
            try databaseController?.authController.signOut()
            //removeAllCards() // Remove all cards from persistent storage upon logout
            performSegue(withIdentifier: "logoutSegue", sender: nil)
            print("Logout Successful")
            // Logout successful
        } catch {
            print("Logout failed with error: \(error)")
        }
    }
}

