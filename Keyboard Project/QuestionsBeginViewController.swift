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
//        while counter < selectedQuestionList.count {
//            questionLabel.text = selectedQuestionList[counter].question
//            questionNumberLabel.text = String(counter + 1)
//        }
        questionLabel.text = selectedQuestionList[0].question
        questionNumberLabel.text = "Question " + String(counter) + ":"
        responseLabel.text = "Your response: "
        textField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Started")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Ended")
    }
    
    func displayReadAnswersMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "No", style: .default, handler: nil)
        let alertActionYes = UIAlertAction(title: "Yes!", style: .default) {
            (action) in
            if self.counter < self.selectedQuestionList.count {
                self.counter += 1
                self.questionLabel.text = self.selectedQuestionList[self.counter - 1].question
                self.questionNumberLabel.text = "Question " + String(self.counter) + ":"
                self.textField.text = ""
                self.textField.resignFirstResponder()
            } else {
                // End the question set here. Depending on whether display answer or not.
                return
            }
        }
        alertController.addAction(alertActionNo)
        alertController.addAction(alertActionYes)
        self.present(alertController, animated: true, completion: nil)
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
