//
//  Book.swift
//  OpenLibrary
//
//  Created by Sergio Acosta on 12/03/16.
//  Copyright © 2016 Sergio Acosta. All rights reserved.
//

import Foundation

class Book {
    var isbn: String = ""
    var title: String = ""
    var authors: [String] = []
    var cover: NSURL? = nil
    
    init() {}
    
    convenience init(isbn: String, title: String) {
        self.init()
        self.isbn = isbn
        self.title = title
    }
    
    convenience init(isbn: String, title: String, authors: [String]?, cover: NSURL?){
        self.init(isbn: isbn, title: title)
        if let a = authors{
            self.authors += a
        }
        self.cover = cover
    }
    
    convenience init(isbn: String, title: String, authors: [String], cover: String){
        self.init(isbn: isbn, title: title)
        self.authors += authors
        self.cover = NSURL(string: cover)
    }
    
    convenience init(isbn: String, title: String, authors: [String]){
        self.init(isbn: isbn, title: title)
        self.authors += authors
    }
    
    convenience init(isbn: String, title: String, cover: String){
        self.init(isbn: isbn, title: title)
        self.cover = NSURL(string: cover)
    }
    
    
    func addAuthor(author: String) {
        authors.append(author)
    }
    
    func addAuthor(authors: [String]) {
        self.authors += authors
    }
    
    func addCover(url: String) {
        self.cover = NSURL(string: url)
    }
    
}
