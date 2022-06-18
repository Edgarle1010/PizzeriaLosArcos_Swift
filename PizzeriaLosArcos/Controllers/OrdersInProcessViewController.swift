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
        
        tableView.register(UINib(nibName: K.Collections.orderTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.orderCell)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        if let user = Auth.auth().currentUser?.phoneNumber {
            ProgressHUD.show()
            db.collection(K.Firebase.ordersCollection)
                .whereField(K.Firebase.client, isEqualTo: user)
                .addSnapshotListener { querySnapshot, error in
                    ProgressHUD.dismiss()
                    self.ordersList = []
                    if let error = error {
                        self.alert(title: K.Texts.problemOcurred, message: error.localizedDescription)
                    } else {
                        if let documents = querySnapshot?.documents {
                            for doc in documents {
                                let result = Result {
                                    try doc.data(as: Order.self)
                                }
                                switch result {
                                case .success(let order):
                                    if !order.complete {
                                        self.ordersList.append(order)
                                    }
                                case .failure(let error):
                                    print("Error decoding food: \(error)")
                                }
                            }
                            
                            DispatchQueue.main.async {
                                UIView.transition(with: self.tableView, duration: 0.6, options: .transitionCrossDissolve, animations: {
                                    self.tableView.reloadData()
                                }, completion: nil)
                            }
                        }
                    }
                }
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
}

//MARK: - TableView Delegate and DataSource

extension OrdersInProcessViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.ordersList.count == 0 {
            self.tableView.setEmptyView(title: "No tienes pedidos en proceso", message: "Aquí se mostrarán solo las ordenes que tengas en proceso.")
        } else {
            self.tableView.restore()
        }
        
        return ordersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.orderCell, for: indexPath) as! OrderTableViewCell
        
        let currOrder = ordersList[indexPath.row]
        
        cell.folioLabel.text = currOrder.folio
        cell.priceLabel.text = "$\(currOrder.totalPrice)"
        
        let timeRequest = currOrder.dateRequest
        let timeEstimatedDelivery = currOrder.dateEstimatedDelivery
        let timeProcessed = currOrder.dateProcessed ?? 0.0
        let timeFinished = currOrder.dateFinished ?? 0.0
        let timeDelivered = currOrder.dateDelivered ?? 0.0
        
        let dateRequest = Date(timeIntervalSince1970: timeRequest)
        let dateEstimatedDelivery = Date(timeIntervalSince1970: timeEstimatedDelivery)
        let dateProcessed = Date(timeIntervalSince1970: timeProcessed)
        let dateFinished = Date(timeIntervalSince1970: timeFinished)
        let dateDelivered = Date(timeIntervalSince1970: timeDelivered)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        cell.timeRequest.text = "\(dateFormatter.string(from: dateRequest))"
        if timeProcessed != 0.0 {
            cell.timeProcessed.text = "\(dateFormatter.string(from: dateProcessed))"
        } else {
            cell.timeProcessed.text = ""
        }
        if timeFinished != 0.0 {
            cell.timeFinished.text = "\(dateFormatter.string(from: dateFinished))"
        } else {
            cell.timeFinished.text = ""
        }
        if timeDelivered != 0.0 {
            cell.timeDelivered.text = "\(dateFormatter.string(from: dateDelivered))"
        } else {
            cell.timeDelivered.text = ""
        }
        
        cell.progressView.progress = Float(currOrder.getStatus(currOrder.status))
        
        cell.timeStimatedCompletion.text = "\(dateFormatter.string(from: dateEstimatedDelivery))"
    
        return cell
    }
    
    
}
