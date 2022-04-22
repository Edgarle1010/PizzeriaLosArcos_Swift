//
//  ShoppingCarViewController.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 08/01/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import RealmSwift
import ProgressHUD
import SwipeCellKit
import CoreLocation
import AudioToolbox

class ShoppingCarViewController: UIViewController {
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    let locationManager = CLLocationManager()
    
    var items: Results<Item>?
    let realm = try! Realm()
    
    var totalSum: Double?
    var messageStatus: String?
    var currUserLocation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        totalView.dropShadow()
        totalView.layer.cornerRadius = 12
        totalView.layer.masksToBounds = true;
        
        tableView.register(UINib(nibName: K.Collections.itemTableViewCell, bundle: nil), forCellReuseIdentifier: K.Collections.itemCell)
        
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        self.locationManager.requestLocation()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if items!.isEmpty {
            alert(title: K.Texts.listEmpty, message: nil)
        } else {
            if Reachability.isConnectedToNetwork() {
                if let user = Auth.auth().currentUser {
                    waitTime { waitTime in
                        if let waitTime = waitTime {
                            let alert = UIAlertController(title: K.Texts.questionOrder, message: "Tiempo de espera promedio: \(String(describing: waitTime)) minutos", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Sí", style: .cancel, handler: { action in
                                self.banedStatus { isBaned in
                                    if isBaned! {
                                        self.alert(title: K.Texts.problemOcurred, message: K.Texts.suspendedAccount)
                                    } else {
                                        self.checkService { activeService in
                                            if !activeService {
                                                self.alert(title: K.Texts.outOfService, message: self.messageStatus)
                                            } else {
                                                self.getOrderID { folio in
                                                    let itemList = List<Item>()
                                                    itemList.append(objectsIn: self.realm.objects(Item.self))
                                                    
                                                    let dateRequest = Date().timeIntervalSince1970
                                                    let dateEstimatedDelivery = Date(timeIntervalSince1970: dateRequest).addingTimeInterval(Double(waitTime) * 60).timeIntervalSince1970
                                                    
                                                    let order = Order(folio: folio, client: user.phoneNumber!, clientName: user.displayName!, complete: false, status: "Pedido", dateRequest: dateRequest, dateEstimatedDelivery: dateEstimatedDelivery, dateProcessed: 0.0, dateFinished: 0.0, dateDelivered: 0.0, dateCanceled: 0.0, location: self.currUserLocation ?? "Ubicación no proporcionada", totalPrice: self.totalSum!, items: self.items!.count, itemList: itemList)
                                                    
                                                    self.addOrder(order, folio, waitTime)
                                                }
                                            }
                                        }
                                    }
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    self.alert(title: K.Texts.guestMode, message: K.Texts.guestFunctionsMessage)
                }
            } else {
                self.alert(title: "¡Ha ocurrido un problema!", message: "Revisa tu conexión a internet y vuelve a intentar")
            }
        }
    }
    
    func waitTime(completion: @escaping (Int?) -> Void) {
        ProgressHUD.show()
        db.collection(K.Firebase.waitTimeCollection).document(K.Firebase.time).getDocument { (document, error) in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    if let waitTime = data?[K.Firebase.time] as? Int {
                        completion(waitTime)
                    }
                } else {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error!.localizedDescription)
                }
            }
        }
    }
    
    func banedStatus(completion: @escaping (Bool?) -> Void) {
        ProgressHUD.show()
        if let phoneNumber = Auth.auth().currentUser?.phoneNumber {
            db.collection(K.Firebase.userCollection).whereField(K.Firebase.phoneNumberField, isEqualTo: phoneNumber)
                .getDocuments { (querySnapshot, error) in
                    ProgressHUD.dismiss()
                    if let error = error {
                        self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
                    } else {
                        if let documents = querySnapshot?.documents {
                            if documents.count != 0 {
                                for doc in documents {
                                    let data = doc.data()
                                    if let isBaned = data[K.Firebase.baned] as? Bool {
                                        completion(isBaned)
                                    }
                                }
                            } else {
                                self.alert(title: "¡Ha ocurrido un problema!", message: "No hay ningún usuario registrado con este número")
                            }
                        }
                    }
                }
        }
    }
    
    func checkService(completion: @escaping (Bool) -> Void) {
        ProgressHUD.show()
        db.collection(K.Firebase.messageCollection).document(K.Firebase.current).getDocument { document, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    if let messageStatus = data?[K.Firebase.message] as? String,
                       let activeStatus = data?[K.Firebase.status] as? Bool {
                        self.messageStatus = messageStatus
                        completion(activeStatus)
                    }
                } else {
                    self.alert(title: "¡Ha ocurrido un problema!", message: error!.localizedDescription)
                }
            }
        }
    }
    
    func getOrderID(completion: @escaping (String) -> Void) {
        ProgressHUD.show()
        db.collection(K.Firebase.ordersCollection).getDocuments { querySnapshot, error in
            ProgressHUD.dismiss()
            if let error = error {
                self.alert(title: "¡Ha ocurrido un problema!", message: error.localizedDescription)
            } else {
                if let documents = querySnapshot {                    
                    completion("F\(documents.count + 1)")
                }
            }
        }
    }
    
    func addOrder(_ order: Order, _ folio: String, _ waitTime: Int) {
        ProgressHUD.show()
        do {
            ProgressHUD.dismiss()
            let _ = try db.collection(K.Firebase.ordersCollection).document(folio).setData(from: order)
            
            AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate) {
            }
            
            try! realm.write {
                realm.deleteAll()
                loadItems()
            }
            
            self.alert(title: K.Texts.orderSentSuccessfullyTitle, message: String(format: K.Texts.orderSuccessfullyMessage, waitTime, folio))
        }
        catch {
            print(error)
        }
    }
    
    func loadItems() {
        items = realm.objects(Item.self)
        
        tableView.reloadData()
        refreshPrice()
    }
    
    func refreshPrice() {
        if let items = items {
            totalSum = items.map({$0.price}).reduce(0, +)
            totalLabel.text = "Total: $\(String(format: "%.2f", ceil((totalSum ?? 0)*100)/100))"
        }
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
}


extension ShoppingCarViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Collections.itemCell, for: indexPath) as! ItemTableViewCell
        if let item = items?[indexPath.row] {
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
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: K.Texts.delete) { action, indexPath in
            if let item = self.items?[indexPath.row] {
                do {
                    try self.realm.write{
                        self.realm.delete(item)
                        self.refreshPrice()
                    }
                } catch {
                    print("Error deleting item, \(error)")
                }
            }
        }
        
        deleteAction.image = UIImage(named: K.Images.delete)
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}

//MARK: - CLLocationManagerDelegate

extension ShoppingCarViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            currUserLocation = "\(lat), \(lon)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
