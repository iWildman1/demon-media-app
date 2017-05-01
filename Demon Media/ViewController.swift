//
//  ViewController.swift
//  Demon Media
//
//  Created by Daniel Wildman on 27/04/2017.
//  Copyright © 2017 Daniel Wildman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension String {
    
    var html2AttributedString: NSMutableAttributedString? {
        do {
            return try NSMutableAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    typealias JSONData = [String : AnyObject]
    var postsArray : Array<Post> = []
    private let refreshControl = UIRefreshControl()
    private var currentOffset = 0

    @IBOutlet weak var TableView: UITableView!
    
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "pushRightSegue" {
                if let singleViewController = segue.destination as? SingleViewController {
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.TableView.estimatedRowHeight = 300
        self.TableView.rowHeight = UITableViewAutomaticDimension
        self.TableView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: #selector(ViewController.refreshData(sender:)), for: .valueChanged)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.callAlamofire(url: DEMON_POSTS_URL + "?per_page=\(NUM_OF_ITEMS_FROM_SERVER)")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell"/*Identifier*/, for: indexPath)
        
        let postTitleLabel = cell.viewWithTag(1) as! UILabel!
        let postExcerptTextField = cell.viewWithTag(2) as! UITextView
        let postBannerImage = cell.viewWithTag(3) as! UIImageView
        let postDateLabel = cell.viewWithTag(4) as! UILabel!
        let postCategoryLabel = cell.viewWithTag(5) as! UILabel!
        
        postTitleLabel?.text = postsArray[indexPath.row].title()
        postExcerptTextField.text = postsArray[indexPath.row].excerpt()
        postBannerImage.image = postsArray[indexPath.row].image()
        postDateLabel?.text = postsArray[indexPath.row].datePosted()
        postCategoryLabel?.text = postsArray[indexPath.row].category()
        
        return cell
    }
    
    func refreshData(sender: UIRefreshControl) {
        
        self.callAlamofire(url: DEMON_POSTS_URL + "?per_page=\(NUM_OF_ITEMS_FROM_SERVER)")
        currentOffset = 0
        postsArray = []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = postsArray.count - 1
        
        if indexPath.row == lastElement {
            currentOffset = currentOffset + 5
            self.callAlamofire(url: DEMON_POSTS_URL + "?per_page=\(NUM_OF_ITEMS_FROM_SERVER)&offset=\(currentOffset)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushLeftSegue" {
            if let singleViewController = segue.destination as? SingleViewController {
                let indexPath = TableView.indexPathForSelectedRow?.row
                
                singleViewController.passedPost = postsArray[indexPath!]
            }
        }
        
    }
    
    func callAlamofire(url: String) {
        Alamofire.request(url).responseJSON { response in
            self.parseData(data: response.data!)
        }
    }
    
    func parseData(data : Data) {
        
        let json = JSON(data: data);
        
        for i in 0..<json.count {
            let title = json[i]["title"]["rendered"].string
            let imageURL = json[i]["better_featured_image"]["media_details"]["sizes"]["medium"]["source_url"].string
            let mainImageURL = URL(string: imageURL!)
            let imageData = NSData(contentsOf: mainImageURL!)
            let image = UIImage(data: imageData! as Data)
            let excerpt = json[i]["excerpt"]["rendered"].string
            let content = json[i]["content"]["rendered"].string
            let datePosted = json[i]["date"].string
            let category = json[i]["categories"][0].int
            let author = json[i]["author"].int
            
            let formattedTitle = title?.html2String
            let formattedExcerpt = excerpt?.html2String
            var formattedContent = content?.html2AttributedString!
            let unformattedContent = content?.html2String
            let contentLength = unformattedContent?.characters.count
            formattedContent?.addAttribute(NSFontAttributeName, value: UIFont(name: "FiraSans-UltraLight", size: 16.0), range: NSRange(location: 0, length: contentLength!))
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date = dateFormatter.date(from:datePosted!)!
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            let formattedDate = calendar.date(from:components)
            let formattedCategory = "\(category!)"
            let formattedAuthor = "\(author!)"
            var categoryName = ""
            
            Alamofire.request(DEMON_CATEGORY_META_URL + formattedCategory).responseJSON {
                response in
                let json = JSON(response.data!)
                
                let category_name = json["name"].string
                
                categoryName = category_name!
                
                let newPost = Post(title: formattedTitle!, image: image!, excerpt: formattedExcerpt!, content: formattedContent!, datePosted: formattedDate!, category: categoryName, author: formattedAuthor)
                
                self.postsArray.append(newPost)
            
                let loadingView = self.view.viewWithTag(6)
                loadingView?.removeFromSuperview()
                
                self.TableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        
        }
    
    }
}

