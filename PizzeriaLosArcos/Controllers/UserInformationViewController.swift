//
//  UserInformationViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 11/02/22.
//

import UIKit
import Firebase
import RealmSwift
import ProgressHUD

class UserInformationViewController: UIViewController, UpdateViewController {
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var userDetailsView: UIView!
    @IBOutlet weak var changePasswordView: UIView!
    @IBOutlet weak var deleteAccountView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let db = Firestore.firestore()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameView.dropShadow()
        userDetailsView.dropShadow()
        changePasswordView.dropShadow()
        deleteAccountView.dropShadow()
        
        self.userNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.changePasswordView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.deleteAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let name = user.displayName, let email = user.email, let phone = user.phoneNumber {
                userNameLabel.text = name
                phoneLabel.text = phone
                emailLabel.text = email
            }
        }
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        let tag = sender.view!.tag
        
        switch tag {
        case 0:
            userNameView.showAnimation {
                self.performSegue(withIdentifier: K.Segues.userInformationToEditUserName, sender: self)
            }
        case 1:
            changePasswordView.showAnimation {
                self.performSegue(withIdentifier: K.Segues.userInformationToChangePassword, sender: self)
            }
        case 2:
            deleteAccountView.showAnimation {
                let alert = UIAlertController(title: K.Texts.importantAnnouncement, message: K.Texts.deleteAccountMessage, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "Contraseña"
                    textField.isSecureTextEntry = true
                }
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { action in
                    if let currentPassword = alert.textFields![0].text, let email = Auth.auth().currentUser?.email  {
                        if let user = Auth.auth().currentUser {
                            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
                            
                            ProgressHUD.show()
                            user.reauthenticate(with: credential) { AuthDataResult, error in
                                ProgressHUD.dismiss()
                                if let error = error {
                                    self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                                } else {
                                    ProgressHUD.show()
                                    user.delete { error in
                                        ProgressHUD.dismiss()
                                        if let error = error {
                                            self.alert(title: "¡Ha ocurrido un error!", message: error.localizedDescription)
                                        } else {
                                            let alert = UIAlertController(title: "Cuenta eliminada correctamente", message: nil, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                                try! self.realm.write {
                                                    self.realm.deleteAll()
                                                }
                                                
                                                self.navigationController?.popToRootViewController(animated: true)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        default: break
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "¿Estás seguro que deseas salir?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sí, salir", style: .default, handler: { action in
            do { try Auth.auth().signOut() }
            catch { print("already logged out") }
            
            try! self.realm.write {
                self.realm.deleteAll()
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.userInformationToEditUserName {
            let destinationVC = segue.destination as! EditUserNameViewController
            destinationVC.delegate = self
        }
    }
    
    func update() {
        viewWillAppear(false)
    }
    
}
