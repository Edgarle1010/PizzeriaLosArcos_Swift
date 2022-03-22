//
//  OrdersInProcessViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 21/03/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class OrdersInProcessViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var ordersList: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: K.Images.back)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(tintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
        
        tableView.register(UINib(nibName: K.Collections.orderTebleViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.orderCell)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ProgressHUD.show()
        if let user = Auth.auth().currentUser?.phoneNumber {
            db.collection(K.Firebase.ordersCollection)
                .whereField(K.Firebase.client, isEqualTo: user)
                .getDocuments { querySnapshot, error in
                    ProgressHUD.dismiss()
                    self.ordersList = []
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                    } else {
                        if let documents = querySnapshot?.documents {
                            for doc in documents {
                                let result = Result {
                                    try doc.data(as: Order.self)
                                }
                                switch result {
                                case .success(let order):
                                    self.ordersList.append(order)
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                
        }
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
}

//MARK: - TableView Delegate and DataSource

extension OrdersInProcessViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersList.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.orderCell, for: indexPath) as! OrderTableViewCell
        
        let currOrder = ordersList[indexPath.row]
        
        cell.folioLabel.text = currOrder.folio
        cell.priceLabel.text = "$\(currOrder.totalPrice)"
    
        return cell
    }
    
    
}
