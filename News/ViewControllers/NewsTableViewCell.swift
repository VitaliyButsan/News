//
//  NewsTableViewCell.swift
//  News
//
//  Created by Vitaliy on 23/08/2019.
//  Copyright © 2019 Vitaliy. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleDescriptionLabel: UILabel!
    @IBOutlet weak var articleAuthorLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var articleSourceLabel: UILabel!
    
    
    func updateCell(with articleInfo: Article, forRowIndex cellIndex: Int) {
        
        DispatchQueue.main.async {
            self.spinner.startAnimating()
            self.articleTitleLabel.text = articleInfo.title
            self.articleSourceLabel.text = articleInfo.source.name
            self.articleDescriptionLabel.text = articleInfo.description
            let authorLabelPlaceholder: String = self.articleAuthorLabel.text ?? ""
            self.articleAuthorLabel.text = authorLabelPlaceholder + (articleInfo.author ?? "")
            
            self.articleImageView.image = nil
            guard let imageUrl = articleInfo.urlToImage else { return }
            guard let url = URL(string: imageUrl) else { return }
            
            DispatchQueue.global(qos: .utility).async {
                if let imageData = try? Data(contentsOf: url) {
                    
                    DispatchQueue.main.async {
                        if self.tag == cellIndex {
                            self.articleImageView.image = UIImage(data: imageData)
                        }
                        
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }
}
