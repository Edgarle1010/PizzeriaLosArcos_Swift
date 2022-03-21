//
//  VerificationCodeViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import UIKit
import Firebase
import ProgressHUD

class VerificationCodeViewController: UIViewController {
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLine()

        alert(title: nil, message: "En breve recibiras un código de seguridad para verificar tu número")
        
        if let phoneNumber = UserDefaults.standard.string(forKey: K.UserDef.phoneNumber) {
            phoneNumberLabel.text = "Enviado a \(phoneNumber)"
        }
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        if let verificationCode = verificationCodeTextField.text {
            
            guard let verificationID = UserDefaults.standard.string(forKey: K.UserDef.authVerificationID) else {
                return
            }
            
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
            
            ProgressHUD.show()
            Auth.auth().signIn(with: credential) { (authResult, error) in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: K.Segues.verificationCodeToCreatePassword, sender: self)
                }
            }
        }
    }
    
    fileprivate func addLine() {
        verificationCodeTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
}
