//
//  OrderTableViewCell.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 21/03/22.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeRequest: UILabel!
    @IBOutlet weak var timeProcessed: UILabel!
    @IBOutlet weak var timeFinished: UILabel!
    @IBOutlet weak var timeDelivered: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeStimatedCompletion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewCell.dropShadow()
        viewCell.layer.cornerRadius = 12
        viewCell.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
