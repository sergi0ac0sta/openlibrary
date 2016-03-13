//
//  DetailViewController.swift
//  OpenLibrary
//
//  Created by Sergio Acosta on 12/03/16.
//  Copyright © 2016 Sergio Acosta. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var book = Book()
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthors: UILabel!
    @IBOutlet weak var lblNoImage: UILabel!
    @IBOutlet weak var imgCover: UIImageView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = book.title
        lblAuthors.text = book.authors.joinWithSeparator(", ")
        
        if let cover = book.cover {
            if let data = NSData(contentsOfURL: cover) {
                self.lblNoImage.hidden = true
                self.imgCover.contentMode = .ScaleAspectFit
                self.imgCover.image = UIImage(data: data)
            } else {
                self.lblNoImage.hidden = false
            }
        } else {
            self.lblNoImage.hidden = false
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

