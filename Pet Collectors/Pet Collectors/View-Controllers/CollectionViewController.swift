//
//  ViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 24/4/2023.
// ✅ TODO: Move card creating functionality to Open View controller, add core data and persistent storage to pass data along from Open to Collection view.
// ✅ TODO: Make collection view 'zoomable'
//

import UIKit

protocol CollectionViewControllerDelegate: AnyObject {
    func didSelectCard(_ card: Card)
}

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DatabaseListener {
    
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewZoomButton: UIBarButtonItem!
    var allBreeds: [Breed] = []
    var listenerType = ListenerType.card
    var imageURL: String?
    var data: Data?
    private let REUSE_IDENTIFIER = CardViewCell.reuseIdentifier
    private var collectionView: UICollectionView!
    var allCards: [Card] = []
    var selectedCard: Card?
    var selectedImage: String?
    weak var databaseController: DatabaseProtocol?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var tradeActive = false // to understand if the tradeVC was the one that showed this view
    weak var delegate: CollectionViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        setup()
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
            if currentCellSize.width < 300 && currentCellSize.height < 500 {
                collectionViewZoomButton.image = UIImage(named: "Swipe")
                return currentCellSize
            } else {
                collectionViewZoomButton.image = UIImage(named: "Zoom Out")
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
        selectedCard = allCards[indexPath.row]
        if(tradeActive) {
            delegate?.didSelectCard(selectedCard ?? Card())
            UIUtil.displayMessageDimiss("Success!", "Card has been successfully added as an offer. Swipe down to continue", self)
        } else {
            performSegue(withIdentifier: "moreInfoSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfoSegue" {
            if let destinationVC = segue.destination as? InfoViewController {
                // Pass any necessary data to the destination view controller
                destinationVC.selectedCard = selectedCard
            }
        }
    }
    
    func onCardsChange(change: DatabaseChange, cards: [Card]) {
        allCards = cards
        collectionView.reloadData()
    }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    func setup() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            // Set the initial size of the collection view cells
            layout.itemSize = CGSize(width: 300, height: 500)
        }
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        collectionView.addGestureRecognizer(pinchGestureRecognizer)
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
    }
    
    func onTimerChange(change: DatabaseChange, timer: PackTimer) {
    }
    
    
    /**
     Handler method for the pinch gesture recognizer.
     
     This method is called when a pinch gesture is detected on the collection view. It adjusts the size of the collection view cells based on the pinch scale to enable zooming functionality.
     
     - Parameters:
     - gestureRecognizer: The `UIPinchGestureRecognizer` object that detected the pinch gesture.
     */
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
    
    
    /**
     Action method called when the zoom switch button is tapped.
     
     This method toggles between two zoom levels for the collection view cells. It adjusts the item size in the collection view layout and reloads the collection view to apply the changes.
     
     - Parameters:
     - sender: The object that triggered the action.
     */
    @IBAction func switchZoom(_ sender: Any) {
        // Toggle between zoom levels based on the current state of the zoom switch button
        // Adjust the item size in the collection view layout and reload the collection view
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        if let zoomOut = UIImage(named: "Zoom Out"), collectionViewZoomButton.image?.isEqual(zoomOut) == true {
            layout?.itemSize = CGSize(width: 96, height: 160)
        }
        if let swipe = UIImage(named: "Swipe"), collectionViewZoomButton.image?.isEqual(swipe) == true {
            layout?.itemSize = CGSize(width: 300, height: 500)
        }
        collectionView.reloadData()
    }
    
    /**
     Action method called when the logout button is tapped.
     
     This method handles the user logout functionality. It signs out the user using the authentication controller, performs a segue to the logout screen, and logs the outcome of the logout process.
     
     - Parameters:
     - sender: The object that triggered the action.
     */
    @IBAction func logOut(_ sender: Any) {
        do {
            // Sign out the user using the authentication controller
            try databaseController?.authController.signOut()
            
            // Perform a segue to the logout screen
            performSegue(withIdentifier: "logoutSegue", sender: nil)
            
            // Log the successful logout
            print("Logout Successful")
        } catch {
            // Handle the failed logout
            print("Logout failed with error: \(error)")
        }
    }
}
