//
//  MoreViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 08/01/22.
//

import UIKit
import MessageUI
import Firebase

class MoreViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var howGetStackView: UIStackView!
    @IBOutlet weak var callStackView: UIStackView!
    @IBOutlet weak var commentsStackView: UIStackView!
    @IBOutlet weak var aboutView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userView.dropShadow()
        historyView.dropShadow()
        dataView.dropShadow()
        aboutView.dropShadow()
        
        self.userView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.historyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.howGetStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.callStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.commentsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
        self.aboutView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.checkAction)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let name = user.displayName, let phone = user.phoneNumber {
                userNameLabel.text = name
                phoneNumberLabel.text = phone
            }
        }
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        switch sender.view!.tag {
        case 0:
            userView.showAnimation {
                self.performSegue(withIdentifier: K.Segues.moreToUserInformation, sender: self)
            }
        case 1:
            historyView.showAnimation {
                self.performSegue(withIdentifier: K.Segues.moreToOrdersHistory, sender: self)
            }
        case 2:
            howGetStackView.showAnimation {
                OpenMapDirections.present(in: self, sourceView: self.howGetStackView)
            }
        case 3:
            callStackView.showAnimation {
                if let phoneCallURL = URL(string: "tel://+526255834400") {

                    let application:UIApplication = UIApplication.shared
                    if (application.canOpenURL(phoneCallURL)) {
                        application.open(phoneCallURL, options: [:], completionHandler: nil)
                    }
                  }
            }
        case 4:
            commentsStackView.showAnimation {
                self.sendEmail()
            }
        case 5:
            aboutView.showAnimation {
                self.performSegue(withIdentifier: K.Segues.moreToAbout, sender: self)
            }
        default: break
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["pizzeriagmapp@gmail.com"])
            mail.setSubject("Pizzería Los Arcos App")
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
