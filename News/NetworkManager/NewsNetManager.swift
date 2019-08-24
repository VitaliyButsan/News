//
//  NewsNetManager.swift
//  News
//
//  Created by Vitaliy on 23/08/2019.
//  Copyright © 2019 Vitaliy. All rights reserved.
//

import Foundation

class NewsNetManager {
    
    var newsStorage: [NewsDataWrapper] = []
    static var pageNumber = 1
    
    private struct Constants {
        static let newsEndPoint: String = "https://newsapi.org/v2/top-headlines"
    }
    
    static func getNewsData(pagingState: PaginationState, completionHandler: @escaping(NewsDataWrapper?) -> Void) {
        
        if pagingState == .NO {
            self.pageNumber = 1
        }
        
        var components = URLComponents(string: Constants.newsEndPoint)
        components?.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "apiKey", value: "85f8371c33224d178a3cef6e8ef16f49"),
            URLQueryItem(name: "page", value: String(self.pageNumber))
        ]
        
        guard let url = components?.url else { return }
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else { return }
        
            do {
                let jsonData = try JSONDecoder().decode(NewsDataWrapper.self, from: data)
                self.pageNumber += 1
                completionHandler(jsonData)
            } catch {
                completionHandler(nil)
            }

        }.resume()
    }
}
