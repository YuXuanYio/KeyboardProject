//
//  QuestionSet.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 5/1/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class QuestionSet: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var questions = [Question]()
    var randomized: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case questions
        case randomized
    }
}
