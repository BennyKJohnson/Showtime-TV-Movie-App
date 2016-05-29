//
//  FilmCell.swift
//  Showtime
//
//  Created by Benjamin Johnson on 28/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import UIKit

class FilmCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var subtitleTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
