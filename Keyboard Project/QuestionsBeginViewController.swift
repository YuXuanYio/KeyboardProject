//
//  QuestionsBeginViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 3/1/2023.
//

import UIKit
import CSV
import Speech

class QuestionsBeginViewController: UIViewController, UITextFieldDelegate, DatabaseListener, SFSpeechRecognizerDelegate, RecordCommentViewControllerDelegate {
    
    var listenerType: ListenerType = .child
    var selectedQuestionList: [Question] = []
    var answersShown: Bool = false
    var currentStudent = Student()
    var counter = 1
    var startTime: Date!
    var elaspedTime: Double = 0
    weak var databaseController: DatabaseProtocol?
    lazy var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    let csv = try! CSVWriter(stream: .toMemory())
    var clearButtonPressed = false
    var reactionTime = ""
    var commentsRecorded = false
    var currentQuestion = Question()
    var finalQuestionComments = ""
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var readyForNextQuestionButton: UIButton!
    
    @IBAction func clearButton(_ sender: Any) {
        clearButtonPressed = true
        try! csv.write(field: textField.text ?? "")
        textField.text = ""
    }
    
    @IBAction func readyForNextQuestionPressed(_ sender: Any) {
        readyForNextProblem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        currentQuestion = selectedQuestionList[0]
        questionLabel.text = selectedQuestionList[0].question
        questionNumberLabel.text = "Question " + String(counter) + ":"
        initTextField()
        startTimer()
        self.navigationItem.hidesBackButton = true
        try! csv.write(row: ["Name", "Date", "Problem", "Initial Answer", "Changed Answer", "Correct", "Reaction Time", "Comments"])
        beginNewCSVRow()
        try! csv.write(field: selectedQuestionList[0].question ?? "")
        requestPermissionForMic()
        hideNextQuestionButtons()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func didGetTargetData(data: String) {
        commentsRecorded = true
        finalQuestionComments = data
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let _ = Int(textField.text ?? "") {
            unhideNextQuestionButtons()
        }
    }
    
    func beginNewCSVRow() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let today = formatter.string(from: date)
        csv.beginNewRow()
        try! csv.write(field: currentStudent.name ?? "")
        try! csv.write(field: today)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let allowedCharacters = CharacterSet.decimalDigits
//        let characterSet = CharacterSet(charactersIn: string)
//        return allowedCharacters.isSuperset(of: characterSet)
//    }
    
    func initTextField() {
        textField.delegate = self
        textField.inputView = UIView()
        textField.tintColor = .clear
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        textField.allowsEditingTextAttributes = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            endTimer()
        }
    }
    
    func startTimer() {
        startTime = Date()
    }
    
    func endTimer() {
        elaspedTime = Date().timeIntervalSince(startTime)
        print("Elapsed time: \(self.elaspedTime) seconds")
        reactionTime = String(format: "%.2f", elaspedTime)
    }
    
    func hideNextQuestionButtons() {
        commentButton.isEnabled = true
        commentButton.isHidden = true
        readyForNextQuestionButton.isHidden = true
    }
    
    func unhideNextQuestionButtons() {
        commentButton.isHidden = false
        readyForNextQuestionButton.isHidden = false
    }
    
    func readyForNextProblem() {
        if let _ = Int(textField.text ?? "") {
            var answerCorrect = "0"
            if textField.text == String(self.currentQuestion.answer ?? 0) {
                answerCorrect = "1"
            }
            if clearButtonPressed == false {
                try! csv.write(field: textField.text ?? "")
                try! csv.write(field: "-")
                try! csv.write(field: answerCorrect)
                try! csv.write(field: String(reactionTime))
            } else {
                try! csv.write(field: textField.text ?? "")
                try! csv.write(field: answerCorrect)
                try! csv.write(field: String(reactionTime))
            }
            self.hideNextQuestionButtons()
            print(finalQuestionComments)
            if commentsRecorded == false {
                try! csv.write(field: "-")
            } else {
                try! csv.write(field: finalQuestionComments)
            }
            if self.counter < self.selectedQuestionList.count {
                self.counter += 1
                if self.counter == self.selectedQuestionList.count {
                    readyForNextQuestionButton.setTitle("Exit to Home Page", for: .normal)
                }
                clearButtonPressed = false
                commentsRecorded = false
                currentQuestion = self.selectedQuestionList[self.counter - 1]
                self.questionLabel.text = self.selectedQuestionList[self.counter - 1].question
                // Writing question name to csv file.
                beginNewCSVRow()
                try! csv.write(field: self.selectedQuestionList[self.counter - 1].question ?? "")
                self.questionNumberLabel.text = "Question " + String(self.counter) + ":"
                self.textField.text = ""
                self.textField.resignFirstResponder()
                self.startTimer()
            } else {
                // End the question set here. Depending on whether display answer or not.
                csv.stream.close()

                // Get the data from the CSV file as a string
                let csvData = csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
                let csvString = String(data: csvData, encoding: .utf8)!
                print(csvString)
                databaseController?.addCSVFile(data: csvString, studentName: currentStudent.name ?? "")
                navigationController?.popToRootViewController(animated: true)
            }
        } else {
            displayMessage(title: "Error", message: "Please enter numerical answers only. Clear space provided and try again.")
        }
    }
    
    func requestPermissionForMic() {
        SFSpeechRecognizer.requestAuthorization {
            (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    print("ACCEPTED")
                } else if authState == .denied {
                    self.displayMessage(title: "User denied permission", message: "Please enable microphone permissions in the settings")
                } else if authState == .notDetermined {
                    self.displayMessage(title: "Error", message: "Speech recognition unavailable on this device")
                } else if authState == .restricted {
                    self.displayMessage(title: "Error", message: "This device is restricted from using speech recognition")
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "recordComment" {
            if let recordCommentVC = segue.destination as? RecordCommentViewController {
                recordCommentVC.commentDelegate = self
            }
        }
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    
    func onQuestionsChange(change: DatabaseChange, questions: [Question]) {
        return
    }
    
    func onSetsChange(change: DatabaseChange, questionSets: [QuestionSet]) {
        return
    }

}
