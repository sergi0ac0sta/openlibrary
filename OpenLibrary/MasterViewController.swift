//
//  MasterViewController.swift
//  OpenLibrary
//
//  Created by Sergio Acosta on 12/03/16.
//  Copyright © 2016 Sergio Acosta. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var books: [Book] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.searchBar.delegate = self
        self.searchBar.hidden = true
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let entityBook = NSEntityDescription.entityForName("Book", inManagedObjectContext: self.managedObjectContext!)
        let request = entityBook?.managedObjectModel.fetchRequestTemplateForName("requestBooks")
        
        do {
            let books = try self.managedObjectContext?.executeFetchRequest(request!)
            for book in books! {
                let name = book.valueForKey("name") as! String
                let authors = (book.valueForKey("authors") as! String).componentsSeparatedByString(",")
                let cover = NSURL(string: book.valueForKey("cover") as! String)
                self.books.append(Book(title: name, authors: authors, cover: cover))
                
                self.tableView.beginUpdates()
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.books.count - 1, inSection: 0)], withRowAnimation: .Automatic)
                self.tableView.endUpdates()
                
            }
        } catch {}
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.searchBar.text = nil
        self.searchBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func insertNewObject(sender: AnyObject) {
        self.searchBar.hidden = false
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            if let _ = self.tableView.indexPathForSelectedRow {
                controller.book = self.books[self.tableView.indexPathForSelectedRow!.row]
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            } else {
                controller.book = self.books[self.books.count - 1]
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let entityBook = NSEntityDescription.entityForName("Book", inManagedObjectContext: self.managedObjectContext!)
            let request = entityBook?.managedObjectModel.fetchRequestFromTemplateWithName("requestBook", substitutionVariables: ["name" : books[indexPath.row].title])
            do {
                let eBooks = try self.managedObjectContext?.executeFetchRequest(request!)
                if eBooks?.count > 0 {
                    for eBook: AnyObject in eBooks! {
                        self.managedObjectContext?.deleteObject(eBook as! NSManagedObject)
                    }
                    try self.managedObjectContext?.save()
                }
            } catch {}
            
            self.tableView.beginUpdates()
            books.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.endUpdates()
            
            /*
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
            */
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        cell.textLabel!.text = self.books[indexPath.row].title
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    @IBAction func backgroundTap(sender: UITableView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
    }
    
    func parse(data: NSDictionary) -> (title: String, authors: [String]?, cover: NSURL?){
        var bookTitle = ""
        var bookAuthors: [String] = []
        var bookCover: NSURL? = nil
        
        let elements = data["ISBN:" + self.searchBar.text!] as! NSDictionary
        if let t = elements["title"] {
            bookTitle = t as! String
        }
        if let auth = elements["authors"] {
            for a in auth as! NSArray {
                if let n = a["name"] {
                    bookAuthors.append(n as! String)
                }
            }
        }
        if let c = elements["cover"] {
            if let m = c["medium"] {
                bookCover = NSURL(string: m as! String)
            }
        }
        return (bookTitle, bookAuthors, bookCover)
    }
    
    func search() {
        let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + searchBar.text!)
        let session = NSURLSession.sharedSession()
        let data = { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
                        if json.count > 0 {
                            let bookData = self.parse(json)
                            let book = Book(title: bookData.title, authors: bookData.authors, cover: bookData.cover)
                            
                            if !self.books.contains({$0.title == book.title}) {
                                self.books.append(Book(title: bookData.title, authors: bookData.authors, cover: bookData.cover))
                                
                                let entityBook = NSEntityDescription.entityForName("Book", inManagedObjectContext: self.managedObjectContext!)
                                let request = entityBook?.managedObjectModel.fetchRequestFromTemplateWithName("requestBook", substitutionVariables: ["name" : book.title])
                                
                                do {
                                    let eBook = try self.managedObjectContext?.executeFetchRequest(request!)
                                    if eBook?.count == 0 {
                                        let newBook = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext!)
                                        newBook.setValue(book.title, forKey: "name")
                                        newBook.setValue(book.authors.joinWithSeparator(", "), forKey: "authors")
                                        
                                        if book.cover != nil {
                                            newBook.setValue(book.cover!.absoluteString, forKey: "cover")
                                        } else {
                                            newBook.setValue("", forKey: "cover")
                                        }
                                        do {
                                            try self.managedObjectContext?.save()
                                        } catch {}

                                    }
                                } catch {}
                                dispatch_sync(dispatch_get_main_queue()) {
                                    self.tableView.beginUpdates()
                                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.books.count - 1, inSection: 0)], withRowAnimation: .Automatic)
                                    self.tableView.endUpdates()
                                    self.performSegueWithIdentifier("showDetail", sender:self)
                                }
                            }
                        } else {
                            dispatch_sync(dispatch_get_main_queue()) {
                                self.sendAlert("Resultados de búsqueda", message: "Tu búsqueda no arrojó resultados, por favor intenta otra.")
                            }
                        }
                    } catch _ {}
                } else {
                    dispatch_sync(dispatch_get_main_queue()) {
                        self.sendAlert("Error de conexión", message: "Verifica tu conexión a internet.")
                    }
                }
            } else {
                dispatch_sync(dispatch_get_main_queue()) {
                    self.sendAlert("Error de conexión", message: "Verifica tu conexión a internet.")
                }
            }
        }
        let dt = session.dataTaskWithURL(url!, completionHandler: data)
        dt.resume()
    }

    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Cancel) { _ in
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

