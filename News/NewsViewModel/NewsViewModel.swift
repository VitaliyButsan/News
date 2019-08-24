//
//  NewsViewModel.swift
//  News
//
//  Created by Vitaliy on 23/08/2019.
//  Copyright © 2019 Vitaliy. All rights reserved.
//

import Foundation

class NewsVewModel {
    
    var newsStorage: NewsDataWrapper?
    
    func getNews(pagingState: PaginationState, completionHandler: @escaping(NewsDataWrapper?) -> Void) {
        NewsNetManager.getNewsData(pagingState: pagingState) { result in
            guard let news = result else {
                completionHandler(nil)
                return
            }
            
            completionHandler(news)
        }
    }
}
