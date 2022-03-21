//
//  ExtraIngredientCollectionViewCell.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 18/01/22.
//

import UIKit

protocol ExtraIngredientCollectionViewCellDelegate : AnyObject {
    func didPressButton(_ tag: Int)
}

class ExtraIngredientCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var cellDelegate: ExtraIngredientCollectionViewCellDelegate?
    
    var cornerRadius: CGFloat = 20
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let origCencelImage = UIImage(named: K.Images.cancel)
        let tintedCancelImage = origCencelImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedCancelImage, for: .normal)
        cancelButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
             
             NSLayoutConstraint.activate([
                 contentView.leftAnchor.constraint(equalTo: leftAnchor),
                 contentView.rightAnchor.constraint(equalTo: rightAnchor),
                 contentView.topAnchor.constraint(equalTo: topAnchor),
                 contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
             ])
        
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
    @IBAction func removeExtraIngredientPressed(_ sender: UIButton) {
        cellDelegate?.didPressButton(sender.tag)
    }
    

}
