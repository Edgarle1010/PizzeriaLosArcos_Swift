//
//  TabBarController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseFirestoreSwift
import BadgeHub

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet weak var ordersInProcessButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    
    var notificationToken: NotificationToken?
    var itemList: Results<Item>?
    let realm = try! Realm()
    
    let db = Firestore.firestore()
    
    var ordersList: [Order] = []
    var notifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ordersInProcessHub = BadgeHub(view: ordersInProcessButton)
        ordersInProcessHub.scaleCircleSize(by: 0.65)

        let notificationsHub = BadgeHub(view: notificationsButton)
        notificationsHub.scaleCircleSize(by: 0.65)
       
        self.delegate = self
        
        self.navigationItem.title = K.Titles.menu
        ordersInProcessButton.isHidden = true
        
        itemList = realm.objects(Item.self)
        
        guard let itemList = itemList else {
            return
        }
        
        notificationToken = itemList.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tabItems = self?.tabBar.items else { return }
            let tabItem = tabItems[1]
            switch changes {
            case .initial:
                if itemList.count > 0 {
                    tabItem.badgeValue = "\(itemList.count)"
                } else {
                    tabItem.badgeValue = nil
                }
            case .update(_, _, _, _):
                if itemList.count > 0 {
                    tabItem.badgeValue = "\(itemList.count)"
                } else {
                    tabItem.badgeValue = nil
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
        getOrdersInProcess(ordersInProcessHub)
        
        getNotifications(notificationsHub)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }
    
    
    func getOrdersInProcess(_ hub: BadgeHub) {
        if let user = Auth.auth().currentUser?.phoneNumber {
            db.collection(K.Firebase.ordersCollection)
                .whereField(K.Firebase.client, isEqualTo: user)
                .addSnapshotListener { querySnapshot, error in
                    self.ordersList = []
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                    } else {
                        if let documents = querySnapshot?.documents {
                            for doc in documents {
                                let result = Result {
                                    try doc.data(as: Order.self)
                                }
                                switch result {
                                case .success(let order):
                                    if !order.complete {
                                        self.ordersList.append(order)
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                            }
                            
                            DispatchQueue.main.async {
                                if self.ordersList.count != 0 {
                                    hub.pop()
                                    hub.setCount(self.ordersList.count)
                                } else {
                                    hub.hide()
                                }
                            }
                        }
                    }
                }
            
        }
    }
    
    func getUserToken(completion: @escaping (String) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        db.collection(K.Firebase.userCollection).document(userID).getDocument { document, error in
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
    
    func getNotifications(_ hub: BadgeHub) {
        getUserToken { userToken in
            self.db.collection(K.Firebase.notificationsCollection)
                .addSnapshotListener { querySnapshot, error in
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
                                if self.notifications.count != 0 {
                                    hub.pop()
                                    hub.setCount(self.notifications.count)
                                } else {
                                    hub.hide()
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let currentVC = viewController.restorationIdentifier {
            switch currentVC {
            case K.ViewControllers.menuViewController:
                self.navigationItem.title = K.Titles.menu
                ordersInProcessButton.isHidden = true
            case K.ViewControllers.shoppingCarViewController:
                self.navigationItem.title = K.Titles.shoppingCar
                ordersInProcessButton.isHidden = false
            case K.ViewControllers.moreViewController:
                self.navigationItem.title = K.Titles.more
                ordersInProcessButton.isHidden = true
            default:
                break;
            }
        }
    }
}
