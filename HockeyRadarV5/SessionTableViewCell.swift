//
//  SessionsTableViewCell.swift
//  HockeyRadarV5
//
//  Created by Alex Aghajanov on 2023-07-18.
//

import UIKit

class SessionsTableViewCell: UITableViewCell {
    
    @IBOutlet var shotsCount: UILabel!
    @IBOutlet var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
