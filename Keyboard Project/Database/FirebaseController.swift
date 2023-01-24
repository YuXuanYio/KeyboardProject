//
//  FirebaseController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 3/1/2023.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var questionList: [Question]
    var questionSetList: [QuestionSet]
    var database: Firestore
    var questionsRef: CollectionReference?
    var childRef: CollectionReference?
    var questionSetRef: CollectionReference?
    var csvRef: CollectionReference?

    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        questionList = [Question]()
        questionSetList = [QuestionSet]()
        super.init()
        initDatabaseRef()
        self.setupQuestionsListener()
    }
    
    func initDatabaseRef() {
        questionsRef = database.collection("questions")
        childRef = database.collection("student")
        questionSetRef = database.collection("questionsets")
        csvRef = database.collection("csvfiles")
    }
    
    func cleanup() {}
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .questions || listener.listenerType == .all {
            listener.onQuestionsChange(change: .update, questions: questionList)
        }
        if listener.listenerType == .questionsets || listener.listenerType == .all {
            listener.onSetsChange(change: .update, questionSets: questionSetList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addChild(name: String, gender: String, yearLevel: Int, date: Date) -> Student {
        let childToAdd = Student()
        childToAdd.name = name
        childToAdd.gender = gender
        childToAdd.yearLevel = yearLevel
        childToAdd.date = date
        do {
            if let childRef = try childRef?.addDocument(from: childToAdd) {
                childToAdd.id = childRef.documentID
            }
        } catch {
            print("Failed to serialize question")
        }
        return childToAdd
    }
    
    func addCSVFile(data: String, studentName: String) {
        csvRef?.addDocument(data: ["data": data, "studentName": studentName]) {
            error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func parseQuestionSetSnapshot(snapshot: QueryDocumentSnapshot) {
        let tempQuestionSet = QuestionSet()
        tempQuestionSet.name = snapshot.data()["name"] as? String
        tempQuestionSet.id = snapshot.documentID
        if let questionsReferences = snapshot.data()["questions"] as? [DocumentReference] {
            print(questionList)
            for reference in questionsReferences {
                if let question = getQuestionByID(id: reference.documentID) {
                    tempQuestionSet.questions.append(question)
                }
            }
        }
        var choiceToAppend = true
        for questionSet in questionSetList {
            if questionSet.name == tempQuestionSet.name {
                choiceToAppend = false
            }
        }
        if choiceToAppend {
            questionSetList.append(tempQuestionSet)
            listeners.invoke {
                (listener) in
                if listener.listenerType == ListenerType.questionsets || listener.listenerType == ListenerType.all {
                    listener.onSetsChange(change: .update, questionSets: questionSetList)
                }
            }
        } else {
            var temp = 0
            for i in 0..<questionSetList.count {
                if questionSetList[i].name == tempQuestionSet.name {
                    temp = i
                }
            }
            questionSetList[temp] = tempQuestionSet
            listeners.invoke {
                (listener) in
                if listener.listenerType == ListenerType.questionsets || listener.listenerType == ListenerType.all {
                    listener.onSetsChange(change: .update, questionSets: questionSetList)
                }
            }
        }
    }
    
    func setupQuestionSetListener() {
        questionSetRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
            print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            var i = 0
            while i < querySnapshot.count {
                self.parseQuestionSetSnapshot(snapshot: querySnapshot.documents[i])
                i += 1
            }
        }
    }
    
    func parseQuestionsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedQuestion: Question?
            do {
                parsedQuestion = try change.document.data(as: Question.self)
            } catch {
                print("Unable to decode question. Is the question malformed?")
                return
            }
            guard let question = parsedQuestion else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                questionList.insert(question, at: Int(change.newIndex))
            } else if change.type == .modified {
                questionList[Int(change.oldIndex)] = question
            } else if change.type == .removed {
                questionList.remove(at: Int(change.oldIndex))
            }
            listeners.invoke {
                (listener) in
                if listener.listenerType == ListenerType.questions || listener.listenerType == ListenerType.all {
                    listener.onQuestionsChange(change: .update, questions: questionList)
                }
            }
        }
        self.setupQuestionSetListener()
    }
    
    func setupQuestionsListener() {
        questionsRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
            print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseQuestionsSnapshot(snapshot: querySnapshot)
        }
    }
    
    func getQuestionByID(id: String) -> Question? {
        for question in questionList {
            if question.id == id {
                return question
            }
        }
        return nil
    }
}
