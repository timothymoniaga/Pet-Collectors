// 
//  Util.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import Foundation
import UIKit

class ApiUtil {
    
    /**
     Makes an API call to the specified URL with optional headers.

     This function performs a GET request to the provided `url` with optional `headers` included in the request. Upon completion, the `completion` closure is called with the resulting data or an error.

     - Parameters:
       - url: The URL to make the API call to.
       - headers: Optional headers to include in the request.
       - completion: A closure to be called when the API call is completed. It receives the data retrieved from the API call or an error, if any.
     */
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
    
    /**
     Fetches information about a dog breed from the Wikipedia API.

     This function fetches information about the specified `dogBreed` from the Wikipedia API. It makes use of the `makeApiCall` function internally. Upon completion, the `completion` closure is called with a result containing either the fetched description as a `String` or an error.

     - Parameters:
       - dogBreed: The dog breed to fetch information for.
       - completion: A closure to be called when the API call is completed. It receives a result containing either the fetched description or an error.
     
     - Note: Not used anymore
     */
    static func wikipideaAPI(for dogBreed: String, completion: @escaping (Result<String, Error>) -> Void) {
        let encodedDogBreed = dogBreed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = "https://en.wikipedia.org/api/rest_v1/page/summary/" + (encodedDogBreed ?? "")
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
    
    
    /**
     Loads an image from a URL asynchronously.

     This function loads an image from the specified `urlString` asynchronously. It fetches the image data from the URL and converts it into a `UIImage`. Upon completion, the `completion` closure is called with the loaded image or `nil` if loading fails.

     - Parameters:
       - urlString: The URL string from which to load the image.
       - completion: A closure to be called when the image loading is completed. It receives the loaded image or `nil`.
     */
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

    
    /**
     Creates a card with random dog breed, image, statistics, and description.

     This function creates a card by fetching a random dog breed from the database, retrieving a random dog image URL, fetching dog statistics, and generating a dog description using the OpenAI Chat Completions API. The resulting card contains the breed, details, rarity, imageURL, and statistics. The `completion` closure is called with a result containing either the created card or an error.

     - Parameters:
       - completion: A closure to be called when the card creation is completed. It receives a result containing either the created card or an error.
     */
    static func createCard(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let breeds = databaseController?.breedList
        
        /// Using recursion to repeat this function until there is a successful call of all 3 api's ensuring a card is created. If the firestroe database cannot be reached. It will exit automatically
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
    
    /**
     Fetches a description of a dog breed using the OpenAI Chat Completions API.

     This function fetches a description of a dog breed using the OpenAI Chat Completions API. It generates a description by providing a dog prompt to the API and receives the generated response. The `completion` closure is called with a result containing either the fetched description or an error.

     - Parameters:
       - completion: A closure to be called when the description fetching is completed. It receives a result containing either the fetched description or an error.
     */
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
    
    
    /**
     Fetches a random dog image URL for a given dog breed.

     This function fetches a random dog image URL for the specified dog breed. It constructs the API URL using the dog breed parameter, makes an API call using the `makeApiCall` function, and retrieves the image URL from the response. The `completion` closure is called with a result containing either the fetched image URL or an error.

     - Parameters:
       - dogBreed: The breed of the dog for which to fetch a random image URL.
       - completion: A closure to be called when the image URL fetching is completed. It receives a result containing either the fetched image URL or an error.
     */
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
    
    
    /**
     Fetches dog statistics for the current dog breed.

     This function fetches dog statistics for the current dog breed. It constructs the API URL using the current dog breed, makes an API call using the `makeApiCall` function, and retrieves the statistics data from the response. The `completion` closure is called with a result containing either the fetched statistics data or an error.

     - Parameters:
       - completion: A closure to be called when the statistics fetching is completed. It receives a result containing either the fetched statistics data or an error.
     */
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
    
    /**
     Retrieves the current dog breed based on the image URL.

     This function retrieves the current dog breed based on the image URL stored in the `imageURL` property. It parses the breed from the URL and performs necessary string manipulations to format the breed name properly. The function returns the current dog breed as a string.

     - Returns: The current dog breed as a string.
     */
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
    
    /**
     Capitalizes the first letter of each word in a given string.

     This function takes a string as input and capitalizes the first letter of each word in the string. It iterates through the string, identifies spaces followed by lowercase letters, and capitalizes the letter immediately after the space. The function returns the modified string with capitalized letters.

     - Parameter string: The input string to be capitalized.

     - Returns: The modified string with the first letter of each word capitalized.
     */
    static func capitalizeFirstLetterAndAfterSpace(_ string: String) -> String {
        var capitalizedString = string.capitalized
        
        for i in capitalizedString.indices {
            if capitalizedString[i] == " " && i < capitalizedString.index(before: capitalizedString.endIndex) {
                let nextIndex = capitalizedString.index(after: i)
                capitalizedString.replaceSubrange(nextIndex...nextIndex, with: String(capitalizedString[nextIndex]).capitalized)
            }
        }
        return capitalizedString
    }
    
    /**
     Chooses an index based on given probability weights.

     This function selects an index from a given array of probability weights. It calculates the total probability by summing up the provided weights and then generates a random number between 0 and the total probability. The function iterates through the probability weights, subtracting each weight from the random number until it becomes non-positive. It returns the index corresponding to the first weight that causes the random number to be non-positive.

     - Parameter probs: An array of probability weights.

     - Returns: The index selected based on the probability weights.
     */
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
    
    /**
     Decodes JSON data into a string representing dog statistics.

     This function decodes the provided JSON data into a string representing dog statistics. It assumes the JSON data conforms to the structure defined by the `[CardDetails]` type. The function extracts the relevant details from the decoded data and formats them into a readable string representation. The resulting string contains different statistics and their corresponding values. If the decoding or extraction process encounters an error, an empty string is returned.

     - Parameter jsonData: The JSON data to be decoded.

     - Returns: A string representation of the extracted dog statistics.
     */
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
                print(text)
                retVal = text
            }
            return retVal
            
        } catch {
            print("Error decoding JSON: \(error)")
        }
        return ""
        
    }
    
    
    /**
     Sets the color based on the rarity level.

     This function takes an `Int32` value representing the rarity level and returns a corresponding `UIColor` object. The function uses a `switch` statement to match the rarity level and assigns a specific color value based on the matching case. The color values are represented using the `#colorLiteral` syntax.

     - Parameter rarity: The rarity level for which the color is to be determined.

     - Returns: A `UIColor` object representing the color associated with the specified rarity level.
     */
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
    
    /**
     Retrieves a list of all dog breeds.

     This function makes an API call to fetch a list of all dog breeds. It uses the "https://dog.ceo/api/breeds/list/all" endpoint to retrieve the data. Upon successful retrieval, the function returns the JSON string representation of the data.

     - Parameter completion: A closure to be called upon completion, containing a `Result` object with either the JSON string or an error.

     - Important: The completion closure is called asynchronously upon completion of the API request.

     - Note: This function uses the `ApiUtil.makeApiCall` helper function internally to make the API request.
     */
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

    /**
     Parses a JSON object to extract breed information.

     This function takes a JSON object in the form of a `[String: Any]` dictionary and extracts breed information from it. The function iterates over the key-value pairs of the JSON object, looking for subarrays. If a subarray is found, the function appends each element of the subarray to a string array, prefixed with the key.

     - Parameter jsonObject: The JSON object to be parsed.

     - Returns: An array of strings representing the extracted breed information.

     - Important: The function assumes that the JSON object follows a specific structure with subarrays containing breed names.

     - Note: The function is commonly used to parse the response from the "getAllBreeds(completion:)" function.
     */
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
    
    /**
     Displays an alert message with continue and cancel options.

     This function creates and presents an alert controller with a given title and message on a specified view controller. The alert controller provides two options: "Continue" and "Cancel". When the user selects either option, the completion closure is called with a boolean parameter indicating the user's choice. If the user selects "Continue", the completion closure is called with `true`, and if the user selects "Cancel", the completion closure is called with `false`.

     - Parameters:
       - title: The title of the alert.
       - message: The message displayed in the alert.
       - viewController: The view controller on which to present the alert.
       - completion: A closure to be called when the user selects an option, containing a boolean parameter indicating the user's choice. `true` represents the selection of "Continue", and `false` represents the selection of "Cancel".

     - Important: The completion closure is called asynchronously when the user selects an option.

     - Note: The function uses the main DispatchQueue to present the alert controller on the main thread.
     */
    static func displayMessageContinueCancel(_ title: String, _ message: String, _ viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false) // User selected "Cancel"
        })
        
        alertController.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            completion(true) // User selected "Continue"
        })
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**
     Displays an alert message with a dismiss option.

     This function creates and presents an alert controller with a given title and message on a specified view controller. The alert controller provides a single option: "Dismiss". When the user selects the "Dismiss" option, the alert is dismissed without any further action.

     - Parameters:
       - title: The title of the alert.
       - message: The message displayed in the alert.
       - viewController: The view controller on which to present the alert.

     - Important: The alert is presented asynchronously on the main thread using the main DispatchQueue.

     - Note: The function does not provide a completion closure as it assumes no action is required after dismissing the alert.
     */
    static func displayMessageDimiss(_ title: String, _ message: String, _ viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

}
