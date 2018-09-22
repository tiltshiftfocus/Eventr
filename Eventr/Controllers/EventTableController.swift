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
    var timer: Timer?
    
    let db = DBManager.db
    var allEvents = [Event]()
    var selectedMode = "add"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTableTimer), userInfo: nil, repeats: true)
        
        searchBar.delegate = self
        dateFormatter.locale = Locale(identifier: "en_US")
        
        setUpTableView()
        allEvents = db.queryAll()
    }
    
    func setUpTableView() {
        tableView.register(UINib(nibName: "CustomEventCell", bundle: nil), forCellReuseIdentifier: "customEventCell")
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }
    
    // MARK: Table Stuff
    
    @objc func updateTableTimer() {
        for cell in tableView.visibleCells {
            let indexPath = tableView.indexPath(for: cell)!
            let currentEvent = allEvents[indexPath.row]
            let currentCell = tableView(tableView, cellForRowAt: indexPath) as! CustomEventCell
            currentEvent.updateRelative()
            currentCell.relativeTimeLabel.attributedText = currentEvent.formattedRelative
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customEventCell", for: indexPath) as! CustomEventCell
        cell.delegate = self
        
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

//        let currentCell = tableView.cellForRow(at: indexPath)
//
//        if currentCell?.accessoryType == .checkmark {
//           currentCell?.accessoryType = .none
//        } else {
//           currentCell?.accessoryType = .checkmark
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        selectedMode = "add"
    }
    
    // MARK: Segue Stuff
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddEvent") {
            timer?.invalidate()
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
    
    func wentBack() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTableTimer), userInfo: nil, repeats: true)
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

