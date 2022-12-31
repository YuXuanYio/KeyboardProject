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
    
    override func viewDidLoad() {
        databaseController = appDelegate.databaseController
        initSearchController()
        super.viewDidLoad()
//         Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false
//
//         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        let question = filteredQuestionList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = question.question
        cell.contentConfiguration = content
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
