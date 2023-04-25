//
//  ViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 24/4/2023.
//

import UIKit



struct Image: Decodable {
    let message: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case message = "imageURL"
        case status
      }
}
class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean iaculis aliquam urna, at ultricies purus pellentesque ac. Quisque commodo felis ac feugiat iaculis. Mauris mattis velit nec mi mattis, nec gravida metus consequat. Duis pretium ornare libero, at cursus est sagittis a. Vivamus a eros at sem tempor tempor in eu est. Cras pharetra mauris ex, non lobortis lacus ultricies ac. Vestibulum nec mauris at arcu rutrum hendrerit. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque ut faucibus lectus. Vivamus et nibh eu mi ultricies tincidunt. Duis vitae risus eu magna convallis cursus quis hendrerit tortor. Sed non tincidunt enim. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed ut faucibus tortor, ac mollis magna. \n Nunc nec arcu ut nibh fermentum aliquet a sit amet mi. Aenean vitae neque cursus, ullamcorper lorem sed, feugiat felis. Aliquam erat volutpat. Nullam sit amet nisl hendrerit, rutrum lectus at, lacinia metus. Nunc tristique feugiat sollicitudin. Vivamus ac rhoncus mauris. Aenean laoreet mi sit amet est sodales, pharetra dapibus dui porttitor. Phasellus vitae tempus dolor, sit amet auctor augue. Sed condimentum nisi et convallis dapibus. Sed vestibulum lorem id purus euismod tempor. Aenean lacinia tincidunt diam eget vehicula. Etiam dictum ligula odio, sed posuere mi imperdiet id. Vestibulum facilisis ut justo vel faucibus. Quisque tincidunt purus tincidunt, rhoncus lorem ac, molestie dolor."
    
    var imageURL: String?
    var data: Data?
    private let REUSE_IDENTIFIER = "CardCell"
    private var collectionView: UICollectionView!
    var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CardViewCell
        let card = cards[indexPath.row]
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
    
    @IBAction func addCard(_ sender: Any) {
        callAPI()
        cards.append(Card(breed: "test", details: loremIpsum, colour: .lightGray, imageURL: imageURL ?? ""))
        collectionView.reloadData()
    }
    
    func callAPI() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let message = json?["message"] as? String else {
                    print("Error: Failed to extract image URL from response")
                    return
                }
                print("Image URL: \(message)")
                self.imageURL = message
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }

        task.resume()
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

