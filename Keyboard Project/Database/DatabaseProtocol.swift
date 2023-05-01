//
//  DatabaseProtocol.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 3/1/2023.
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
    case child
    case questionsets
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onQuestionsChange(change: DatabaseChange, questions: [Question])
    func onSetsChange(change: DatabaseChange, questionSets: [QuestionSet])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addChild(name: String, gender: String, yearLevel: Int, date: Date) -> Student
    func addCSVFile(data: String, studentName: String)
}
