//
//  QuestionSetTableViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 5/1/2023.
//

import UIKit

class QuestionSetTableViewController: UITableViewController, DatabaseListener {
    
    var listenerType = ListenerType.all
    var currentQuestionSets: [QuestionSet] = []
    var currentQuestions: [Question] = []
    weak var databaseController: DatabaseProtocol?
    lazy var appDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    override func viewDidLoad() {
        databaseController = appDelegate.databaseController
        tableView.reloadData()
        super.viewDidLoad()
    }
    
    func onQuestionsChange(change: DatabaseChange, questions: [Question]) {
        currentQuestions = questions
    }
    
    func onSetsChange(change: DatabaseChange, questionSets: [QuestionSet]) {
        currentQuestionSets = questionSets
        currentQuestionSets = currentQuestionSets.sorted(by: {$0.name ?? "" < $1.name ?? ""})
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adding listeners when view appear
        databaseController?.addListener(listener: self)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Removing listners when leaving view
        databaseController?.removeListener(listener: self)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestionSets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath)
        let questionSet = currentQuestionSets[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = questionSet.name
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedSetSegue" {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! StudentDetailsViewController
                destination.selectedQuestionList = currentQuestionSets[selectedIndexPath.row].questions
            }
        }
    }

}
