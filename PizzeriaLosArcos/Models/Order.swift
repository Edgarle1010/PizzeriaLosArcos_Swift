//
//  Order.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 15/03/22.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift

public class Order: Codable {
    var folio: String
    var client: String
    var clientName: String
    var complete: Bool
    var status: String
    var date: Double
    var location: String
    var totalPrice: Double
    var items: Int
    var itemList = List<Item>()
    
    init(folio: String, client: String, clientName: String, complete: Bool, status: String, date: Double, location: String, totalPrice: Double, items: Int, itemList: List<Item>) {
        self.folio = folio
        self.client = client
        self.clientName = clientName
        self.complete = complete
        self.status = status
        self.date = date
        self.location = location
        self.totalPrice = totalPrice
        self.items = items
        self.itemList = itemList
    }
    
    enum CodingKeys: String, CodingKey {
        case folio
        case client
        case clientName
        case complete
        case status
        case date
        case location
        case totalPrice
        case items
        case itemList
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        folio = try values.decodeIfPresent(String.self, forKey: .folio)!
        client = try values.decodeIfPresent(String.self, forKey: .client)!
        clientName = try values.decodeIfPresent(String.self, forKey: .clientName)!
        complete = try values.decodeIfPresent(Bool.self, forKey: .complete)!
        status = try values.decodeIfPresent(String.self, forKey: .status)!
        date = try values.decodeIfPresent(Double.self, forKey: .date)!
        location = try values.decodeIfPresent(String.self, forKey: .location)!
        totalPrice = try values.decodeIfPresent(Double.self, forKey: .totalPrice)!
        items = try values.decodeIfPresent(Int.self, forKey: .items)!
        itemList = try values.decodeIfPresent(List<Item>.self, forKey: .itemList)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(folio, forKey: .folio)
        try container.encodeIfPresent(client, forKey: .client)
        try container.encodeIfPresent(clientName, forKey: .clientName)
        try container.encodeIfPresent(complete, forKey: .complete)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(totalPrice, forKey: .totalPrice)
        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(itemList, forKey: .itemList)
    }
    
}
