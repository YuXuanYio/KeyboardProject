//
//  QuestionsBeginViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 3/1/2023.
//

import UIKit
import CSV
import InstantSearchVoiceOverlay

class QuestionsBeginViewController: UIViewController, UITextFieldDelegate, DatabaseListener {
    
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
    let voiceOverlayController = VoiceOverlayController()
    var questionComments = ""
    
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func readAnswerButton(_ sender: Any) {
        var answerCorrect = "0"
        if textField.text == String(self.currentQuestion.answer ?? 0) {
            answerCorrect = "1"
        }
        if clearButtonPressed == false {
            try! csv.write(field: textField.text ?? "")
            try! csv.write(field: "-")
            try! csv.write(field: "-")
            try! csv.write(field: answerCorrect)
            try! csv.write(field: String(reactionTime))
        } else {
            try! csv.write(field: textField.text ?? "")
            try! csv.write(field: textField.text ?? "")
            try! csv.write(field: answerCorrect)
            try! csv.write(field: String(reactionTime))
        }
        displayReadAnswersMessage(title: "Confirmation", message: "Is this your answer: " + (textField.text ?? "0") + "?")
    }
    
    @IBAction func clearButton(_ sender: Any) {
        clearButtonPressed = true
        try! csv.write(field: textField.text ?? "")
        textField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseController = appDelegate.databaseController
        currentQuestion = selectedQuestionList[0]
        questionLabel.text = selectedQuestionList[0].question
        questionNumberLabel.text = "Question " + String(counter) + ":"
        responseLabel.text = "Your response: "
        initTextField()
        startTimer()
        self.navigationItem.hidesBackButton = true
        try! csv.write(row: ["Name", "Date", "Problem", "Initial Answer", "Corrected Answer", "Changed Answer", "Correct", "Reaction Time", "Comments"])
        beginNewCSVRow()
        try! csv.write(field: selectedQuestionList[0].question ?? "")
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
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
    
    func displayReadAnswersMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "No", style: .default) {
            (action) in
            self.textField.resignFirstResponder()
        }
        let alertActionYes = UIAlertAction(title: "Yes!", style: .default) {
            (action) in
            self.addNextquestionButtons()
        }
        alertController.addAction(alertActionNo)
        alertController.addAction(alertActionYes)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func removeNextQuestionButtons() {
        self.navigationItem.rightBarButtonItems = .none

    }
    
    func addNextquestionButtons() {
        let nextProblemButton = UIBarButtonItem(title: "Ready for next problem", style: .plain, target: self, action: #selector(self.readyForNextProblem))
        let commentButton = UIBarButtonItem(image: UIImage(named: "mic"), style: .plain, target: self, action: #selector(self.recordComment))
        self.navigationItem.rightBarButtonItems = [nextProblemButton, commentButton]
    }
    
    @objc func readyForNextProblem() {
        self.removeNextQuestionButtons()
        if commentsRecorded == false {
            try! csv.write(field: "-")
        } else {
            try! csv.write(field: questionComments)
        }
        if self.counter < self.selectedQuestionList.count {
            self.counter += 1
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
        }
    }
    
    @objc func recordComment() {
        commentsRecorded = true
        voiceOverlayController.settings.layout.inputScreen.titleListening = "Record your comment"
        voiceOverlayController.settings.layout.inputScreen.subtitleBulletList = ["This is really easy!"]
        voiceOverlayController.settings.layout.inputScreen.titleInProgress = "You said: "
        voiceOverlayController.start(on: self, textHandler: { text, final, _  in
            if final {
                self.questionComments = String(describing: text)
            }
        }, errorHandler: { (error) in
            print("voice output: error \(String(describing: error))")
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func onQuestionsChange(change: DatabaseChange, questions: [Question]) {
        return
    }
    
    func onSetsChange(change: DatabaseChange, questionSets: [QuestionSet]) {
        return
    }

}
