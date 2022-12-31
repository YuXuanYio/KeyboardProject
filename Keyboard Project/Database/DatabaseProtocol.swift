//
//  DatabaseProtocol.swift
//  Lab03
//
//  Created by Michael Wybrow on 20/3/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case questions
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onQuestionsChange(change: DatabaseChange, questions: [Questions])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addQuestion(question: String, answer: Int)
    func deleteQuestion(question: Questions)
}
