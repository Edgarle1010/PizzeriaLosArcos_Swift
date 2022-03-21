//
//  AmountViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 18/01/22.
//

import UIKit

class AmountViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: DataSending? = nil
    
    let myPickerData = K.amountArray
    var amount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origCencelImage = UIImage(named: K.Images.cancel)
        let tintedCancelImage = origCencelImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedCancelImage, for: .normal)
        cancelButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        let origAddImage = UIImage(named: K.Images.add)
        let tintedAddImage = origAddImage?.withRenderingMode(.alwaysTemplate)
        addButton.setImage(tintedAddImage, for: .normal)
        addButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        pickerView.dataSource = self
        pickerView.delegate = self

        amount = myPickerData[0]
    }

    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        if let amount = amount, let delegate = delegate {
            delegate.sendAmount(amount: amount)
            dismiss(animated: true)
        }
    }
}


// MARK: UIPickerView Delegation

extension AmountViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(myPickerData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: String(myPickerData[row]), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(named: K.BrandColors.primaryColor) as Any])
        return attributedString
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        amount = myPickerData[row]
    }
    
}
