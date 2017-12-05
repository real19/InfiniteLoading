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
        
        guard let book = book else {
            return
        }
        
        bookImageView?.image = book.image
        
        bookTitleLabel?.text = book.title
        
        bookAuthorLabel?.text = book.author

        bookDescriptionLabel?.text = book.description
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
