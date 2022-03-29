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
        
        let standardAppearance = UINavigationBarAppearance()

        standardAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: K.BrandColors.primaryColor)!]

        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(named: K.BrandColors.secundaryColor)

        self.navigationController?.navigationBar.standardAppearance = standardAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = standardAppearance
        
        AppManager.shared.appContainer = self
        AppManager.shared.showApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        UserDefaults.standard.set(false, forKey: K.UserDef.isRecoveryProcess)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func guestPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: K.Texts.guestMode, message: K.Texts.guestMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: .default, handler: { UIAlertAction in
            self.performSegue(withIdentifier: K.Segues.guestToMenu, sender: self)
        }))
        alert.addAction(UIAlertAction(title: K.Texts.goBack, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
}

