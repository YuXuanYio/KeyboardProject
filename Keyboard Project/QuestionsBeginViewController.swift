//
//  QuestionsBeginViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 3/1/2023.
//

import UIKit

class QuestionsBeginViewController: UIViewController, UITextFieldDelegate {
    
    var selectedQuestionList: [Question] = []
    var answersShown: Bool = false
    var currentStudent = Student()
    var counter = 1
    var startTime: Date!
    var elaspedTime: Double = 0
    
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func readAnswerButton(_ sender: Any) {
        displayReadAnswersMessage(title: "Confirmation", message: "Is this your answer: " + (textField.text ?? "0") + "?")
    }
    
    @IBAction func clearButton(_ sender: Any) {
        textField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = selectedQuestionList[0].question
        questionNumberLabel.text = "Question " + String(counter) + ":"
        responseLabel.text = "Your response: "
        initTextField()
        startTimer()
        self.navigationItem.hidesBackButton = true
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
        endTimer()
    }
    
    func startTimer() {
        startTime = Date()
    }
    
    func endTimer() {
        elaspedTime = Date().timeIntervalSince(startTime)
        print("Elapsed time: \(self.elaspedTime) seconds")
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
    
    @objc func readyForNextProblem() {
        if self.counter < self.selectedQuestionList.count {
            self.removeNextQuestionButtons()
            self.counter += 1
            self.questionLabel.text = self.selectedQuestionList[self.counter - 1].question
            self.questionNumberLabel.text = "Question " + String(self.counter) + ":"
            self.textField.text = ""
            self.textField.resignFirstResponder()
            self.startTimer()
        } else {
            // End the question set here. Depending on whether display answer or not.
            return
        }
    }
    
    func removeNextQuestionButtons() {
        self.navigationItem.rightBarButtonItem = .none

    }
    
    func addNextquestionButtons() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ready for next problem", style: .plain, target: self, action: #selector(self.readyForNextProblem))
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
