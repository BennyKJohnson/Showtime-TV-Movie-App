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
    case EpisodeDetailCell
    
}

class DetailViewController: UITableViewController {

    var cells: [DetailCellType] = []
    
    var film: Film! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
     var count = 0
    
    func configureView() {
        // Update the user interface for the detail item.
        if let film = self.film{
            title = film.name
            
            cells = []
            cells.append(DetailCellType.HeaderCell)
            cells.append(DetailCellType.DescriptionCell(title: "Description", body: film.overview))
            cells.append(DetailCellType.InformationCell)
            
            
            if  film is Show {
                // Setup Cells specific to TV Show
                cells.append(DetailCellType.EpisodeDetailCell)
                
                
            } else if film is Movie {
                
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
                if let lastEpisode = show.lastEpisodeToAir {
                    
                    let seasonNumber = lastEpisode.season!.number.description
                    
                    if(seasonNumber != ""){
                        cell.numOfSeasonsDetail.text = "\(seasonNumber)"}
                    else{
                        cell.numOfSeasonsDetail.text = "Unknown"
                    }

                }

                
            } else if let movie = film as? Movie {
                
                if let releaseDate = movie.releaseDate{
                    cell.rating.text = "Release date"
                    cell.detailRating.text = releaseDate.stringFormat!
                }
                
                cell.numOfSeasons.text = ""
                cell.numOfSeasonsDetail.text = ""
            }

            
            return cell
            
        case .EpisodeDetailCell:
            let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeDetailCell", forIndexPath: indexPath) as! EpisodeDescriptionCell

            
            if let show = film as? Show {
                                    
                    if let airDate = show.nextEpisodeAirDate {
                        
                        let labelString = "Next episode airing: "
                        let dateString = airDate.stringFormat!
        
                        let attributedString = NSMutableAttributedString(string: labelString + dateString)
                      
                        attributedString.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(cell.nextEpisodeAir.font.pointSize)], range: NSMakeRange(0, labelString.length))
                        
                        cell.nextEpisodeAir.attributedText = attributedString
   
                    }else
                    {
                        cell.nextEpisodeAir.text = ""
                    }

                
                
                if let lastEpisode = show.lastEpisodeToAir {
                    
                    let episodeNum = String(lastEpisode.episodeNumber!)
                    let seasonNumber = lastEpisode.season!.number.description
                    let labelStringLastAired = "Last episode aired: "
                    
                    let attributedString = NSMutableAttributedString(string: labelStringLastAired + "Season " + seasonNumber + " Episode " + episodeNum)
                    
                    attributedString.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(cell.nextEpisodeAir.font.pointSize)], range: NSMakeRange(0, labelStringLastAired.length))
                    
                    cell.lastEpisodeAired.attributedText =  attributedString
                    
                }
                
                
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
