//
//  TabBarController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 09/01/22.
//

import UIKit
import RealmSwift

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    var notificationToken: NotificationToken?
    var itemList: Results<Item>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.navigationItem.title = K.Titles.menu
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.hidesBackButton = false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let currentVC = viewController.restorationIdentifier {
            switch currentVC {
            case K.ViewControllers.menuViewController:
                self.navigationItem.title = K.Titles.menu
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            case K.ViewControllers.shoppingCarViewController:
                self.navigationItem.title = K.Titles.shoppingCar
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
            case K.ViewControllers.moreViewController:
                self.navigationItem.title = K.Titles.more
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            default:
                break;
            }
        }
    }
}
