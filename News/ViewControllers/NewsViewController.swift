//
//  ViewController.swift
//  News
//
//  Created by Vitaliy on 23/08/2019.
//  Copyright © 2019 Vitaliy. All rights reserved.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var newsViewModel = NewsVewModel()
    var spinner = UIActivityIndicatorView()
    var isPagination = false
    let searchController = UISearchController(searchResultsController: nil)
    var filteredNews = [Article]()
    
    private struct Constants {
        static let cellId: String = "NewsCell"
    }
    
    let newsRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateNews), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.refreshControl = newsRefreshControl
        updateNews()
        self.createSpinner()
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @objc func updateNews() {
        
        newsViewModel.getNews(pagingState: .NO) { result in
            if let news = result {
                DispatchQueue.main.async {
                    self.newsViewModel.newsStorage = news
                    self.tableView.reloadData()
                    self.newsRefreshControl.endRefreshing()
                }
            } else {
                // setup Alert
            }
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // Pagination spinner
    func createSpinner() {
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60)
        spinner.color = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
        tableView.tableFooterView = spinner
    }
    
    // Pagination cells
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (tableView.contentOffset.y + tableView.frame.size.height) > tableView.contentSize.height, scrollView.isDragging, self.newsViewModel.newsStorage != nil, !self.isPagination {
            
            self.isPagination = true
            spinner.startAnimating()
            
            newsViewModel.getNews(pagingState: .YES) { result in
                
                self.isPagination = false
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
                
                if let news = result {
                    DispatchQueue.main.async {
                        if self.newsViewModel.newsStorage?.articles != nil {
                            self.newsViewModel.newsStorage?.articles.append(contentsOf: news.articles)
                        } else {
                            self.newsViewModel.newsStorage = news
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let article = newsViewModel.newsStorage?.articles[indexPath.row] else { return }
        guard let url = article.url else { return }
        showLinkWithSafari(link: url)
    }
    
    func showLinkWithSafari(link: String) {
        
        let safariVC = SFSafariViewController(url: URL(string: link)!)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
}

// MARK: - SFSafariViewControllerDelegate

extension NewsViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension NewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredNews.count
        }
        return newsViewModel.newsStorage?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as! NewsTableViewCell
        cell.selectionStyle = .none
        
        if var article = newsViewModel.newsStorage?.articles[indexPath.row] {
            if isFiltering() {
                article = self.filteredNews[indexPath.row]
                cell.updateCell(with: article, forRowIndex: indexPath.row)
                
            } else {
                cell.updateCell(with: article, forRowIndex: indexPath.row)
            }
        }
        
        cell.tag = indexPath.row
        return cell
    }
}

// MARK: - UISearchResultsUpdating Delegate

extension NewsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        self.filteredNews = (self.newsViewModel.newsStorage?.articles.filter({( article : Article) -> Bool in
            return (article.title?.lowercased().contains(searchText.lowercased()))!
        }))!
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

