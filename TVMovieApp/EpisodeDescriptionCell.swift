//
//  EpisodeDescriptionCell.swift
//  Showtime
//
//  Created by Ozakovic on 2/06/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import Foundation
import UIKit

class EpisodeDescriptionCell: UITableViewCell {

    @IBOutlet weak var lastEpisodeAired: UILabel!
    
    @IBOutlet weak var nextEpisodeAir: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}