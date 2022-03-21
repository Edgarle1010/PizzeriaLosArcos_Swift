//
//  SigninViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 06/01/22.
//

import UIKit

class TermsServicesViewController: UIViewController {
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMultipleTapLabel()
    }
    
    @IBAction func aceptPressed(_ sender: UIButton) {
        
    }
    
    func setupMultipleTapLabel() {
        termsAndConditionsLabel.text = K.Texts.termsAndPrivacy
        let text = (termsAndConditionsLabel.text)!
        let underlineAttriString = NSMutableAttributedString(string: text)
        let termsRange = (text as NSString).range(of: K.Texts.termsAndConditions)
        let privacyRange = (text as NSString).range(of: K.Texts.privacyPolicy)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor(named: K.BrandColors.secundaryColor)!, range: termsRange)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: termsRange)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor(named: K.BrandColors.secundaryColor)!, range: privacyRange)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: privacyRange)
        termsAndConditionsLabel.attributedText = underlineAttriString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel(gesture:)))
        termsAndConditionsLabel.isUserInteractionEnabled = true
        termsAndConditionsLabel.addGestureRecognizer(tapAction)
    }
    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: termsAndConditionsLabel, targetText: K.Texts.termsAndConditions) {
            guard let url = URL(string: K.URLS.termsAndConditions) else { return }
            UIApplication.shared.open(url)
        } else if gesture.didTapAttributedTextInLabel(label: termsAndConditionsLabel, targetText: K.Texts.privacyPolicy) {
            guard let url = URL(string: K.URLS.privacyPolicy) else { return }
            UIApplication.shared.open(url)
        }
    }
}
