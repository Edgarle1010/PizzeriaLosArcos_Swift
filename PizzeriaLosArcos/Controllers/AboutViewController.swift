//
//  AboutViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 22/02/22.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var termsAndConditionsStackView: UIStackView!
    @IBOutlet weak var noticePrivacyStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataView.dropShadow()
        
        self.termsAndConditionsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.noticePrivacyStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))

    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        switch sender.view!.tag {
        case 0:
            termsAndConditionsStackView.showAnimation {
                guard let url = URL(string: K.URLS.termsAndConditions) else { return }
                UIApplication.shared.open(url)
            }
        case 1:
            noticePrivacyStackView.showAnimation {
                guard let url = URL(string: K.URLS.privacyPolicy) else { return }
                UIApplication.shared.open(url)
            }
        default: break
        }
    }

}
