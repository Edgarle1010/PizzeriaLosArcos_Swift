//
//  CreatePasswordViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class CreatePasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var signinPressed: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLine()
        
        passwordTextField.delegate = self
        verifyPasswordTextField.delegate = self
        
    }
    
    @IBAction func signinPressed(_ sender: UIButton) {
        if let password = passwordTextField.text, let verifyPassword = verifyPasswordTextField.text, let user = Auth.auth().currentUser, let email = UserDefaults.standard.string(forKey: K.UserDef.email) {
            if password == verifyPassword {
                ProgressHUD.show()
                user.updatePassword(to: password) { error in
                    ProgressHUD.dismiss()
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                    } else {
                        ProgressHUD.show()
                        user.updateEmail(to: email) { error in
                            ProgressHUD.dismiss()
                            if let error = error {
                                self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                            } else {
                                let changeRequest = user.createProfileChangeRequest()
                                if let name = UserDefaults.standard.string(forKey: K.UserDef.name),
                                   let lastName = UserDefaults.standard.string(forKey: K.UserDef.lastName),
                                   let phoneNumber = UserDefaults.standard.string(forKey: K.UserDef.phoneNumber) {
                                    changeRequest.displayName = "\(name) \(lastName)"
                                    ProgressHUD.show()
                                    changeRequest.commitChanges { (error) in
                                        ProgressHUD.dismiss()
                                        let currUser = User(userId: user.uid, name: name, lastName: lastName, email: email, phoneNumber: phoneNumber, streaks: 0, isBaned: false, fcmToken: nil)
                                        
                                        let docRef = self.db.collection(K.Firebase.userCollection).document(user.uid)
                                        ProgressHUD.show()
                                        do {
                                            ProgressHUD.dismiss()
                                            try docRef.setData(from: currUser)
                                            self.performSegue(withIdentifier: K.Segues.createPasswordToMenu, sender: self)
                                        }
                                        catch {
                                            self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                alert(title: nil, message: "Las contraseñas no coinciden, vuelvelo a intentar")
            }
        }
    }
    
    fileprivate func addLine() {
        passwordTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        verifyPasswordTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case passwordTextField:
            verifyPasswordTextField.becomeFirstResponder()
        case verifyPasswordTextField:
            signinPressed.sendActions(for: .touchUpInside)
        default:
            self.verifyPasswordTextField.resignFirstResponder()
        }
    }
}
