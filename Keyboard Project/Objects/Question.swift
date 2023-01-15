//
//  Questions.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 26/12/2022.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class Question: NSObject, Codable {
    
    @DocumentID var id: String?
    var question: String?
    var answer: Int?
    var isSelected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
        case isSelected
    }
}
