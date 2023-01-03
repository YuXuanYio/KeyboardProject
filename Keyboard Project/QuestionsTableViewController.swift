//
//  QuestionsTableViewController.swift
//  Keyboard Project
//
//  Created by Yu Xuan Yio on 26/12/2022.
//

import UIKit

class QuestionsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, DatabaseListener {
    
    var listenerType = ListenerType.questions
    var currentQuestionList: [Questions] = []
    var filteredQuestionList: [Questions] = []
    var answersShown = false
    weak var databaseController: DatabaseProtocol?
    lazy var appDelegate = {
       return UIApplication.shared.delegate as! AppDelegate
    }()
    let searchController = UISearchController(searchResultsController: nil)

    func onQuestionsChange(change: DatabaseChange, questions: [Questions]) {
        currentQuestionList = questions
        updateSearchResults(for: navigationItem.searchController!)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        databaseController = appDelegate.databaseController
        tableView.reloadData()
        initSearchController()
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.editButtonItem.title = "Select"
        super.viewDidLoad()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if self.isEditing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Proceed", image: nil, primaryAction: nil, menu: getMenu())
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel Selection", style: .plain, target: self, action: #selector(cancelEditing))
        } else {
            self.editButtonItem.title = "Select"
        }
    }
    
    func getMenu() -> UIMenu {
        let displayAnswers = UIAction(title: "Display answers", image: UIImage(systemName: "eye")) { (action) in
            self.answersShown = true
            self.performSegue(withIdentifier: "dopeSegue", sender: nil)
        }
        let doNotDisplayAnswers = UIAction(title: "Do not display answers", image: UIImage(systemName: "eye.slash")) { (action) in
            self.answersShown = false
            self.performSegue(withIdentifier: "dopeSegue", sender: nil)
        }
        let menu = UIMenu(title: "Proceed and:", options: .displayInline, children: [displayAnswers , doNotDisplayAnswers])
        return menu
    }
    
    
    @objc func cancelEditing() {
        self.setEditing(false, animated: true)
        self.navigationItem.leftBarButtonItem = .none
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.editButtonItem.title = "Select"
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
        if searchController.isActive {
            return filteredQuestionList.count
        }
        return currentQuestionList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "question", for: indexPath)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bgColorView
        var question = Questions()
        if searchController.isActive {
            question = filteredQuestionList[indexPath.row]
            if question.isSelected == true {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                question.isSelected = false
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            question = currentQuestionList[indexPath.row]
            if question.isSelected == true {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                question.isSelected = false
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        var content = cell.defaultContentConfiguration()
        content.text = question.question
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            filteredQuestionList[indexPath.row].isSelected = true
        } else {
            currentQuestionList[indexPath.row].isSelected = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            filteredQuestionList[indexPath.row].isSelected = false
        } else {
            currentQuestionList[indexPath.row].isSelected = false
        }
    }
    
    // MARK: - Search Bar and Search Scope Buttons

    // Initialisation for the search controller
    func initSearchController() {
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = ["All", "Addition", "Subtraction"]
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Questions"
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text ?? ""
        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: scopeButton)
    }
    
    func filterForSearchTextAndScopeButton(searchText: String, scopeButton: String = "All") {
        var searchScope = scopeButton
        if scopeButton == "Subtraction" {
            searchScope = "-"
        } else if scopeButton == "Addition" {
            searchScope = "+"
        }
        filteredQuestionList = currentQuestionList.filter{
            question in
            var scopeMatch = false
            if searchScope != "All" {
                scopeMatch = (question.question!.contains(searchScope))
            } else {
                scopeMatch = (searchScope == "All")
            }
            if searchController.searchBar.text != "" {
                let searchTextMatch = question.question!.contains(searchText.lowercased())
                return scopeMatch && searchTextMatch
            } else {
                return scopeMatch
            }
        }
        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "dopeSegue" {
            let destination = segue.destination as! StudentDetailsViewController
            destination.answersShown = self.answersShown
            var tempArr: [Questions] = []
            for question in currentQuestionList {
                if question.isSelected == true {
                    tempArr.append(question)
                }
            }
            destination.selectedQuestionList = tempArr
        }
    }

}
