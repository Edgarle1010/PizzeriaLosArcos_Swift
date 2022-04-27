//
//  NotificationsTableViewCell.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 25/03/22.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var optionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
