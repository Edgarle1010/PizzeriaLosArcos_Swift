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

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet weak var ordersInProccessButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    
    var notificationToken: NotificationToken?
    var itemList: Results<Item>?
    let realm = try! Realm()
    
    let db = Firestore.firestore()
    
    var ordersList: [Order] = []
    var notifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.navigationItem.title = K.Titles.menu
        ordersInProccessButton.isHidden = true
        
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
        
        getOrdersInProccess()
        
        getNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }
    
    let badgeSize: CGFloat = 20
    let badgeTag = 9830384
    
    func badgeLabel(withCount count: Int) -> UILabel {
        let badgeCount = UILabel(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))
        badgeCount.translatesAutoresizingMaskIntoConstraints = false
        badgeCount.tag = badgeTag
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(12)
        badgeCount.backgroundColor = .systemRed
        badgeCount.text = String(count)
        return badgeCount
    }
    
    func showBadge(withCount count: Int, _ button: UIButton) {
        let badge = badgeLabel(withCount: count)
        button.addSubview(badge)
        
        NSLayoutConstraint.activate([
            badge.leftAnchor.constraint(equalTo: button.leftAnchor, constant: 14),
            badge.topAnchor.constraint(equalTo: button.topAnchor, constant: 4),
            badge.widthAnchor.constraint(equalToConstant: badgeSize),
            badge.heightAnchor.constraint(equalToConstant: badgeSize)
        ])
    }
    
    func removeBadge(_ button: UIButton) {
        if let badge = button.viewWithTag(badgeTag) {
            badge.removeFromSuperview()
        }
    }
    
    func getOrdersInProccess() {
        NSLayoutConstraint.activate([
            ordersInProccessButton.widthAnchor.constraint(equalToConstant: 34),
            ordersInProccessButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
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
                                    self.showBadge(withCount: self.ordersList.count, self.ordersInProccessButton)
                                } else {
                                    self.removeBadge(self.ordersInProccessButton)
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
    
    func getNotifications() {
        NSLayoutConstraint.activate([
            notificationsButton.widthAnchor.constraint(equalToConstant: 34),
            notificationsButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
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
                                    self.showBadge(withCount: self.notifications.count, self.notificationsButton)
                                } else {
                                    self.removeBadge(self.notificationsButton)
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
                ordersInProccessButton.isHidden = true
            case K.ViewControllers.shoppingCarViewController:
                self.navigationItem.title = K.Titles.shoppingCar
                ordersInProccessButton.isHidden = false
            case K.ViewControllers.moreViewController:
                self.navigationItem.title = K.Titles.more
                ordersInProccessButton.isHidden = true
            default:
                break;
            }
        }
    }
}
