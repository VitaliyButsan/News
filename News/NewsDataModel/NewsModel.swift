//
//  NewsModel.swift
//  News
//
//  Created by Vitaliy on 23/08/2019.
//  Copyright © 2019 Vitaliy. All rights reserved.
//

import Foundation

struct NewsDataWrapper: Decodable {
    var articles: [Article]
    let status: String
}

struct Article: Decodable {
    let source: SourceDescription
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
}

struct SourceDescription: Decodable {
    let name: String?
}

enum PaginationState {
    case YES
    case NO
}
