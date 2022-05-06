//
//  OrderDetailsViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 14/01/22.
//

import UIKit
import BonsaiController
import RealmSwift
import AudioToolbox
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class OrderDetailsViewController: UIViewController, UITextFieldDelegate, DataSending, ExtraIngredientCollectionViewCellDelegate {
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var conditionView: UIStackView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var halfButton: UIButton!
    
    @IBOutlet weak var iceCreamView: UIStackView!
    @IBOutlet weak var withOutCreamBotton: UIButton!
    @IBOutlet weak var withIcreamButton: UIButton!
    
    @IBOutlet weak var orderTypeView: UIStackView!
    @IBOutlet weak var completeOrderButton: UIButton!
    @IBOutlet weak var halfOrderButton: UIButton!
    
    @IBOutlet weak var sizeView: UIStackView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var bigButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var smallButton: UIButton!
    
    @IBOutlet weak var flavorsView: UIStackView!
    @IBOutlet weak var flavorsPickerView: UIPickerView!
    
    @IBOutlet weak var fillingView: UIStackView!
    @IBOutlet weak var hashButton: UIButton!
    @IBOutlet weak var chickenButton: UIButton!
    @IBOutlet weak var cheeseButton: UIButton!
    
    @IBOutlet weak var styleView: UIStackView!
    @IBOutlet weak var crashedButton: UIButton!
    @IBOutlet weak var scrambledButton: UIButton!
    
    @IBOutlet weak var chilaquilesView: UIStackView!
    @IBOutlet weak var chilaquilesLabel: UILabel!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    
    @IBOutlet weak var breadView: UIStackView!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var wholemealButton: UIButton!
    @IBOutlet weak var baguetteButton: UIButton!
    
    @IBOutlet weak var extraIngredientView: UIStackView!
    @IBOutlet weak var extraIngredientCollectionView: UICollectionView!
    @IBOutlet weak var addExtraIngredientStackView: UIStackView!
    
    @IBOutlet weak var amountButton: UIButton!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    
    let realm = try! Realm()
    var items: Results<Item>?
    
    let db = Firestore.firestore()
    
    var currView = UIView()
    
    var food: Food?
    var foodType: String?
    
    var isComplete = true
    var size = 0
    var extraIngredientList = List<ExtraIngredient>()
    var amount = 1
    var price: Double = 0
    
    var halfFood: Food?
    var filling: String?
    var isHalfOrder = true
    var chilaquiles: String?
    var bread: String?
    
    var drinkList: [Food] = []
    var currDrink: Food?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let food = food else {
            return
        }
        
        commentsTextView.dropShadow()
        commentsTextView.layer.cornerRadius = 12
        commentsTextView.layer.masksToBounds = true;
        
        let nibCell = UINib(nibName: K.Collections.extraIngredientCollectionViewCell, bundle: nil)
        extraIngredientCollectionView.register(nibCell, forCellWithReuseIdentifier: K.Collections.extraIngredientCell)
        
        loadCurrentView(food)
        
        refreshView(food)
    }
    
    func sendFood(food: Food) {
        halfFood = food
        isComplete = false
    }
    
    func cancelFood(isTrue: Bool) {
        if isTrue {
            completeButton.sendActions(for: .touchUpInside)
            halfFood = nil
            isComplete = true
        }
        refreshView(food!)
    }
    
    func sendExtraIngredient(extraIngredient: ExtraIngredient) {
        extraIngredientList.append(extraIngredient)
        refreshView(food!)
    }
    
    func sendAmount(amount: Int) {
        self.amount = amount
        refreshView(food!)
    }
    
    func didPressButton(_ tag: Int) {
        extraIngredientList.remove(at: tag)
        refreshView(food!)
    }
    
    func refreshView(_ food: Food) {
        var description: String?
        var extraIngredientPrice: Double = 0
        
        amountButton.setTitle(String(amount), for: .normal)
        
        if let halfFood = halfFood {
            if food.id.contains(K.Texts.BREAKFAST) {
                navigationItem.title = "\(food.title) | Revueltos \(halfFood.title)"
                description = food.description
            } else if food.id.contains(K.Texts.DESSERTS) {
                navigationItem.title = "\(food.title) | Con nieve de \(halfFood.title)"
                description = food.description
            } else {
                let halfFoodTitle = halfFood.title.replacingOccurrences(of: K.Texts.PIZZA_SUBTITLE, with: "")
                navigationItem.title = "\(food.title) / \(halfFoodTitle)"
                
                if food.description == nil && halfFood.description == nil {
                    description = nil
                } else {
                    var fDescription = food.description
                    if fDescription == nil {
                        fDescription = food.title
                    }
                    
                    var hDescription = halfFood.description
                    if hDescription == nil {
                        hDescription = halfFood.title
                    }
                    
                    description = "\(fDescription!) / \(hDescription!)"
                }
            }
        } else {
            if food.id.contains(K.Texts.BREAKFAST) {
                if let currDescription = food.description {
                    if currDescription.contains("revueltos o estrellados") {
                        navigationItem.title = "\(food.title) | Estrellados"
                    } else {
                        navigationItem.title = food.title
                    }
                } else {
                    navigationItem.title = food.title
                }
            } else {
                navigationItem.title = food.title
                isComplete = true
            }
            
            description = food.description
        }
        
        if let description = description {
            if !description.isEmpty {
                descriptionView.isHidden = false
                descriptionLabel.text = description
            } else {
                descriptionView.isHidden = true
            }
        } else {
            descriptionView.isHidden = true
        }
        
        if !isHalfOrder {
            price = Double(food.getPrice(size)) * 0.7
        } else {
            price = Double(food.getPrice(size))
        }
        
        if !isComplete {
            if let halfFood = halfFood {
                if halfFood.id.contains(K.Texts.EGGS_INGREDIENTS_ID)
                    || halfFood.id.contains(K.Texts.ICECREAM_ID) {
                    price = price + Double(halfFood.getPrice(3))
                } else {
                    price = (price + Double(halfFood.getPrice(size))) / 2
                }
            }
        }
        
        if let currDrink = currDrink {
            price = Double(currDrink.getPrice(size))
        }
        
        extraIngredientCollectionView.reloadData()
        extraIngredientCollectionView.layoutIfNeeded()
        
        for extra in extraIngredientList {
            extraIngredientPrice += Double(extra.getPrice(size))
        }
        
        if extraIngredientList.count < 3 {
            addExtraIngredientStackView.isHidden = false
        } else {
            addExtraIngredientStackView.isHidden = true
        }
        
        price = (price + extraIngredientPrice) * Double(amount)
        
        totalLabel.text = "Total: $\(String(format: "%.2f", ceil(price*100)/100))"
        
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.init(named: K.BrandColors.primaryColor)
        label.text = navigationItem.title
        self.navigationItem.titleView = label
    }
    
    @IBAction func conditionChanged(_ sender: UIButton) {
        completeButton.backgroundColor = UIColor.clear
        halfButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        if sender.tag == 1 {
            performSegue(withIdentifier: K.Segues.orderDetailsToHalfFood, sender: self)
        } else {
            navigationItem.title = food!.title
            halfFood = nil
            refreshView(food!)
        }
    }
    
    @IBAction func iceCreamChanged(_ sender: UIButton) {
        withOutCreamBotton.backgroundColor = UIColor.clear
        withIcreamButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        if sender.tag == 1 {
            foodType = K.Texts.ICECREAM_FOOD_TYPE
            performSegue(withIdentifier: K.Segues.orderDetailsToHalfFood, sender: self)
        } else {
            navigationItem.title = food!.title
            halfFood = nil
            refreshView(food!)
        }
    }
    
    @IBAction func orderTypeChanged(_ sender: UIButton) {
        completeOrderButton.backgroundColor = UIColor.clear
        halfOrderButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        if sender.tag == 1 {
            isHalfOrder = false
        } else {
            isHalfOrder = true
        }
        
        refreshView(food!)
    }
    
    @IBAction func sizeChanged(_ sender: UIButton) {
        bigButton.backgroundColor = UIColor.clear
        mediumButton.backgroundColor = UIColor.clear
        smallButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        size = sender.tag
        
        refreshView(food!)
    }
    
    @IBAction func fillingChanged(_ sender: UIButton) {
        hashButton.backgroundColor = UIColor.clear
        chickenButton.backgroundColor = UIColor.clear
        cheeseButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        filling = sender.currentTitle
        
        refreshView(food!)
    }
    
    @IBAction func styleChanged(_ sender: UIButton) {
        crashedButton.backgroundColor = UIColor.clear
        scrambledButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        if sender.tag == 1 {
            foodType = K.Texts.EGGS_INGREDIENTS_ID
            performSegue(withIdentifier: K.Segues.orderDetailsToHalfFood, sender: self)
        } else {
            navigationItem.title = food!.title
            halfFood = nil
            refreshView(food!)
        }
    }
    
    @IBAction func chilaquilesChanged(_ sender: UIButton) {
        redButton.backgroundColor = UIColor.clear
        greenButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        chilaquiles = sender.currentTitle
    }
    
    @IBAction func breadChanged(_ sender: UIButton) {
        whiteButton.backgroundColor = UIColor.clear
        wholemealButton.backgroundColor = UIColor.clear
        baguetteButton.backgroundColor = UIColor.clear
        
        sender.backgroundColor = UIColor.init(named: K.BrandColors.thirdColor)
        
        bread = sender.currentTitle
    }
    
    
    @IBAction func addExtraIngredientPressed(_ sender: UIButton) {
        currView = addExtraIngredientStackView
        
        if food!.id.contains(K.Texts.BREAKFAST) {
            foodType = K.Texts.BREAKFAST
        }
        
        performSegue(withIdentifier: K.Segues.orderDetailsToExtraIngredient, sender: self)
    }
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @IBAction func amountPressed(_ sender: UIButton) {
        currView = amountButton
        performSegue(withIdentifier: K.Segues.orderDetailsToAmount, sender: self)
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        let item = Item()
        
        item.id = food!.id
        
        item.title = navigationItem.title!
        
        if let filling = filling {
            item.title = "\(navigationItem.title!) | \(filling)"
        }
        
        if let chilaquiles = chilaquiles {
            item.title += " | \(chilaquilesLabel.text!) \(chilaquiles)"
        }
        
        if let bread = bread {
            item.title += " | Pan \(bread)"
        }
        
        if !isHalfOrder {
            item.title += " | \(halfOrderButton.currentTitle!)"
        }
        
        if let currDrink = currDrink {
            item.title += " | \(currDrink.title)"
        }
        
        item.isComplete = isComplete
        item.extraIngredientList = extraIngredientList
        item.size = food!.getSize(size)
        item.amount = amount
        item.comments = commentsTextView.text
        item.price = price
        
        save(item)
        
        AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate) {
        }
        
        let alert = UIAlertController(title: nil, message: "¡Producto agregado correctamente!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: TabBarController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
    func loadCurrentView(_ food: Food) {
        let id = food.id
        if id.contains(K.Texts.BURGER)
            || id.contains(K.Texts.SALAD)
            || id.contains(K.Texts.PLATILLO) {
            conditionView.isHidden = true
            sizeView.isHidden = true
            
            if id.contains(K.Texts.HOTDOG_ID) {
                foodType = K.Texts.HOTDOG_FOOD_TYPE
            } else if id.contains(K.Texts.ENCHILADAS_ID) {
                fillingView.isHidden = false
                filling = hashButton.currentTitle
                foodType = K.Texts.ENCHILADAS_FOOD_TYPE
            }
            
        } else if id.contains(K.Texts.SEA_FOOD) {
            conditionView.isHidden = true
            if id.elementsEqual(K.Texts.SHRIMP_ID) {
                mediumButton.isHidden = true
                foodType = K.Texts.SHRIMP_FOOD_TYPE
            } else if id.elementsEqual(K.Texts.FISH_STEAK_ID) {
                mediumButton.isHidden = true
                foodType = K.Texts.FISH_STEAK_FOOD_TYPE
            } else {
                sizeView.isHidden = true
                if id.contains(K.Texts.FISH_STEAK_TITLE) {
                    foodType = K.Texts.FISH_STEAK_FOOD_TYPE
                } else {
                    foodType = K.Texts.RANCH_SHRIMP_FOOD_TYPE
                }
            }
        } else if id.contains(K.Texts.BREAKFAST) {
            conditionView.isHidden = true
            sizeView.isHidden = true
            
            orderTypeView.isHidden = false
            breadView.isHidden = false
            bread = whiteButton.currentTitle
            isHalfOrder = true
            
            if let currDescription = food.description {
                if currDescription.contains("revueltos o estrellados") {
                    styleView.isHidden = false
                    foodType = K.Texts.EGGS_INGREDIENTS_ID
                }
                
                if currDescription.contains("chilaquiles") {
                    chilaquilesView.isHidden = false
                    chilaquiles = "Rojos"
                }
                
                if currDescription.contains("enchiladas") {
                    chilaquilesView.isHidden = false
                    chilaquilesLabel.text = "Enchiladas"
                    redButton.setTitle("Rojas", for: .normal)
                    chilaquiles = redButton.currentTitle
                    
                    fillingView.isHidden = false
                    filling = hashButton.currentTitle
                }
            }
        } else if id.contains(K.Texts.DRINKS)
                    || id.contains(K.Texts.MILKSHAKESICECREAM)
                    || id.contains(K.Texts.KIDS) {
            conditionView.isHidden = true
            extraIngredientView.isHidden = true
            
            if id == K.Texts.SODA_ID
                || id == K.Texts.FUZETEA_ID
                || id == K.Texts.SMOOTHIE_ID
                || id == K.Texts.MILKSHAKE_ID
                || id == K.Texts.ICECREAM_FOOD_ID {
                sizeView.isHidden = true
                flavorsView.isHidden = false
                
                if id == K.Texts.SODA_ID {
                    foodType = K.Texts.SODA_FOOD_TYPE
                } else if id == K.Texts.FUZETEA_ID {
                    foodType = K.Texts.FUZETEA_FOOD_TYPE
                } else if id == K.Texts.SMOOTHIE_ID {
                    foodType = K.Texts.SMOOTHIE_FOOD_TYPE
                } else if id == K.Texts.MILKSHAKE_ID {
                    foodType = K.Texts.MILKSHAKE_FOOD_TYPE
                } else if id == K.Texts.ICECREAM_FOOD_ID {
                    sizeView.isHidden = false
                    foodType = K.Texts.ICECREAM_FOOD_TYPE
                }
                
                guard let foodType = foodType else {
                    return
                }
                
                ProgressHUD.show()
                db.collection(K.Firebase.foodCollection).order(by: K.Firebase.listPosition)
                    .getDocuments { (querySnapshot, error) in
                        ProgressHUD.dismiss()
                        if let error = error {
                            self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                        } else {
                            if let documents = querySnapshot?.documents {
                                for doc in documents {
                                    let result = Result {
                                        try doc.data(as: Food.self)
                                    }
                                    switch result {
                                    case .success(let food):
                                        if food.id.contains(foodType) {
                                            self.drinkList.append(food)
                                        }
                                    case .failure(let error):
                                        print("Error decoding food: \(error)")
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.flavorsPickerView.reloadAllComponents()
                                    self.currDrink = self.drinkList[0]
                                    self.refreshView(food)
                                }
                            }
                        }
                    }
            } else if food.title.contains("naranja")
                        || food.title.contains("Limonada") {
                mediumButton.isHidden = true
                bigButton.setTitle("Jarra", for: .normal)
                smallButton.setTitle("Vaso", for: .normal)
            } else if food.title.contains("Chocolate") {
                sizeLabel.text = "Temperatura"
                mediumButton.isHidden = true
                bigButton.setTitle("Caliente", for: .normal)
                smallButton.setTitle("Frío", for: .normal)
            } else {
                sizeView.isHidden = true
            }
        } else if id.contains(K.Texts.DESSERTS) {
            conditionView.isHidden = true
            sizeView.isHidden = true
            extraIngredientView.isHidden = true
            
            iceCreamView.isHidden = false
        }
    }
    
    //Mark: - Data Manipulation Methods
    func save(_ item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let foodType = foodType else {
            return
        }
        
        if segue.identifier == K.Segues.orderDetailsToHalfFood {
            let destinationVC = segue.destination as! HalfFoodViewController
            destinationVC.delegate = self
            destinationVC.foodType = foodType
            destinationVC.food = food
        }
        
        if segue.identifier == K.Segues.orderDetailsToExtraIngredient {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
            let destinationVC = segue.destination as! ExtraIngredientViewController
            destinationVC.delegate = self
            destinationVC.foodType = foodType
            destinationVC.foodSize = size
            destinationVC.currExtraIngredientList = extraIngredientList
        }
        
        if segue.identifier == K.Segues.orderDetailsToAmount {
            segue.destination.transitioningDelegate = self
            segue.destination.modalPresentationStyle = .custom
            let destinationVC = segue.destination as! AmountViewController
            destinationVC.delegate = self
        }
    }
}


extension OrderDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return extraIngredientList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Collections.extraIngredientCell, for: indexPath) as! ExtraIngredientCollectionViewCell
        cell.titleLabel.text = "\(extraIngredientList[indexPath.row].title) $\(extraIngredientList[indexPath.row].getPrice(size))"
        cell.cancelButton.tag = indexPath.row
        cell.cellDelegate = self
        return cell
    }
    
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
}


// MARK: UIPickerView Delegation

extension OrderDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinkList.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drinkList[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: drinkList[row].title, attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(named: K.BrandColors.primaryColor) as Any])
        return attributedString
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currDrink = drinkList[row]
        
        refreshView(food!)
    }
    
}


extension OrderDetailsViewController: BonsaiControllerDelegate {
    
    // return the frame of your Bonsai View Controller
    func frameOfPresentedView(in containerViewFrame: CGRect) -> CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: containerViewFrame.height / 4), size: CGSize(width: containerViewFrame.width, height: containerViewFrame.height / (3/1)))
    }
    
    // return a Bonsai Controller with SlideIn or Bubble transition animator
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        /// With Background Color ///
        
        // Slide animation from .left, .right, .top, .bottom
        //return BonsaiController(fromDirection: .bottom, backgroundColor: UIColor(white: 0, alpha: 0.5), presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        return BonsaiController(fromView: currView, backgroundColor: UIColor(white: 0, alpha: 0.5), presentedViewController: presented, delegate: self)
        
        
        /// With Blur Style ///
        
        // Slide animation from .left, .right, .top, .bottom
        //return BonsaiController(fromDirection: .bottom, blurEffectStyle: .light, presentedViewController: presented, delegate: self)
        
        // or Bubble animation initiated from a view
        //return BonsaiController(fromView: yourOriginView, blurEffectStyle: .dark,  presentedViewController: presented, delegate: self)
    }
}
