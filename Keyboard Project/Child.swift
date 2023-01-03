//
//  Child.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 3/1/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class Child: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var gender: String?
    var yearLevel: Int?
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case gender
        case yearLevel
        case date
    }
}

enum Gender: Int {
    case female = 0
    case male = 1
    case others = 2
}
