// 
//  Util.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import Foundation
import UIKit

class ApiUtil {
    
    static func makeApiCall(url: URL, headers: [String: String]? = nil, completion: @escaping (Data?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NSError(domain: "Error: Invalid HTTP response", code: -1, userInfo: nil))
                return
            }
            
            completion(data, nil)
        }
        
        task.resume()
    }
    
    static func wikipideaAPI(for dogBreed: String, completion: @escaping (Result<String, Error>) -> Void) {
        let encodedDogBreed = dogBreed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/" + (encodedDogBreed ?? "")
        //print(urlString)
        guard let url = URL(string: urlString) else { return }
        
        ApiUtil.makeApiCall(url: url) { data, error in
            if let error = error {
                // handle error
                print("Error fetching data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                // handle missing data
                print("No data returned")
                let error = NSError(domain: "Error: No data returned", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            // handle data
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let description = json?["extract"] as? String else {
                    let error = NSError(domain: "Error: Failed to get description", code: -1, userInfo: nil)
                    completion(.failure(error))
                    return
                }
                completion(.success(description))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    static func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url) {
                let dogImage = UIImage(data: imageData)
                DispatchQueue.main.async {
                    completion(dogImage)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
}

class CardUtil {
    
    static var imageURL: String?
    static let API_KEY = "wc1HVS7jhkVlyrOr99Mk7g==r2pXzaSabDkQ79VH"
    static weak var databaseController: DatabaseProtocol?

    static func createCard(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let breeds = databaseController?.breedList
        print(breeds)
        
        //using recursion to repeat this function until there is a successful call of all 3 api's ensuring a card is created. If the firestroe database cannot be reached. It will exit automatically
        func fetchCard() {
            guard let breeds = breeds else {
                completion(.failure(NSError(domain: "Error: Failed to fetch breeds", code: -1, userInfo: nil)))
                return
            }
            if(!breeds.isEmpty) {
                let dogbreed = breeds[Int.random(in: 0..<breeds.count)]
                getRandomDogAPI(for: dogbreed) { imageURLResult in
                    switch imageURLResult {
                    case .success(let imageURL):
                        getDogStatistics { statisticResult in
                            switch statisticResult {
                            case .success(let data):
                                //let dogBreed = getDogBreed()
                                getDogDescription { description in
                                    switch description {
                                    case .success(let detailData):
                                        let breed = capitalizeFirstLetterAndAfterSpace(getDogBreed())
                                        let rarityArr = [0.75, 0.15, 0.025, 0.005, 0.001]
                                        let randomInt = chooseEventIndex(probs: rarityArr)
                                        let statistics = decodeJSONStatistics(jsonData: data)
                                        let retval = ["breed": breed, "details": detailData, "rarity": Rarity(rawValue: Int32(randomInt)), "imageURL": imageURL, "statistics": statistics] as [String: Any]
                                        
                                        completion(.success(retval))
                                    case .failure(let error):
                                        // Retry fetching the card
                                        print("Error fetching dog details: \(error.localizedDescription)")
                                        fetchCard()
                                    }
                                }
                            case .failure(let error):
                                // Retry fetching the card
                                print("Error fetching dog statistics: \(error.localizedDescription)")
                                fetchCard()
                            }
                        }
                    case .failure(let error):
                        // Retry fetching the card
                        print("Error fetching random dog image URL: \(error.localizedDescription)")
                        fetchCard()
                    }
                }
            }
        }
        
        fetchCard()
    }
    
    static func getDogDescription(completion: @escaping (Result<String, Error>) -> Void) {
        let dogBreed = getDogBreed()
        let apiKey = APIKEYS().OPEN_AI
        let urlString = "https://api.openai.com/v1/chat/completions"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Error: Invalid API URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dogPrompt = "Describe the \(dogBreed) breed of dogs in a few sentences."

        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that provides dog descriptions."],
                ["role": "user", "content": dogPrompt]
            ]
        ]
        
        
        guard let requestData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            completion(.failure(NSError(domain: "Error: Failed to serialize request data", code: -1, userInfo: nil)))
            return
        }
        request.httpBody = requestData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "Error: No data returned", code: -1, userInfo: nil)))
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            } else {
                print("Failed to convert data to string")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let description = choices.last?["message"] as? [String: Any],
                   let content = description["content"] as? String {
                    completion(.success(content))
                } else {
                    completion(.failure(NSError(domain: "Error: Failed to parse response", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    static func getRandomDogAPI(for dogBreed: String, completion: @escaping (Result<String, Error>) -> Void) {
        print(dogBreed)
        let urlString = "https://dog.ceo/api/breed/\(dogBreed)/images/random"
        guard let url = URL(string: urlString) else { return }
        print(url)
        ApiUtil.makeApiCall(url: url) { data, error in
            if let error = error {
                // handle error
                print("Error fetching data in getRandomDogAPI: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                // handle missing data
                print("No data returned")
                return
            }
            
            // handle data
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
    }
    
    static func getDogStatistics(completion: @escaping (Result<Data, Error>) -> Void) {
        let dogBreed = getDogBreed()
        let name = dogBreed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "https://api.api-ninjas.com/v1/dogs?name=" + (name ?? "")
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Error: Invalid URL", code: -1, userInfo: nil)))
            return
        }
        let headers = ["X-Api-Key": API_KEY]
        ApiUtil.makeApiCall(url: url, headers: headers) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: nil)))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            completion(.success(data))
        }
    }
    
    static func getDogBreed() -> String {
        if let range = imageURL?.range(of: #"breeds/([\w-]+)/"#, options: .regularExpression) {
            var breed = imageURL?[range].replacingOccurrences(of: "-", with: " ") ?? "golden retriever"
            breed = breed.replacingOccurrences(of: "breeds/", with: "")
            breed = breed.replacingOccurrences(of: "/", with: "")
            breed = breed.split(separator: " ").reversed().joined(separator: " ")

            print("this is the sod breed being parsed: \(breed)")
            return breed
        }
        return "golden retiever"
    }
    
    static func capitalizeFirstLetterAndAfterSpace(_ string: String) -> String {
        var capitalizedString = string.capitalized
        
        for i in capitalizedString.indices {
            if capitalizedString[i] == " " && i < capitalizedString.index(before: capitalizedString.endIndex) {
                let nextIndex = capitalizedString.index(after: i)
                capitalizedString.replaceSubrange(nextIndex...nextIndex, with: String(capitalizedString[nextIndex]).capitalized)
            }
        }
        //self.currentDog = capitalizedString
        return capitalizedString
    }
    
    static func chooseEventIndex(probs: [Double]) -> Int {
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
    
    static func decodeJSONStatistics(jsonData: Data) -> String {
        // Assume jsonData is the JSON data received from API
        do {
            var retVal = ""
            let cardDetails = try JSONDecoder().decode([CardDetails].self, from: jsonData)
            
            if let firstCard = cardDetails.first {
                var keys = [  ["Good with children", String(firstCard.goodWithChildren)],
                              ["Good with other dogs", String(firstCard.goodWithOtherDogs)],
                              ["Shedding level", String(firstCard.shedding)],
                              ["Grooming level", String(firstCard.grooming)],
                              ["Drooling level", String(firstCard.drooling)],
                              ["Coat length", String(firstCard.coatLength)],
                              ["Good with strangers", String(firstCard.goodWithStrangers)],
                              ["Playfulness level", String(firstCard.playfulness)],
                              ["Protectiveness level", String(firstCard.protectiveness)],
                              ["Trainability level", String(firstCard.trainability)],
                              ["Energy level", String(firstCard.energy)],
                              ["Barking level", String(firstCard.barking)]
                ]
                
                var text = ""
                for key in keys {
                    text += "\(key[0]): \(key[1])/5\n"
                }
                
                //can get json object to string but it is more efficient to use decodable rather than looping through all characters of the json data
                //let text = String(data: jsonData, encoding: .utf8)
                print(text)
                retVal = text
            }
            return retVal
            
        } catch {
            print("Error decoding JSON: \(error)")
        }
        return ""
        
    }
    
    static func setColor(rarity: Int32) -> UIColor{
        switch rarity {
        case 0:
            return #colorLiteral(red: 0.6443734765, green: 0.6593127847, blue: 0.6590517163, alpha: 1)
        case 1:
            return #colorLiteral(red: 0.3268340826, green: 0.6946660876, blue: 0.905626595, alpha: 1)
        case 2:
            return #colorLiteral(red: 0.6719612479, green: 0.3691940308, blue: 0.9197270274, alpha: 1)
        case 3:
            return #colorLiteral(red: 0.9144165516, green: 0.7269795537, blue: 0, alpha: 1)
        case 4:
            return #colorLiteral(red: 0.9476212859, green: 0.264480412, blue: 0.2327539623, alpha: 1)
        default:
            return #colorLiteral(red: 0.6443734765, green: 0.6593127847, blue: 0.6590517163, alpha: 1)
        }
    }
    
}

class BreedUtil {
    static func getAllBreeds(completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://dog.ceo/api/breeds/list/all"
        guard let url = URL(string: urlString) else { return }
        
        ApiUtil.makeApiCall(url: url) { data, error in
            if let error = error {
                // handle error
                print("Error fetching data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                // handle missing data
                print("No data returned")
                let error = NSError(domain: "Error: No data returned", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            // handle data
            do {
                let jsonString = String(data: data, encoding: .utf8)
                completion(.success(jsonString!))
            } catch {
                completion(.failure(error))
            }
        }
    }

    
    static func parseJsonObject(_ jsonObject: [String: Any]) -> [String] {
        var stringArray = [String]()
        
        for (key, value) in jsonObject {
            if let subArray = value as? [String] {
                for subValue in subArray {
                    stringArray.append("\(key) \(subValue)")
                }
            }
        }
        
        return stringArray
    }
    
    
}


class UIUtil {
    static func displayMessage(_ title: String, _ message: String, from viewController: UIViewController) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                viewController.present(alertController, animated: true, completion: nil)
            }
        }
}
