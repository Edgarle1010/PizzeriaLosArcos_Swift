//
//  ExtraIngredientViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 17/01/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD
import RealmSwift

class ExtraIngredientViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: DataSending? = nil
    
    var foodType: String?
    var foodSize: Int?
    var currExtraIngredientList: List<ExtraIngredient>?
    
    var extraIngredientData: [ExtraIngredient] = []
    var extraIngredient: ExtraIngredient?
    
    let db = Firestore.firestore()
    
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
        
        guard let foodType = foodType else {
            return
        }
        
        ProgressHUD.show()
        db.collection(K.Firebase.extraIngredientsCollection).order(by: K.Firebase.listPosition)
            .getDocuments { (querySnapshot, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        for doc in documents {
                            let result = Result {
                                try doc.data(as: ExtraIngredient.self)
                                }
                                switch result {
                                case .success(let extraIngredient):
                                    if let currExtraIngredientList = self.currExtraIngredientList {
                                        if !currExtraIngredientList.contains(where: { $0.id == extraIngredient.id })
                                            && extraIngredient.food.contains(foodType) {
                                            self.extraIngredientData.append(extraIngredient)
                                        }
                                    } else {
                                        if extraIngredient.food.contains(foodType) {
                                            self.extraIngredientData.append(extraIngredient)
                                        }
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                        }
                        
                        DispatchQueue.main.async {
                            self.pickerView.reloadAllComponents()
                            self.extraIngredient = self.extraIngredientData[0]
                        }
                    }
                }
            }

    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }

    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        if let extraIngredient = extraIngredient, let delegate = delegate {
            delegate.sendExtraIngredient(extraIngredient: extraIngredient)
            dismiss(animated: true)
        }
    }
}


// MARK: UIPickerView Delegation

extension ExtraIngredientViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return extraIngredientData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let foodSize = foodSize {
            return "\(extraIngredientData[row].title) $\(extraIngredientData[row].getPrice(foodSize))"
        } else {
            return "error"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: "\(extraIngredientData[row].title) $\(extraIngredientData[row].getPrice(foodSize!))", attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(named: K.BrandColors.primaryColor) as Any])
        return attributedString
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        extraIngredient = extraIngredientData[row]
    }
    
}
