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
    var listener: ListenerRegistration?
    
    var notifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: K.Images.back)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        tableView.register(UINib(nibName: K.Collections.notificationTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.notificationCell)
        
        getUserToken { userToken in
            self.getNotifications(userToken)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener?.remove()
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
    
    func getNotifications(_ userToken: String) {
        ProgressHUD.show()
        listener = self.db.collection(K.Firebase.notificationsCollection)
            .whereField(K.Firebase.userToken, isEqualTo: userToken)
            .addSnapshotListener { querySnapshot, error in
                ProgressHUD.dismiss()
                self.notifications.removeAll()
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
                                self.notifications.append(notification)
                            case .failure(let error):
                                print("Error decoding food: \(error)")
                            }
                        }
                        
                        DispatchQueue.main.async {
                            UIView.transition(with: self.tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {
                                self.notifications = self.notifications.sorted(by: { $0.dateSend > $1.dateSend })
                                self.tableView.reloadData()
                            }, completion: nil)
                        }
                    }
                }
            }
    }
    
    func markReadNotification(_ notification: Notification) {
        ProgressHUD.show()
        db.collection(K.Firebase.notificationsCollection)
            .whereField(K.Firebase.dateSend, isEqualTo: notification.dateSend)
            .getDocuments { document, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = document?.documents {
                        for doc in documents {
                            ProgressHUD.show()
                            self.db.collection(K.Firebase.notificationsCollection).document(doc.documentID).updateData([
                                K.Firebase.viewed: true,
                            ]) { err in
                                ProgressHUD.dismiss()
                                if let err = err {
                                    self.alert(title: K.Texts.problemOcurred, message: err.localizedDescription)
                                } else {
                                    print("Document successfully updated")
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func removeNotification(_ notification: Notification) {
        ProgressHUD.show()
        db.collection(K.Firebase.notificationsCollection)
            .whereField(K.Firebase.dateSend, isEqualTo: notification.dateSend)
            .getDocuments { document, error in
                ProgressHUD.dismiss()
                if let error = error {
                    self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                } else {
                    if let documents = document?.documents {
                        for doc in documents {
                            ProgressHUD.show()
                            self.db.collection(K.Firebase.notificationsCollection).document(doc.documentID).delete() { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
//                                    DispatchQueue.main.async {
//                                        if self.notifications.count == 0 {
//                                            self.tableView.setEmptyView(title: "No tienes notificaciones nuevas", message: "")
//                                        } else {
//                                            self.tableView.restore()
//                                        }
//
//                                        UIView.transition(with: self.tableView, duration: 0.6, options: .transitionCrossDissolve, animations: {
//                                            self.tableView.reloadData()
//                                        }, completion: nil)
//                                    }
                                }
                            }
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
}


//MARK: - TableView Delegate and DataSource

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notifications.count == 0 {
            self.tableView.setEmptyView(title: "No tienes notificaciones nuevas", message: "")
        } else {
            self.tableView.restore()
        }
        
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.notificationCell, for: indexPath) as! NotificationsTableViewCell
        
        let currNotification = notifications[indexPath.row]
        
        let timeRequest = currNotification.dateSend
        let dateRequest = Date(timeIntervalSince1970: timeRequest)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.timeZone = TimeZone.current
        dateFormatterGet.locale = NSLocale.current
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        cell.folioLabel.text = currNotification.folio
        cell.titleLabel.text = currNotification.title
        cell.descriptionLabel.text = currNotification.description
        cell.optionsLabel.text = dateFormatterGet.string(from: dateRequest)
        
        if currNotification.viewed {
            cell.notificationView.isHidden = true
        } else {
            cell.notificationView.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let currNotification = notifications[index]
        
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
                
                let markAsRead = UIAction(title: "Marcar notificación como leída",
                                          image: UIImage(named: K.Images.markRead),
                                          identifier: nil
                ) { _ in
                    self.markReadNotification(currNotification)
                }
                
                let origImage = UIImage(named: "delete")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                
                let delete = UIAction(title: "Borrar notificación",
                                      image: tintedImage,
                                      identifier: nil,
                                      attributes: .destructive
                ) { _ in
                    self.removeNotification(currNotification)
                }
                
                if currNotification.viewed {
                    return UIMenu(title: "", image: nil, children: [delete])
                } else {
                    return UIMenu(title: "", image: nil, children: [markAsRead, delete])
                }
            }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let identifier = configuration.identifier as? String,
            let index = Int(identifier),
            
                let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
                as? NotificationsTableViewCell
        else {
            return nil
        }
        
        return UITargetedPreview(view: cell.viewCell)
    }
}
