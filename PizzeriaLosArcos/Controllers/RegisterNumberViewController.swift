//
//  RegisterNumberViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import UIKit
import Firebase
import ProgressHUD

class RegisterNumberViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: ButtonWithShadow!
    
    let db = Firestore.firestore()
    
    let regionPicker = UIPickerView()
    let myPickerData = K.regions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLine()
        
        phoneNumberTextField.delegate = self
        
        regionTextField.inputView = regionPicker
        regionPicker.delegate = self
        
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        if var phoneNumber = phoneNumberTextField.text, let prefix = regionTextField.text {
            if phoneNumber.count == 10 {
                phoneNumber = prefix + phoneNumber
                checkPhoneNumber(phoneNumber);
            }
        } else {
            alert(title: "Alerta", message: "El número celular introducido no es válido.")
        }
    }
    
    func checkPhoneNumber(_ phoneNumber: String) {
        ProgressHUD.show()
        db.collection(K.Firebase.userCollection).whereField(K.Firebase.phoneNumberField, isEqualTo: phoneNumber)
            .getDocuments { (querySnapshot, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        if documents.count != 0 {
                            self.alert(title: "¡Ha ocurrido un problema!", message: "El número celular ya ha sido registrado anteriormente")
                        } else {
                            ProgressHUD.show()
                            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                                ProgressHUD.dismiss()
                                if let error = error {
                                    self.alert(title: "¡Ha ocurrido un problema!", message: "\(error.localizedDescription)")
                                } else {
                                    UserDefaults.standard.set(verificationID, forKey: K.UserDef.authVerificationID)
                                    UserDefaults.standard.set(phoneNumber, forKey: K.UserDef.phoneNumber)
                                    
                                    self.performSegue(withIdentifier: K.Segues.phoneNumberToVerificationCode, sender: self)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    fileprivate func addLine() {
        regionTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        phoneNumberTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        
        let maxLength = 10
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= maxLength && allowedCharacters.isSuperset(of: characterSet)
    }
}


// MARK: UIPickerView Delegation

extension RegisterNumberViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.backgroundColor = UIColor(named: K.BrandColors.thirdColor)
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row].description
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        regionTextField.text = myPickerData[row].prefix
    }
    
}
