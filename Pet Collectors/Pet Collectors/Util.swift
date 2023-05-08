//
//  Util.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/5/2023.
//

import Foundation

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

    
}

