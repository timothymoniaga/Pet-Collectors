//
//  ViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 24/4/2023.
// TODO: Move card creating functionality to Open View controller, add core data and persistent storage to pass data along from Open to Collection view. Make collection view 'zoomable'
//

import UIKit



//struct Image: Decodable {
//    let message: String
//    let status: String
//    
//    enum CodingKeys: String, CodingKey {
//        case message = "imageURL"
//        case status
//    }
//}
class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DatabaseListener {
    
    var listenerType = ListenerType.card
    var imageURL: String?
    var data: Data?
    private let REUSE_IDENTIFIER = CardViewCell.reuseIdentifier
    private var collectionView: UICollectionView!
    var allCards: [Card] = []
    var currentDog: String?
    var selectedImage: String?
    weak var databaseController: DatabaseProtocol?
    
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
        selectedImage = allCards[indexPath.row].imageURL
        performSegue(withIdentifier: "imageSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageSegue" {
            if let destinationVC = segue.destination as? ImageViewController {
                // Pass any necessary data to the destination view controller
                destinationVC.imageURL = selectedImage
                destinationVC.dogBreed = currentDog
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
    
}

