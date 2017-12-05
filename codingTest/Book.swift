//
//  Book.swift
//  codingTest
//
//  Created by Suleman Imdad on 12/3/17.
//  Copyright © 2017 Suleman Imdad. All rights reserved.
//

import Foundation
import UIKit


struct Book {
    
    var title:String
    var author:String
    var description:String
    var selfLink:String
    var thumbnailURL:String
    var smallThumbnailURL:String
    lazy var url: URL = {
        return URL(string: self.smallThumbnailURL)!
    }()
    var image: UIImage?
}
