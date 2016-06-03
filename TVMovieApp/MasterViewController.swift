//
//  MasterViewController.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 13/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    
    var managedObjectContext: NSManagedObjectContext? = nil

    var searchController:UISearchController!// = UISearchController(searchResultsController: nil)!
    
    var client: ShowtimeClient!
    
    var showingErrorMessage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = ShowtimeClient(context: managedObjectContext!)
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

       // let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
       // self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Setup SearchController
        
        // Create SearchViewController
        let searchViewController = storyboard!.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        searchViewController.delegate = self
        searchController = UISearchController(searchResultsController: searchViewController)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search TV Series or Movie"
        
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.estimatedRowHeight = 84.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        // Schedule notifications.
        let notificationSystem = NotificationSystem(films: fetchedResultsController.fetchedObjects as! [Film], delegate: self)
        notificationSystem.scheduleNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        
        let film = Show(entity: entity, insertIntoManagedObjectContext: context)
        
        film.name = "My Film"
        film.genre = ""
        film.overview = ""
        film.identifier = "id"
        film.rating = NSNumber(double: 7.0)
        film.releaseDate = NSDate()
        film.posterURL = ""
      
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            print(error)
            abort()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Film
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.film = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FilmCell
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Film
        self.configureCell(cell, withObject: object)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
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
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.name

    }
    
    func configureCell(cell: FilmCell, withObject object: Film) {
        cell.titleTextLabel.text = object.name
        cell.posterImageView.af_setImageWithURL(NSURL(string: object.posterURL)!)
        
        if let show = object as? Show {
            if let releaseDate = show.nextEpisodeAirDate {
                cell.subtitleTextLabel.text = releaseDate.stringFormat ?? ""
            } else {
                cell.subtitleTextLabel.text = ""
            }
        } else {
            if let releaseDate = object.releaseDate {
                cell.subtitleTextLabel.text = releaseDate.stringFormat ?? ""
            } else {
                cell.subtitleTextLabel.text = ""
            }
        }
      
        

    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Film", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "sectionTitle", ascending: false)
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor, nameSortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "sectionTitle", cacheName: nil)
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
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)! as! FilmCell, withObject: anObject as! Film)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}

extension MasterViewController: UISearchResultsUpdating {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text where searchText.length > 2 {
            // Send Request 
            client.queryMovie(searchText, completition: { (results, error) in
                
                // Set the ViewController Display to SearchController
                if let results = results {
                    let searchViewController = searchController.searchResultsController as! SearchViewController
                    searchViewController.searchResults = results
                    searchViewController.tableView.reloadData()
                } else if let error = error {
                    print(error)
                    
                    let errorDescription: String
                    
                    switch error {
                    case .InvalidData:
                        errorDescription = "Received invalid data from server"
                    case .Response(let systemError):
                        errorDescription = systemError.localizedDescription
                    case .ServerError:
                        errorDescription = "Server error occured"
                    }
                    
                    // Show error message
                    if !self.showingErrorMessage {
                        self.showingErrorMessage = true
                        
                        let alertController = UIAlertController(title: "Search Results Error", message: errorDescription, preferredStyle: .Alert)
                        let okayAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                            self.showingErrorMessage = false
                        })
                        
                        alertController.addAction(okayAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
        }
    }
}

extension MasterViewController: SearchResultsViewControllerDelegate {
    
    func insertShow(show: Show) {
        
        // Move seasons into main context
        for season in show.showSeasons {
            // Move Episodes into main context
            for episode in season.seasonEpisodes {
                self.managedObjectContext?.insertObject(episode)
            }
            
            self.managedObjectContext?.insertObject(season)
        }
        
        
    }
    
    
    func didSelectSearchResult(searchResult: SearchResult) {
        
        // Hide SearchController
        searchController.dismissViewControllerAnimated(true, completion: nil)
        searchController.searchBar.text = nil
        
        // Get SearchResult Detail
        client.getFilmDetail(searchResult) { (film, error) in
            if  let film = film   {
                film.status = NSNumber(integer: 0)

                do {
                    try self.managedObjectContext?.save()
                } catch {
                    print("Save Error \(error)")
                    self.managedObjectContext?.deleteObject(film)
                    
                }
            } else if let error = error {
                
                print(error)

                // Create ErrorAlertController
                let errorAlertController = UIAlertController(title: "Error", message: "Error getting details for \(searchResult.name)", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                errorAlertController.addAction(okAction)
                
                // Show Error
                self.presentViewController(errorAlertController, animated: true, completion: nil)
                
            
            }
        }
    }
}

extension MasterViewController: NotificationSystemDelegate {
    func failedToScheduleNotification() {
        let alertController = UIAlertController(title: "Permission error", message: "Showtime doesn't have permission to schedule notifications.\n\nPlease configure your device's settings to give us permission.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
        return
    }
}
