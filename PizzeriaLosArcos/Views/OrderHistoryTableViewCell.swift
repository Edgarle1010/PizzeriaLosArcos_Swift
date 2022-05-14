//
//  OrderHistoryTableViewCell.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 13/05/22.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeEstimatedDelivery: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
