//
//  SigninViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import UIKit

class SigninViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextPressed: ButtonWithShadow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLine()
        
        nameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if let name = nameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text {
            if !isValidName(name) || name.isEmpty {
                alert(title: "Alerta", message: "El nombre introducido no es válido")
            } else if !isValidName(lastName) || lastName.isEmpty {
                alert(title: "Alerta", message: "El apellido introducido no es válido")
            } else if !isValidEmail(email) || email.isEmpty {
                alert(title: "Alerta", message: "El e-mail introducido no es válido")
            } else {
                UserDefaults.standard.set(name, forKey: K.UserDef.name)
                UserDefaults.standard.set(lastName, forKey: K.UserDef.lastName)
                UserDefaults.standard.set(email, forKey: K.UserDef.email)
                
                self.performSegue(withIdentifier: K.Segues.userInformationToPhoneNumber, sender: self)
            }
        }
    }
    
    fileprivate func addLine() {
        nameTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        lastNameTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        emailTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidName(_ name: String) -> Bool {
        let nameRegExt = "[A-Za-zÀ-ÿ '-]*"
        let namePred = NSPredicate(format:"SELF MATCHES %@", nameRegExt)
        return namePred.evaluate(with: name)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            nextPressed.sendActions(for: .touchUpInside)
        default:
            self.emailTextField.resignFirstResponder()
        }
    }
}
