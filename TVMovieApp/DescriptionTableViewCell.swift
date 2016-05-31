//
//  DescriptionTableViewCell.swift
//  TVMovieApp
//
//  Created by Ben Johnson on 27/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: TruncateTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class InformationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var detailTextLabel1: UILabel!

    @IBOutlet weak var textLabel4: UILabel!
    @IBOutlet weak var textLabel2: UILabel!
    @IBOutlet weak var detailTextLabel2: UILabel!
    
    @IBOutlet weak var textLabel3: UILabel!
    @IBOutlet weak var detailTextLabel3: UILabel!
    
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var detailRating: UILabel!

    @IBOutlet weak var numOfSeasons: UILabel!
    @IBOutlet weak var numOfSeasonsDetail: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}