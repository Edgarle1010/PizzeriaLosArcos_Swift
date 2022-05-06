//
//  FoodListViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 11/01/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class FoodListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var foodType: String?
    var foodTitle: String?
    
    var foodList: [Food] = []
    var food: Food?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let foodType = foodType, let foodTitle = foodTitle else {
            return
        }
        
        navigationItem.title = foodTitle
        
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
                                if (food.id.contains(foodType)) {
                                    self.foodList.append(food)
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
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segues.foodListToOrderDetails {
            let destinationVC = segue.destination as! OrderDetailsViewController
            destinationVC.food = food
            destinationVC.foodType = foodType
        }
    }
    
}


extension FoodListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Collections.foodCell, for: indexPath) as! FoodCollectionViewCell
        cell.titleLabel.text = foodList[indexPath.row].title
        if let description = foodList[indexPath.row].description {
            if !description.isEmpty {
                cell.descriptionLabel.text = description
            } else {
                cell.descriptionLabel.isHidden = true
            }
        } else {
            cell.descriptionLabel.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        food = foodList[indexPath.row]
        
        if let cell = collectionView.cellForItem(at: indexPath) as? FoodCollectionViewCell {
            cell.showAnimation {
                self.performSegue(withIdentifier: K.Segues.foodListToOrderDetails, sender: self)
            }
        }
        
        
    }
    
    
}
