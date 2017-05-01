//
//  SingleViewController.swift
//  Demon Media
//
//  Created by Daniel Wildman on 30/04/2017.
//  Copyright © 2017 Daniel Wildman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SingleViewController: UIViewController {
    
    var passedPost: Post?
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    @IBOutlet weak var postAuthor: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postContent: UITextView!
    var authorName : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(DEMON_AUTHOR_META_URL + "\(passedPost!.author())").responseJSON {
            response in
            
            let data = response.data!
            let json = JSON(data);
            
            self.authorName = json["name"].string!
            
            self.bannerImage.image = self.passedPost!.image()
            self.postTitle.text = self.passedPost!.title()
            self.postCategory.text = self.passedPost!.category()
            self.postAuthor.text = self.authorName
            self.postDate.text = self.passedPost!.datePosted()
            self.postContent.attributedText = self.passedPost!.content()
            
        }
    }

}
