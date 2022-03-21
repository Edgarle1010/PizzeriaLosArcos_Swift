//
//  ChangePasswordViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 13/02/22.
//

import UIKit
import Firebase
import ProgressHUD

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: K.Images.back)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        addLine()
        
        currentPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        verifyPasswordTextField.delegate = self

    }

    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        if let currentPassword = currentPasswordTextField.text, let newPassword = newPasswordTextField.text, let verifyPassword = verifyPasswordTextField.text, let email = Auth.auth().currentUser?.email  {
            if let user = Auth.auth().currentUser {
                let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

                ProgressHUD.show()
                user.reauthenticate(with: credential) { AuthDataResult, error in
                    ProgressHUD.dismiss()
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                    } else {
                        if newPassword.elementsEqual(verifyPassword) {
                            ProgressHUD.show()
                            user.updatePassword(to: newPassword) { error in
                                ProgressHUD.dismiss()
                                if let error = error {
                                    self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                                } else {
                                    let alert = UIAlertController(title: nil, message: "Contraseña actualizada correctamente", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                        self.dismiss(animated: true)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        } else {
                            self.alert(title: "¡Ha ocurrido un error!", message: "Las contraseñas no coinciden, vuelvelo a intentar")
                        }
                    }
                }
            }
        } else {
            alert(title: nil, message: "Las contraseñas no coinciden, vuelvelo a intentar")
        }
    }
    
    fileprivate func addLine() {
        currentPasswordTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        newPasswordTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
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
        case currentPasswordTextField:
            newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            verifyPasswordTextField.becomeFirstResponder()
        case verifyPasswordTextField:
            saveButton.sendActions(for: .touchUpInside)
        default:
            self.verifyPasswordTextField.resignFirstResponder()
        }
    }
}
