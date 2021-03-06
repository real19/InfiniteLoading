//
//  ViewController.swift
//  codingTest
//
//  Created by Suleman Imdad on 12/2/17.
//  Copyright © 2017 Suleman Imdad. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching , UISearchResultsUpdating , UISearchBarDelegate{
    
    
    @IBOutlet weak var tableView:UITableView!
    
    var lastBookFound:Int = 0
    
    var booksArray:[Book] =  [Book]() {
        didSet{
            if (booksArray.count == 0) {
                
                tableView.separatorStyle = .none
                
            } else {
                
                tableView.separatorStyle = .singleLine
            }
        }
    }
    
    var totalItems:Int = 0
    
    var fetchSize = 40
    
    var isLoading = false
    
    var counter = 0
    
    /// We store all ongoing tasks here to avoid duplicating tasks.
    fileprivate var tasks = [URLSessionTask]()
    
    var searchString:String = ""
    
     // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
       
        tableView.dataSource = self
        
        tableView.prefetchDataSource = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setUpSearchController()
    }
    
     // MARK: - TABLEVIEW DATASOURCE
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksArray.count
    }
    
    // MARK: - TABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ( indexPath.row < booksArray.count - 1 && booksArray.count != 0 ){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookTableViewCell
            
            let book = booksArray[indexPath.row]
            
            cell.bookTitleLabel?.text = "\(indexPath.row + 1 )" + ". " + book.title
            
            cell.bookAuthorLabel?.text = book.author
            
            cell.bookDescriptionLabel?.text = book.description
            
            cell.accessoryType = .disclosureIndicator
            
            if let image =  booksArray[indexPath.row].image {
                cell.bookImageView?.image = image
            } else {
                cell.bookImageView?.image = UIImage(named: "cover")
                self.downloadImage(forItemAtIndex: indexPath.row, completion: { (image) in
                    cell.bookImageView?.image = image
                })
            }
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
            
            let ai = cell.viewWithTag(999) as! UIActivityIndicatorView
          
            ai.startAnimating()
            
            loadBooks()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let book =  self.booksArray[indexPath.row] as Book?{
            
            if let bookViewController = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as!  BookViewController?{
                
                bookViewController.book = book
                
                navigationController?.pushViewController(bookViewController, animated: true)
                
            }
        }
    }
    
    
   
    
    // MARK: - TABLEVIEW PREFETCH
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //print("prefetchRowsAt \(indexPaths)")
        indexPaths.forEach {
            
            self.downloadImage(forItemAtIndex: $0.row, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // print("cancelPrefetchingForRowsAt \(indexPaths)")
        indexPaths.forEach {
         
            self.cancelDownloadingImage(forItemAtIndex: $0.row)
            
        }
    }
    
    // MARK: - MISCELLANEOUS
    
    
    func setUpSearchController(){
        
        let searchController = UISearchController(searchResultsController: nil)
        
        navigationItem.searchController = searchController
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search Books"
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        // Set any properties (in this case, don't hide the nav bar and don't show the emoji keyboard option)
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        
        // Make this class the delegate and present the search
        searchController.searchBar.delegate = self
        
        searchController.searchBar.tintColor = .black
        
        
    }
    
    override func didReceiveMemoryWarning() {
       
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
        
            if let bookViewController = segue.destination as? BookViewController{
                
                if let book = sender as? Book{
                    
                    bookViewController.book = book
                }
                
            }
        }
    }
    
    
     // MARK: - BOOK LOADING
    
    func loadBooks(){
        
        if isLoading == true {
            return
        } else {
            isLoading = true
        }
        
        let queryString = searchString.replacingOccurrences(of: " ", with: "+")
        
        guard let url = URL(string:"https://www.googleapis.com/books/v1/volumes?q=\(String(describing: queryString))&maxResults=\(fetchSize)&startIndex=\(counter)&fields=items(id%2CselfLink%2CvolumeInfo(authors%2CaverageRating%2Cdescription%2CimageLinks%2Ctitle))%2CtotalItems&key=\(YOUR_API_KEY)") else {
            return
        }
        
        print("url is \(url)")
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            do {
                guard let data = data else {
                    return
                }
                
                let json = try JSON(data: data)
                
                if let total = json[Constant.TotalItems].number {
                    
                    self.totalItems = Int(truncating: total)
                    
                }
                
                self.addBooksFrom(json: json)
                
                self.isLoading = false
                
                
            } catch let error as NSError {
               
                print(error.localizedDescription)
            }
        }
        
        task.resume()
        
    }
    
    func addBooksFrom(json:JSON){
        
        var newBooks = [Book]()
        
        if let items = json["items"].array {
            
            for item in items {
                
                if let title = item[Constant.VolumeInfo][Constant.Title].string,
                    
                    let author = item[Constant.VolumeInfo][Constant.Authors][0].string,
                    
                    let selfLink = item[Constant.SelfLink].string,
                    
                    let description = item[Constant.VolumeInfo][Constant.Description].string,
                    
                    let thumbnailURL = item[Constant.VolumeInfo][Constant.ImageLinks][Constant.Thumbnail].string,
                    
                    let smallThumbnailURL = item[Constant.VolumeInfo][Constant.ImageLinks][Constant.SmallThumbnail].string{
                    
                    
                    
                    let book:Book =  Book(title: title, author: author, description: description, selfLink: selfLink, thumbnailURL: thumbnailURL, smallThumbnailURL: smallThumbnailURL, url: nil, image: nil)
                    
                    newBooks.append(book)
                    
                }
            }
            
            if (newBooks.count == 0 ){
                return
            }
            
            var paths = [IndexPath]()
            
            for row in (booksArray.count) ..< (booksArray.count + newBooks.count)
            {
                paths.append(IndexPath(row: row - 1 , section: 0))
            }
            
           // print("new books are found : \(newBooks.count)")
            
            booksArray.append(contentsOf: newBooks)
            
            counter = counter + fetchSize
            
            OperationQueue.main.addOperation {
               
                self.tableView.beginUpdates()
              
                self.tableView.insertRows(at: paths, with: .top)
                
                self.tableView.endUpdates()
            }
            
        }
    }
    
  
    
    // MARK: - IMAGE LOADING
    
    fileprivate func downloadImage(forItemAtIndex index: Int, completion:((UIImage)->())?) {
        
        if (index < booksArray.count) {
            
            var book = booksArray[index]
            
            
            let task = URLSession.shared.dataTask(with: book.url) { (data, response, error) in
                
                if let data = data, let image = UIImage(data: data) {
                 
                    self.booksArray[index].image = image
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    
                    DispatchQueue.main.async {
                    
                        if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                          
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        }
                    }
                }
            }
            task.resume()
          
            tasks.append(task)
        }
    }
    
    fileprivate func cancelDownloadingImage(forItemAtIndex index: Int) {
        
        if (index < booksArray.count) {
            
            let url = booksArray[index].url
            
            guard let taskIndex = tasks.index(where: { $0.originalRequest?.url == url }) else {
                return
            }
            let task = tasks[taskIndex]
          
            task.cancel()
           
            tasks.remove(at: taskIndex)
        }
    }
    
    
      // MARK: - SEARCH CONTROLLER
    
    func updateSearchResults(for searchController: UISearchController) {
        
        
        searchString =  searchController.searchBar.text ?? ""
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        booksArray = [Book]()
        
        counter = 0
        
        totalItems = 0
        
        isLoading = false
        
        tableView.reloadData()
        
        loadBooks()
        
    }
    
}


