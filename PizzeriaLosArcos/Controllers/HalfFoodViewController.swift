//
//  HalfFoodViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 16/01/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class HalfFoodViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: DataSending? = nil
    var cancelHalfFood: Bool = true
    
    var foodType: String?
    
    var foodData = [Food]()
    var food: Food?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: K.Images.cancel)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        guard let foodType = foodType, let currFood = food else {
            return
        }
        
        if foodType.elementsEqual(K.Texts.EGGS_INGREDIENTS_ID) {
            titleLabel.text = "Seleccione el ingrediente"
        }
        
        let nibCell = UINib(nibName: K.Collections.foodCollectionViewCell, bundle: nil)
        collectionView.register(nibCell, forCellWithReuseIdentifier: K.Collections.foodCell)
        
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
                                    if food.id.contains(foodType) && food.id != currFood.id {
                                        self.foodData.append(food)
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }
            }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let delegate = delegate {
            delegate.cancelFood(isTrue: cancelHalfFood)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }

}


extension HalfFoodViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Collections.foodCell, for: indexPath) as! FoodCollectionViewCell
        cell.titleLabel.text = foodData[indexPath.row].title
        if let description = foodData[indexPath.row].description {
            cell.descriptionLabel.text = description
        } else {
            cell.descriptionLabel.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        food = foodData[indexPath.row]
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FoodCollectionViewCell {
            cell.showAnimation {
                if let halfFood = self.food, let delegate = self.delegate {
                    delegate.sendFood(food: halfFood)
                    self.cancelHalfFood = false
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}
