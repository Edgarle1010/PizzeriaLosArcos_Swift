//
//  AppManager.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 01/01/22.
//

import UIKit
import ProgressHUD
 
class AppManager {
    let window = (UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate).window
    static let shared = AppManager()
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var appContainer: WelcomeViewController!
    private init() { }
    
    func showApp() {
        var viewController: UIViewController
        viewController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        appContainer.navigationController?.pushViewController(viewController, animated: false)
    }
}

protocol DataSending {
    func sendFood(food: Food)
    func cancelFood(isTrue: Bool)
    func sendExtraIngredient(extraIngredient: ExtraIngredient)
    func sendAmount(amount: Int)
}

protocol UpdateViewController {
    func update()
}
