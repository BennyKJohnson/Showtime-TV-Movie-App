//
//  DetailViewController.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 27/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import UIKit

enum DetailCellType {
    case DescriptionCell(title: String, body: String)
    case HeaderCell
    case InformationCell
    
}

class DetailViewController: UITableViewController {

    var cells: [DetailCellType] = []
    
    var film: Film! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let film = self.film{
            title = film.name
            
            cells = []
            cells.append(DetailCellType.HeaderCell)
            cells.append(DetailCellType.DescriptionCell(title: "Description", body: film.overview))
            cells.append(DetailCellType.InformationCell)
            
            if let show = film as? Show {
                
                // Setup Cells specific to TV Show
                print("Showing Detail for TV Show: " + show.name)
                for season in show.showSeasons {
                    print("Season \(season.number)")
                    for episode in season.seasonEpisodes {
                        print("\tEpisode \(episode.episodeNumber!)")
                    }
                }
                
                
            } else if let movie = film as? Movie {
                
                // Setup Cells specific to Movie
                print("Showing Detail for Movie: " + movie.name)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
     
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellType = cells[indexPath.row]
        switch cellType {
        case .HeaderCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FilmCell
            cell.titleTextLabel.text = film.name
            cell.posterImageView.af_setImageWithURL(NSURL(string: film.posterURL)!)
            cell.subtitleTextLabel.text = ""
        
            return cell
        case .DescriptionCell(let title, let body):
            
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
            cell.titleTextLabel.text = title
            cell.descriptionTextView.content = body
            cell.descriptionTextView.delegate = self
        
            return cell
        case .InformationCell:
            
            let cell = tableView.dequeueReusableCellWithIdentifier("InformationCell", forIndexPath: indexPath) as! InformationTableViewCell
            if let show = film as? Show {
                cell.textLabel1.text = "Network"
                cell.detailTextLabel1.text = show.network

            } else if let movie = film as? Movie {
                cell.textLabel1.text = "Rating"
                cell.detailTextLabel1.text = "\(movie.rating)" + " / 10"
            }
            
            cell.textLabel2.text = "Genre"
            cell.detailTextLabel2.text = film.genre
            
            cell.textLabel3.text = "Run Time"
            if let runtime = film.runtime {
                cell.detailTextLabel3.text = "\(runtime)" + " min"
            } else {
                cell.detailTextLabel3.text = "Unknown"
            }
            
            if let show = film as? Show {
                cell.rating.text = "Rating"
                let showRating = String(show.rating)
                    cell.detailRating.text = "\(showRating)" + " / 10"
                if showRating == "" {
                    cell.detailRating.text = "Unknown"
                }
                
                cell.numOfSeasons.text = "Seasons"
                let numSeasons = String(show.seasonsCount)
                cell.numOfSeasonsDetail.text = "\(numSeasons)"
                if numSeasons == "" {
                    cell.numOfSeasonsDetail.text = "Unknown"
                }
                
            } else if let movie = film as? Movie {
                cell.rating.text = ""
                cell.detailRating.text = ""
                
                cell.numOfSeasons.text = ""
                cell.numOfSeasonsDetail.text = ""
            }

            
            return cell
        }
        
        
       
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    @IBAction func showActivityViewController(sender: AnyObject) {
        
        let shareContent = film!.name 
        
        let activityViewController = UIActivityViewController(activityItems: [shareContent], applicationActivities: nil)
        presentViewController(activityViewController, animated: true) {
            
        }
        
        
    }
    
}

extension DetailViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        // Show Detail
        if let truncatedTextView = textView as? TruncateTextView {
            truncatedTextView.shouldTruncated = false
            tableView.beginUpdates()
            tableView.endUpdates()
            
        }
    
        return false
    }
    
}
