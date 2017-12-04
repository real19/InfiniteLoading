//
//  BookTableViewCell.swift
//  codingTest
//
//  Created by Suleman Imdad on 12/3/17.
//  Copyright © 2017 Suleman Imdad. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet var bookImageView: UIImageView?
    @IBOutlet var bookTitle: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
