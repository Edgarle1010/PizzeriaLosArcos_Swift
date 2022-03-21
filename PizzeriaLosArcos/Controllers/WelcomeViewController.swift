//
//  ViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 29/12/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set top Nav Bar behavior for ALL of app
        let standardAppearance = UINavigationBarAppearance()

        // Title font color
        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.BrandColors.primaryColor)!]

        // prevent Nav Bar color change on scroll view push behind NavBar
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(named: K.BrandColors.secundaryColor)

        self.navigationController?.navigationBar.standardAppearance = standardAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        AppManager.shared.appContainer = self
        AppManager.shared.showApp()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
}

