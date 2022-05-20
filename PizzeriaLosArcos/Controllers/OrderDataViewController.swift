//
//  OrderDataViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 13/05/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import ProgressHUD

class OrderDataViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var folioLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateRequestLabel: UILabel!
    @IBOutlet weak var dateProcessedLabel: UILabel!
    @IBOutlet weak var dateFinishedLabel: UILabel!
    @IBOutlet weak var titleDateCanceledLabel: UILabel!
    @IBOutlet weak var dateDeliveredLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var order: Order?
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadViews()
        
        tableView.register(UINib(nibName: K.Collections.itemTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.itemCell)
        tableView.rowHeight = UITableView.automaticDimension
        
        guard let order = order else {
            return
        }
        
        loadOrderDetails(order)
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func loadViews() {
        let backButtonImage = UIImage(named: K.Images.back)
        let backButtonTintedImage = backButtonImage?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backButtonTintedImage, for: .normal)
        backButton.tintColor = UIColor.init(named: K.BrandColors.primaryColor)
    }
    
    func loadOrderDetails(_ order: Order) {
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection)
            .whereField(K.Firebase.folio, isEqualTo: order.folio)
            .addSnapshotListener { querySnapshot, error in
                ProgressHUD.dismiss()
                self.items = []
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
                                self.folioLabel.text = order.folio
                                
                                let timeRequest = order.dateRequest
                                let timeProcessed = order.dateProcessed ?? 0.0
                                let timeFinished = order.dateFinished ?? 0.0
                                let timeDelivered = order.dateDelivered ?? 0.0
                                let timeCanceled = order.dateCanceled ?? 0.0
                                
                                let dateRequest = Date(timeIntervalSince1970: timeRequest)
                                let dateProcessed = Date(timeIntervalSince1970: timeProcessed)
                                let dateFinished = Date(timeIntervalSince1970: timeFinished)
                                let dateDelivered = Date(timeIntervalSince1970: timeDelivered)
                                let dateCenceled = Date(timeIntervalSince1970: timeCanceled)
                                
                                let dateFormatterGet = DateFormatter()
                                dateFormatterGet.timeZone = TimeZone.current
                                dateFormatterGet.locale = NSLocale.current
                                dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone.current
                                dateFormatter.locale = NSLocale.current
                                dateFormatter.dateFormat = "h:mm a"
                                dateFormatter.amSymbol = "AM"
                                dateFormatter.pmSymbol = "PM"
                                
                                self.dateLabel.text = "Fecha del pedido: \(dateFormatterGet.string(from: dateRequest))"
                                self.dateRequestLabel.text = "\(dateFormatter.string(from: dateRequest))"
                                if timeProcessed != 0.0 {
                                    self.dateProcessedLabel.text = "\(dateFormatter.string(from: dateProcessed))"
                                } else {
                                    self.dateProcessedLabel.text = ""
                                }
                                if timeFinished != 0.0 {
                                    self.dateFinishedLabel.text = "\(dateFormatter.string(from: dateFinished))"
                                } else {
                                    self.dateFinishedLabel.text = ""
                                }
                                if timeDelivered != 0.0 {
                                    self.dateDeliveredLabel.text = "\(dateFormatter.string(from: dateDelivered))"
                                } else {
                                    self.dateDeliveredLabel.text = ""
                                }
                                if timeCanceled != 0.0 {
                                    self.titleDateCanceledLabel.text = "Hora de cancelación:"
                                    self.dateDeliveredLabel.text = "\(dateFormatter.string(from: dateCenceled))"
                                }
                                
                                self.statusLabel.text = order.status
                                self.totalLabel.text = "Total: $\(String(format: "%.2f", ceil((order.totalPrice)*100)/100))"
                                self.items = Array(order.itemList)
                                
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
    
    func alert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: K.Texts.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }

}


// MARK: - UITableViewDelagete && DataSource

extension OrderDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.itemCell, for: indexPath) as! ItemTableViewCell
        let item = items[indexPath.row]
        let id = item.id
        let title = item.title
        if id.contains(K.Texts.BURGER)
            || id.contains(K.Texts.SALAD)
            || id.contains(K.Texts.PLATILLO)
            || id.contains(K.Texts.BREAKFAST)
            || id.contains(K.Texts.DRINKS) {
            if title.contains("naranja")
                || title.contains("Limonada")
                || title.contains("Chocolate") {
                cell.titleLabel.text = "\(item.title) | \(item.size)"
            } else {
                cell.titleLabel.text = item.title
            }
        } else if id.contains(K.Texts.DESSERTS)
                    || id.contains(K.Texts.MILKSHAKE_ID)
                    || id.contains(K.Texts.KIDS) {
            cell.titleLabel.text = item.title
        } else {
            cell.titleLabel.text = "\(item.title) | \(item.size)"
        }
        
        if item.extraIngredientList.isEmpty {
            cell.extraIngredientView.isHidden = true
        } else {
            cell.extraIngredientsLabel.text = item.extraIngredientList.map {($0["title"] as? String) ?? nil}.compactMap({$0}).joined(separator: "\n")
        }
        
        if let comments = item.comments {
            if !comments.isEmpty {
                cell.commentsLabel.text = comments
            } else {
                cell.commentsView.isHidden = true
            }
        }
        
        cell.amountLabel.text = String(item.amount)
        cell.totalLabel.text = "$\(String(format: "%.2f", ceil(item.price*100)/100))"
        
        
        return cell
    }
    
}

