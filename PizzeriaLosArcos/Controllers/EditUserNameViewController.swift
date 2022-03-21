//
//  EditUserNameViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 13/02/22.
//

import UIKit
import Firebase
import ProgressHUD

class EditUserNameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: UpdateViewController? = nil
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: K.Images.back)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        addLine()
        
        nameTextField.delegate = self
        lastNameTextField.delegate = self
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        if let name = nameTextField.text, let lastName = lastNameTextField.text, let user = Auth.auth().currentUser {
            if !isValidName(name) || name.isEmpty {
                alert(title: "Alerta", message: "El nombre introducido no es válido")
            } else if !isValidName(lastName) || lastName.isEmpty {
                alert(title: "Alerta", message: "El apellido introducido no es válido")
            } else {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = "\(name) \(lastName)"
                ProgressHUD.show()
                changeRequest?.commitChanges { error in
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                    } else {
                        let docRef = self.db.collection(K.Firebase.userCollection).document(user.uid)
                        ProgressHUD.show()
                        docRef.updateData([
                            K.Firebase.nameField: name,
                            K.Firebase.lastNameField: lastName
                        ]) { err in
                            ProgressHUD.dismiss()
                            if let err = err {
                                self.alert(title: "¡Ha ocurrido un error!", message: err.localizedDescription)
                            } else {
                                if let delegate = self.delegate {
                                    delegate.update()
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func addLine() {
        nameTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
        lastNameTextField.addLine(position: .bottom, color: UIColor(named: K.BrandColors.secundaryColor)!, width: 0.5)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
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
            saveButton.sendActions(for: .touchUpInside)
        default:
            self.lastNameTextField.resignFirstResponder()
        }
    }
    
}
