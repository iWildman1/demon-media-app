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


//String extension to add html2AttributedString and html2String methods to be called on any String
extension String {
    
    //Parse HTML into NSMutableAttributedString. Necessary as Post content will contain HTML tags
    var html2AttributedString: NSMutableAttributedString? {
        do {
            return try NSMutableAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }
    
    //Return an NSAttributedString as a String. Removes all formatting from the HTML content
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
    
    //Allows for Unwind segue from SingleViewController to ViewController
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
        
        //Setup self-adjusting table cells
        self.TableView.estimatedRowHeight = 300
        self.TableView.rowHeight = UITableViewAutomaticDimension
        self.TableView.addSubview(refreshControl)
        
        //Apply refresh control to the Table View
        refreshControl.addTarget(self, action: #selector(ViewController.refreshData(sender:)), for: .valueChanged)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        
        //Call Alamofire and begin the request for data from the Demon Media API
        self.callAlamofire(url: DEMON_POSTS_URL + "?per_page=\(NUM_OF_ITEMS_FROM_SERVER)")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell"/*Identifier*/, for: indexPath)
        
        //Setup code outlets for the cell children
        let postTitleLabel = cell.viewWithTag(1) as! UILabel!
        let postExcerptTextField = cell.viewWithTag(2) as! UITextView
        let postBannerImage = cell.viewWithTag(3) as! UIImageView
        let postDateLabel = cell.viewWithTag(4) as! UILabel!
        let postCategoryLabel = cell.viewWithTag(5) as! UILabel!
        
        //Assign the different post elements to the data contained in that index of the post array
        postTitleLabel?.text = postsArray[indexPath.row].title()
        postExcerptTextField.text = postsArray[indexPath.row].excerpt()
        postBannerImage.image = postsArray[indexPath.row].image()
        postDateLabel?.text = postsArray[indexPath.row].datePosted()
        postCategoryLabel?.text = postsArray[indexPath.row].category()
        
        return cell
    }
    
    func refreshData(sender: UIRefreshControl) {
        
        //Re-call Alamofire from the refresh control. Will reset the posts array and offset
        self.callAlamofire(url: DEMON_POSTS_URL + "?per_page=\(NUM_OF_ITEMS_FROM_SERVER)")
        currentOffset = 0
        postsArray = []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Initalise the TableView with the correct amount of cells, based on the Post array
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Prevents cell selection from persisting
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //Checks to see whether scroll has reached the near the bottom of the posts. If so, load 5 more and refresh the table.
        let lastElement = postsArray.count - 1
        
        if indexPath.row == lastElement {
            currentOffset = currentOffset + 5
            self.callAlamofire(url: DEMON_POSTS_URL + "?per_page=\(NUM_OF_ITEMS_FROM_SERVER)&offset=\(currentOffset)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Only 1 section is necessary
        return 1
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Uses a custom segue to control how the views change
        if segue.identifier == "pushLeftSegue" {
            if let singleViewController = segue.destination as? SingleViewController {
                let indexPath = TableView.indexPathForSelectedRow?.row
                
                singleViewController.passedPost = postsArray[indexPath!]
            }
        }
        
    }
    
    func callAlamofire(url: String) {
        
        //A simplified way to call Alamofire. The response data will be passed to the parsing function by default
        Alamofire.request(url).responseJSON { response in
            self.parseData(data: response.data!)
        }
    }
    
    func parseData(data : Data) {
        //Parse data returned from Alamofire
        
        //Parse as JSON
        let json = JSON(data: data);
        
        for i in 0..<json.count {
            
            //Begin grabbing data and assigning to constants/variables
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
            
            
            //Perform any necessary formatting on the data pulled from the JSON
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
            
            //Send another web request to get the category name
            Alamofire.request(DEMON_CATEGORY_META_URL + formattedCategory).responseJSON {
                response in
                let json = JSON(response.data!)
                
                let category_name = json["name"].string
                
                categoryName = category_name!
                
                //Create a new instance of the Post class with the parsed data
                let newPost = Post(title: formattedTitle!, image: image!, excerpt: formattedExcerpt!, content: formattedContent!, datePosted: formattedDate!, category: categoryName, author: formattedAuthor)
                
                //Add the new post object to the postsArray array
                self.postsArray.append(newPost)
            
                //destroy the loading view if it exists
                let loadingView = self.view.viewWithTag(6)
                loadingView?.removeFromSuperview()
                
                //Reload the tabledata and end any ongoing refresh
                self.TableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        
        }
    
    }
}

