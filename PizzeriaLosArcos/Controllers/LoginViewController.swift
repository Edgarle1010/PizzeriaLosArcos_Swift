//
//  LoginViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 06/01/22.
//

import UIKit
import Firebase
import ProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var phoneLoginButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var regionTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()
    
    let regionPicker = UIPickerView()
    let myPickerData = K.regions
    
    var phoneIsSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLine()
        
        phoneTextField.delegate = self
        
        regionTextField.inputView = regionPicker
        regionPicker.delegate = self
        
    }
    
    @IBAction func Pressed(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            phoneLoginButton.alpha = 1
            emailLoginButton.alpha = 0.3
            phoneView.isHidden = false
            emailView.isHidden = true
            phoneIsSelected = true
        case 2:
            phoneLoginButton.alpha = 0.3
            emailLoginButton.alpha = 1
            phoneView.isHidden = true
            emailView.isHidden = false
            phoneIsSelected = false
        case 3:
            if phoneIsSelected {
                if let phone = phoneTextField.text, let prefix = regionTextField.text, let password = passwordTextField.text {
                    let phoneNumber = prefix + phone
                    loginWithPhoneNumberPasswordUser(phoneNumber, password)
                }
            } else {
                if let email = emailTextField.text, let password = passwordTextField.text {
                    loginEmailPasswordUser(email, password)
                }
            }
        default:
            break;
        }
    }
    
    fileprivate func addLine() {
        regionTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        phoneTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        emailTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        passwordTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
    }
    
    func loginWithPhoneNumberPasswordUser(_ phoneNumber: String, _ password: String) {
        ProgressHUD.show()
        db.collection(K.Firebase.userCollection).whereField(K.Firebase.phoneNumberField, isEqualTo: phoneNumber)
            .getDocuments { (querySnapshot, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    if let documents = querySnapshot?.documents {
                        if documents.count != 0 {
                            for doc in documents {
                                let data = doc.data()
                                if let email = data[K.Firebase.emailField] as? String {
                                    
                                    DispatchQueue.main.async {
                                        self.loginEmailPasswordUser(email, password)
                                    }
                                }
                            }
                        } else {
                            self.alert(title: "¡Ha ocurrido un problema!", message: "No hay ningún usuario registrado con este número")
                        }
                    }
                }
        }
    }
    
    func loginEmailPasswordUser(_ email: String, _ password: String) {
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: K.Segues.loginToMenu, sender: self)
            }
        }
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

extension LoginViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
