//
//  TradeViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 1/5/2023.
//  ✅ TODO: Create firebase login auth for users and add to database etc...

import UIKit

class TradeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var tradeCards: [Card] = []
    private let REUSE_IDENTIFIER = CardViewCell.reuseIdentifier
    let cardsForTradeLabel = UILabel()
    var collectionView: UICollectionView!
    let addButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Trade"
        setup()
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tradeCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CardViewCell
        let card = tradeCards[indexPath.row]
        cell.configure(with: card)
        return cell
    }
    
    private func setup() {
        cardsForTradeLabel.text = "Your cards currently for trade:"
        cardsForTradeLabel.textAlignment = .center
        cardsForTradeLabel.font = .boldSystemFont(ofSize: 18)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 96, height: 160)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        //collectionView.backgroundColor = .gray
        
        addButton.backgroundColor = UIColor.systemBlue
        addButton.setTitle("Add Card", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 5
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        view.addSubview(addButton)
        view.addSubview(cardsForTradeLabel)
        view.addSubview(collectionView)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cardsForTradeLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardsForTradeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardsForTradeLabel.widthAnchor.constraint(equalToConstant: view.frame.width),
            cardsForTradeLabel.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: cardsForTradeLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            addButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 125),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -125)
        ])
    }
    
    @objc func addButtonTapped() {
        UIUtil.displayMessageContinueCancel("Add card to trade", "To trade, select a card from your collection and click the '+' in the top right corner?", self) { isContinue in
            if isContinue {
                // Using the tab bar controller to reduce use of segues
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            } else {}
        }
    }
    
//    func displayMessage(_ title: String, _ message: String, completion: @escaping (Bool) -> Void) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            completion(false) // User selected "Cancel"
//        })
//
//        alertController.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
//            completion(true) // User selected "Continue"
//        })
//
//        DispatchQueue.main.async {
//            self.present(alertController, animated: true, completion: nil)
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
