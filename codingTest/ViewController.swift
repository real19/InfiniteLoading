//
//  ViewController.swift
//  codingTest
//
//  Created by Suleman Imdad on 12/2/17.
//  Copyright © 2017 Suleman Imdad. All rights reserved.
//

import UIKit

struct Key {
    
    static let TotalItems = "totalItems"
    static let SelfLink = "selfLink"
    static let VolumeInfo = "volumeInfo"
    static let Title = "title"
    static let Authors = "authors"
    static let ImageLinks = "imageLinks"
    static let Thumbnail = "thumbnail"
    static let SmallThumbnail = "smallThumbnail"
    static let Description = "description"
    
}



let YOUR_API_KEY = "AIzaSyAidSLvx-64rN90VBRfRGShhF5FsML68gg"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    @IBOutlet weak var tableView:UITableView!
    
    var lastBookFound:Int = 0
    
    var booksArray:[Book] =  [Book]() {
        didSet{
           
        }
    }
    
    var totalItems:Int = 0
    
    var fetchSize = 40
    
    var isLoading = false
    
    
    /// We store all ongoing tasks here to avoid duplicating tasks.
    fileprivate var tasks = [URLSessionTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        loadBooks()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row < self.booksArray.count - 1){
            
        } else {
            if (booksArray.count != 0){
                loadBooks()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ( indexPath.row < booksArray.count - 1 && booksArray.count != 0 ){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookTableViewCell
            
            let book = booksArray[indexPath.row]
            
            cell.bookTitle?.text = book.title
            cell.bookAuthor?.text = book.author
            cell.bookDescription?.text = book.description
            
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
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }


    func loadBooks(){
        
        if isLoading == true {
            return
        } else {
            isLoading = true
        }
        
        
        
        lastBookFound = booksArray.count
        
        guard let url = URL(string:"https://www.googleapis.com/books/v1/volumes?q=Rashad+khalifa&maxResults=\(fetchSize)&startIndex=\(lastBookFound)&fields=items(id%2CselfLink%2CvolumeInfo(authors%2CaverageRating%2Cdescription%2CimageLinks%2Ctitle))%2CtotalItems&key=\(YOUR_API_KEY)") else {
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
            
            do {
                guard let data = data else {
                    return
                }
                
                let json = try JSON(data: data)
                
                if let total = json[Key.TotalItems].number {
                    
                    self?.totalItems = Int(truncating: total)
                    
                    print("Total items are \(String(describing: self?.totalItems))")
                }
                
                self?.addBooksFrom(json: json)
                
               self?.isLoading = false
               
    
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    task.resume()

}
    
    func loadMorePaths()->[IndexPath]{
        var paths = [IndexPath]()
        for row in (booksArray.count) ..< (booksArray.count + fetchSize)
        {
            paths.append(IndexPath(row: row - 1 , section: 0))
        }
        return paths
    }


func addBooksFrom(json:JSON){
    
    var newBooks = [Book]()
    
    if let items = json["items"].array {
        
        for item in items {
            
            if let title = item[Key.VolumeInfo][Key.Title].string,
                let author = item[Key.VolumeInfo][Key.Authors][0].string,
                let selfLink = item[Key.SelfLink].string,
                let description = item[Key.VolumeInfo][Key.Description].string,
                let thumbnailURL = item[Key.VolumeInfo][Key.Title].string,
                let smallThumbnailURL = item[Key.VolumeInfo][Key.ImageLinks][Key.SmallThumbnail].string {
                
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
        
        booksArray.append(contentsOf: newBooks)
        
        OperationQueue.main.addOperation {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: paths, with: .none)
            self.tableView.endUpdates()
        }
        
    }
}

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

// MARK: - Image downloading

    fileprivate func downloadImage(forItemAtIndex index: Int, completion:((UIImage)->())?) {
    
    if (index < booksArray.count) {
        
        let book = booksArray[index]
        
        guard let url = URL(string: book.smallThumbnailURL) else {
            return
        }
        
        guard tasks.index(where: { $0.originalRequest?.url == url }) == nil else {
            // We're already downloading the image.
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
       
                if let data = data, let image = UIImage(data: data) {
                    self?.booksArray[index].image = image
                    let indexPath = IndexPath(row: index, section: 0)
                DispatchQueue.main.async {
                    if self?.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
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
}


