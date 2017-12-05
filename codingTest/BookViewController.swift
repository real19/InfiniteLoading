//
//  BookViewController.swift
//  codingTest
//
//  Created by Suleman Imdad on 12/4/17.
//  Copyright © 2017 Suleman Imdad. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
    
    var book:Book?
    
    @IBOutlet var bookImageView: UIImageView?
    @IBOutlet var bookTitleLabel: UILabel?
    @IBOutlet var bookAuthorLabel: UILabel?
    @IBOutlet var bookDescriptionLabel: UILabel?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        
        navigationItem.largeTitleDisplayMode = .never
        
       
        
        guard let book = book else {
            return
        }
        
        if let url = URL(string:book.thumbnailURL!){
            
            downloadImage(url: url)
        }
        
        bookTitleLabel?.text = book.title
        
         navigationItem.title =  book.title
        
        bookAuthorLabel?.text = book.author

        bookDescriptionLabel?.text = book.description
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func downloadImage(url:URL){
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {[weak self] in
                    self?.bookImageView?.image = image
                }
            }
        }
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
