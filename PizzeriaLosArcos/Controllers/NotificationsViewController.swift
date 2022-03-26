//
//  NotificationsViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 25/03/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class NotificationsViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var notifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: K.Images.back)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        tableView.register(UINib(nibName: K.Collections.notificationTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.notificationCell)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        getUserToken { userToken in
            ProgressHUD.show()
            self.db.collection(K.Firebase.notificationsCollection)
                .addSnapshotListener { querySnapshot, error in
                    ProgressHUD.dismiss()
                    self.notifications = []
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                    } else {
                        if let documents = querySnapshot?.documents {
                            for doc in documents {
                                let result = Result {
                                    try doc.data(as: Notification.self)
                                }
                                switch result {
                                case .success(let notification):
                                    if !notification.viewed && notification.userToken.elementsEqual(userToken) {
                                        self.notifications.append(notification)
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
        }
        
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func getUserToken(completion: @escaping (String) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        ProgressHUD.show()
        db.collection(K.Firebase.userCollection).document(userID).getDocument { document, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    if let userToken = data?[K.Firebase.fcmToken] as? String {
                        completion(userToken)
                    }
                } else {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error!.localizedDescription)
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
}


//MARK: - TableView Delegate and DataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.notificationCell, for: indexPath) as! NotificationsTableViewCell
        
        let currNotification = notifications[indexPath.row]
        
        cell.folioLabel.text = currNotification.folio
        cell.titleLabel.text = currNotification.title
        cell.descriptionLabel.text = currNotification.description
        cell.optionsLabel.text = currNotification.options
        
        return cell
    }
    
    
}
