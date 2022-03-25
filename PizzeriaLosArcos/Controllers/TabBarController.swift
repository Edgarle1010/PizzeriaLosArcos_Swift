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
                                self.showBadge(withCount: self.ordersList.count)
                            }
                        }
                    }
                }
                
        }
        
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
    
    func showBadge(withCount count: Int) {
        let badge = badgeLabel(withCount: count)
        ordersInProccessButton.addSubview(badge)

        NSLayoutConstraint.activate([
            badge.leftAnchor.constraint(equalTo: ordersInProccessButton.leftAnchor, constant: 14),
            badge.topAnchor.constraint(equalTo: ordersInProccessButton.topAnchor, constant: 4),
            badge.widthAnchor.constraint(equalToConstant: badgeSize),
            badge.heightAnchor.constraint(equalToConstant: badgeSize)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }
    
    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        
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
