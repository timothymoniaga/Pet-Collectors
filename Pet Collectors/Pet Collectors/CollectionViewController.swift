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
    
    var imageURL: String?
    var data: Data?
    private let REUSE_IDENTIFIER = "CardCell"
    private var collectionView: UICollectionView!
    var cards: [Card] = []
    let API_KEY = "wc1HVS7jhkVlyrOr99Mk7g==r2pXzaSabDkQ79VH"
    var currentDog: String?
    var selectedImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let icon = UIImage(named: "Collection")?.withRenderingMode(.alwaysOriginal)
//        let iconSelected = UIImage(named: "Collection Selected")?.withRenderingMode(.alwaysOriginal)
//        let item = UITabBarItem(title: "Collection", image: icon, selectedImage: iconSelected)
//        self.tabBarItem = item
        
        setup()
        //getRandomDogAPI()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = cards[indexPath.row].imageURL
        performSegue(withIdentifier: "imageSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageSegue" {
               if let destinationVC = segue.destination as? ImageViewController {
                   // Pass any necessary data to the destination view controller
                   destinationVC.imageURL = selectedImage
               }
           }
    }
    
    @IBAction func addCard(_ sender: Any) {
        getRandomDogAPI { imageURL in
            self.getDogDetails() { result in
                switch result {
                case .success(let data):
                    let breed = self.capitalizeFirstLetterAndAfterSpace(self.getDogBreed())
                    let rarityArr = [0.75, 0.1, 0.05, 0.025, 0.001]
                    let randomInt = self.chooseEventIndex(probs: rarityArr)
                    self.cards.append(Card(breed: breed, details: "Hello", rarity: randomInt, imageURL: self.imageURL, statistics: data))
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    // Process the data here
                case .failure(let error):
                    print(error)
                    break
                    // Handle the error here
                }
            }
        }
    }

    
    
    func getRandomDogAPI(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random") else {
            completion(.failure(NSError(domain: "Error: Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Error: No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let message = json?["message"] as? String else {
                    completion(.failure(NSError(domain: "Error: Failed to extract image URL from response", code: -1, userInfo: nil)))
                    return
                }
                print("Image URL: \(message)")
                self.imageURL = message
                completion(.success(message))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    
    func capitalizeFirstLetterAndAfterSpace(_ string: String) -> String {
        var capitalizedString = string.capitalized
        
        for i in capitalizedString.indices {
            if capitalizedString[i] == " " && i < capitalizedString.index(before: capitalizedString.endIndex) {
                let nextIndex = capitalizedString.index(after: i)
                capitalizedString.replaceSubrange(nextIndex...nextIndex, with: String(capitalizedString[nextIndex]).capitalized)
            }
        }
        
        return capitalizedString
    }
    
    func getDogDetails(completion: @escaping (Result<Data, Error>) -> Void) {
        let dogBreed = getDogBreed()
        let name = dogBreed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        print("dog details name: ",name)
        print("dog details url: ", imageURL)
        let url = URL(string: "https://api.api-ninjas.com/v1/dogs?name="+name!)!
        var request = URLRequest(url: url)
        request.setValue(API_KEY, forHTTPHeaderField: "X-Api-Key")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "ResponseError", code: 0, userInfo: nil)))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: nil)))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            completion(.success(data))
        }
        task.resume()
    }
    
    
    func getDogBreed() -> String {
        if let range = imageURL?.range(of: #"breeds/([\w-]+)/"#, options: .regularExpression) {
            var breed = imageURL?[range].replacingOccurrences(of: "-", with: " ") ?? "golden retriever"
            breed = breed.replacingOccurrences(of: "breeds/", with: "")
            breed = breed.replacingOccurrences(of: "/", with: "")
            
            return breed
        }
        return "golden retiever"
    }
    
    func chooseEventIndex(probs: [Double]) -> Int {
        let totalProb = probs.reduce(0, +)
        var random = Double.random(in: 0..<totalProb)
        for (i, prob) in probs.enumerated() {
            random -= prob
            if random <= 0 {
                return i
            }
        }
        return 0
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

