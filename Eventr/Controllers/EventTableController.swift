//
//  ViewController.swift
//  Eventr
//
//  Created by Jerry on 19/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit
import SwipeCellKit
import SVProgressHUD

class EventTableController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    let dateFormatter = DateFormatter()
    let defaults = UserDefaults.standard
    
    let db = DBManager.db
    var allEvents = [Event]()
    var selectedMode = "add"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        dateFormatter.locale = Locale(identifier: "en_US")
        
        setUpTableView()
        allEvents = db.queryAll()
        
//        if let items = defaults.array(forKey: "SavedArray") as? [String] {
//            travelersProtocols = items
//        }
    }
    
    func setUpTableView() {
        tableView.register(UINib(nibName: "CustomEventCell", bundle: nil), forCellReuseIdentifier: "customEventCell")
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    // MARK: Table Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customEventCell", for: indexPath) as! CustomEventCell
        cell.delegate = self
        
        tableView.indexPath(for: cell)
        
        let event = allEvents[indexPath.row]
        cell.eventLabel?.text = event.name
        
        dateFormatter.dateFormat = "dd"
        cell.dateLabel?.text = dateFormatter.string(from: event.dateOfEvent)
        if event.isWeekend {
            cell.dateLabel?.textColor = .red
        } else {
            cell.dateLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.56)
        }
        
        dateFormatter.dateFormat = "MMM"
        cell.monthLabel?.text = dateFormatter.string(from: event.dateOfEvent)
        dateFormatter.dateFormat = "yyyy"
        cell.yearLabel?.text = dateFormatter.string(from: event.dateOfEvent)
        
        cell.relativeTimeLabel?.attributedText = event.formattedRelative
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentCell = tableView.cellForRow(at: indexPath)
        
        if currentCell?.accessoryType == .checkmark {
           currentCell?.accessoryType = .none
        } else {
           currentCell?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
//        var textField = UITextField()
        
//        let alert = UIAlertController(title: "Add New Event", message: "", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Add Event", style: .default) { (action) in
////            self.aray.append(textField.text!)
////            self.defaults.set(self.aray, forKey: "SavedArray")
//
//            self.tableView.reloadData()
//
//        }
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Enter an event name"
////            textField = alertTextField
//        }
//
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
        selectedMode = "add"
    }
    
    // MARK: Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddEvent") {
            let destVC = segue.destination as! CreateEventController
            destVC.delegate = self
            if selectedMode == "edit" {
                let data = sender! as! Event
                destVC.id = data.id
                destVC.name = data.name
                destVC.datetime = data.dateOfEvent
                selectedMode = "add"
            }
        }
    }
    
}


// MARK: SWIPE CELL
extension EventTableController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let id = self.allEvents[indexPath.row].id
            let result = self.db.delete(id: id)
            if result == true {
//                    self.allEvents = self.allEvents.filter{ $0.id != id }
//                    tableView.beginUpdates()
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                    tableView.endUpdates()
                self.allEvents = self.db.queryAll()
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash")
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            // handle action by updating model with deletion
            let event: Event = self.allEvents[indexPath.row]
            self.selectedMode = "edit"
            self.performSegue(withIdentifier: "toAddEvent", sender: event)
        }
        
        // customize the action appearance
        editAction.image = UIImage(named: "pencil-edit")
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}

extension EventTableController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
}

// MARK: Protocol Delegate from CreateEventController

extension EventTableController: EventDelegate {
    func eventCreated(eventName: String) {
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.showSuccess(withStatus: "Event \(eventName) Created")
        allEvents = db.queryAll()
        tableView.reloadData()
    }
}

extension EventTableController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        allEvents = db.query(text: searchBar.text!)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            allEvents = db.queryAll()
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
}

