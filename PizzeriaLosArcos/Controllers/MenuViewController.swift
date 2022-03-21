//
//  MenuViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 06/01/22.
//

import UIKit

class MenuViewController: UIViewController {
    
    var foodType: String?
    var foodTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func foodPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            foodType = K.Texts.PIZZA
            foodTitle = K.Texts.PIZZA_TITLE
        case 1:
            foodType = K.Texts.BURGER
            foodTitle = K.Texts.BURGER_TITLE
        case 2:
            foodType = K.Texts.SALAD
            foodTitle = K.Texts.SALAD_TITLE
        case 3:
            foodType = K.Texts.PLATILLO
            foodTitle = K.Texts.PLATILLO_TITLE
        case 4:
            foodType = K.Texts.SEA_FOOD
            foodTitle = K.Texts.SEA_FOOD_TITLE
        case 5:
            foodType = K.Texts.BREAKFAST
            foodTitle = K.Texts.BREAKFAST_TITLE
        case 6:
            foodType = K.Texts.DRINKS
            foodTitle = K.Texts.DRINKS_TITLE
        case 7:
            foodType = K.Texts.DESSERTS
            foodTitle = K.Texts.DESSERTS_TITLE
        case 8:
            foodType = K.Texts.MILKSHAKESICECREAM
            foodTitle = K.Texts.MILKSHAKESICECREAM_TITLE
        case 9:
            foodType = K.Texts.KIDS
            foodTitle = K.Texts.KIDS_TITLE
        default:
            break;
        }
        
        sender.showAnimation {
            self.performSegue(withIdentifier: K.Segues.menuToFoodList, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.menuToFoodList {
            let destinationVC = segue.destination as! FoodListViewController
            destinationVC.foodType = foodType
            destinationVC.foodTitle = foodTitle
        }
    }
    
}
