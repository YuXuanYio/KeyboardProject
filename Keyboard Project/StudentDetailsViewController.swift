//
//  StudentDetailsViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 2/1/2023.
//

import UIKit

class StudentDetailsViewController: UIViewController {

    var selectedQuestionList: [Question] = []
    var answersShown: Bool = false
    weak var databaseController: DatabaseProtocol?
    var currentStudent = Student()

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderSegementedControl: UISegmentedControl!
    @IBOutlet weak var yearLevelTextField: UITextField!
    
    @IBAction func confirmDetailsButton(_ sender: Any) {
        displayReadyMessage(title: "Thank you!", message: "Are you ready to solve some problems?")
    }
    
    override func viewDidLoad() {
        print(answersShown)
        print(selectedQuestionList)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Back button should be hidden before deployment at this stage students should not be able to view the questions
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adding listeners when view appear
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removing listners when leaving view
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayReadyMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,  preferredStyle: .alert)
        let alertActionNo = UIAlertAction(title: "No", style: .default, handler: nil)
        let alertActionYes = UIAlertAction(title: "Yes!", style: .default) {
            (action) in
            self.addChild()
            self.performSegue(withIdentifier: "questionsBeginSegue", sender: nil)
        }
        alertController.addAction(alertActionNo)
        alertController.addAction(alertActionYes)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addChild() {
        guard let name = nameTextField.text, let yearLevel = yearLevelTextField.text, let genderInt = Int?(genderSegementedControl.selectedSegmentIndex) else {
            return
        }
        if name.isEmpty || yearLevel.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty && yearLevel.isEmpty {
                errorMsg += "- Must provide a name \n - Must provide year level"
            } else if yearLevel.isEmpty {
                errorMsg += "- Must provide year level"
            } else if name.isEmpty {
                errorMsg += "- Must provide a name"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        var gender = ""
        if genderInt == 0 {
            gender = "Female"
        } else if genderInt == 1 {
            gender = "Male"
        } else {
            gender = "Others"
        }
        currentStudent = databaseController!.addChild(name: name, gender: gender, yearLevel: Int(yearLevel) ?? 0, date: Date())
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "questionsBeginSegue" {
            let destination = segue.destination as! QuestionsBeginViewController
//            destination.answersShown = self.answersShown
            destination.selectedQuestionList = selectedQuestionList
            destination.currentStudent = currentStudent
        }
    }

}
