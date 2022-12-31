//
//  FirebaseController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 26/12/2022.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var questionList: [Questions]
    var database: Firestore
    var questionsRef: CollectionReference?

    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        questionList = [Questions]()
        questionsRef = database.collection("questions")
        super.init()
        self.setupQuestionsListener()
    }
    
    func cleanup() {}
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .questions {
            listener.onQuestionsChange(change: .update, questions: questionList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addQuestion(question: String, answer: Int) {
        let questionToAdd = Questions()
        questionToAdd.question = question
        questionToAdd.answer = answer
        do {
            if let questionsRef = try questionsRef?.addDocument(from: questionToAdd) {
                questionToAdd.id = questionsRef.documentID
            }
        } catch {
            print("Failed to serialize question")
        }
    }
    
    func deleteQuestion(question: Questions) {
        if let questionID = question.id {
            questionsRef?.document(questionID).delete()
        }
    }
    
    func parseQuestionsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach {
            (change) in
            var parsedQuestion: Questions?
            do {
                parsedQuestion = try change.document.data(as: Questions.self)
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
                if listener.listenerType == ListenerType.questions {
                    listener.onQuestionsChange(change: .update, questions: questionList)
                }
            }
        }
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
    
}
