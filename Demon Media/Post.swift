//
//  Post.swift
//  Demon Media
//
//  Created by Daniel Wildman on 01/05/2017.
//  Copyright © 2017 Daniel Wildman. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class Post {
    
    private let _title : String!
    private let _image : UIImage!
    private let _excerpt : String!
    private let _content : NSMutableAttributedString!
    private let _datePosted : Date!
    private let _category : String!
    private let _author : String!
    
    func title() -> String {
        return _title
    }
    
    func image() -> UIImage {
        return _image
    }
    
    func excerpt() -> String {
        return _excerpt
    }
    
    func content() -> NSAttributedString {
        return _content
    }
    
    func datePosted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let newDate = dateFormatter.string(from: _datePosted)
        
        return newDate
    }
    
    
    func category() -> String {
        return _category
    }
    
    func author() -> String {
        return _author
    }
    
    
    init(title : String, image : UIImage, excerpt: String, content : NSMutableAttributedString, datePosted : Date, category: String, author: String) {
        _title = title
        _image = image
        _excerpt = excerpt
        _content = content
        _datePosted = datePosted
        _category = category
        _author = author
    }
}
