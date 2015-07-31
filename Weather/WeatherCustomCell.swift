//
//  WeatherCustomCell.swift
//  STRV
//
//  Created by Riccardo Rizzo on 28/07/15.
//  Copyright (c) 2015 Riccardo Rizzo. All rights reserved.
//

import UIKit

class WeatherCustomCell: UITableViewCell {

    
    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var weatherDay: UILabel!
    @IBOutlet var weatherDescription: UILabel!
    @IBOutlet var weatherTemp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
