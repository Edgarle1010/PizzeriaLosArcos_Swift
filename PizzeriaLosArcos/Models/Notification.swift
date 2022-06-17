//
//  Notification.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 25/03/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import SwiftUI

public class Notification: Codable {
    var folio: String?
    var imageURL: String?
    var title: String
    var description: String?
    var options: String?
    var phoneNumber: String
    var viewed: Bool
    var dateSend: Double
    
    init(folio: String?, imageURL: String?, title: String, description: String?, options: String?, phoneNumber: String, viewed: Bool, dateSend: Double) {
        self.folio = folio
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.options = options
        self.phoneNumber = phoneNumber
        self.viewed = viewed
        self.dateSend = dateSend
    }
    
    enum CodingKeys: String, CodingKey {
        case folio
        case imageURL
        case title
        case description
        case options
        case phoneNumber
        case viewed
        case dateSend
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        folio = try values.decodeIfPresent(String.self, forKey: .folio)
        imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
        title = try values.decodeIfPresent(String.self, forKey: .title)!
        description = try values.decodeIfPresent(String.self, forKey: .description)
        options = try values.decodeIfPresent(String.self, forKey: .options)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)!
        viewed = try values.decodeIfPresent(Bool.self, forKey: .viewed)!
        dateSend = try values.decodeIfPresent(Double.self, forKey: .dateSend)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(folio, forKey: .folio)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(viewed, forKey: .viewed)
        try container.encodeIfPresent(dateSend, forKey: .dateSend)
    }
}
