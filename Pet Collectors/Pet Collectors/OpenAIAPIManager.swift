//
//  OpenAIAPIManager.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 30/5/2023.
//

import Foundation

class OpenAIAPIManager {
    static let shared = OpenAIAPIManager()

    private let API_KEY = "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"
    private let apiUrl = "https://api.openai.com/v1/engines/davinci-codex/completions"

    private init() {}

    func sendCompletionRequest(parameters: [String: Any], completion: @escaping (Result<OpenAICompletionResponse, Error>) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid API URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(API_KEY)", forHTTPHeaderField: "Authorization")

        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data returned", code: -1, userInfo: nil)))
                return
            }

            do {
                let response = try JSONDecoder().decode(OpenAICompletionResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

struct OpenAICompletionResponse: Decodable {
    let choices: [OpenAICompletionChoice]
}

struct OpenAICompletionChoice: Decodable {
    let text: String
}

