//
//  ViewController.swift
//  Eventr
//
//  Created by Jerry on 19/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit
import SVProgressHUD

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyListView: UIView!
    
    let dateFormatter = DateFormatter()
    let defaults = UserDefaults.standard
    var timer: Timer?
    
    let db = DBManager.db
    var allEvents = [Event]()
    var selectedMode = "add"
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        self.slideMenuController()?.openLeft()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateTableTimer), userInfo: nil, repeats: true)
        emptyListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addEvent)))
        dateFormatter.locale = Locale(identifier: "en_US")
        searchBar.delegate = self
        
        setUpTableView()
        getEvents()
    }
    
    func setUpTableView() {
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        tableView.backgroundColor = UIColor.clear
    }
    
    func getEvents() {
        allEvents = db.queryAll(for: "main")
        if allEvents.count == 0 {
            UIView.animate(withDuration: 0.5) {
                self.tableView.alpha = 0
                self.emptyListView.alpha = 1
                
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.tableView.alpha = 1
                self.emptyListView.alpha = 0
            }
            
        }
    }
    
    // MARK: Table Stuff
    
    @objc func updateTableTimer() {
        for cell in tableView.visibleCells {
            let indexPath = tableView.indexPath(for: cell)!
            let currentEvent = allEvents[indexPath.row]
            let currentCell = tableView(tableView, cellForRowAt: indexPath) as! EventCell
            currentEvent.updateRelative()
            currentCell.relativeTimeLabel.attributedText = currentEvent.formattedRelative
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
//        cell.delegate = self
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Archive") { (action, indexPath) in
            let id = self.allEvents[indexPath.row].id
            let result = self.db.archive(id: id)
            if result == true {
                self.allEvents = self.allEvents.filter{ $0.id != id }
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                self.getEvents()
            }
        }
        deleteAction.backgroundColor = UIColor.red
        
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let event: Event = self.allEvents[indexPath.row]
            self.selectedMode = "edit"
            self.performSegue(withIdentifier: "toAddEvent", sender: event)
        }
        editAction.backgroundColor = UIColor(rgb: 0xbbdefb)
        
        return [deleteAction, editAction]
        
    }
    
    // MARK: Segue Stuff
    
    @objc func addEvent() {
        performSegue(withIdentifier: "toAddEvent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAddEvent") {
            self.slideMenuController()?.removeLeftGestures()
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
//extension EventTableController: SwipeTableViewCellDelegate {
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            let id = self.allEvents[indexPath.row].id
//            let result = self.db.delete(id: id)
//            if result == true {
////                    self.allEvents = self.allEvents.filter{ $0.id != id }
////                    tableView.beginUpdates()
////                    tableView.deleteRows(at: [indexPath], with: .fade)
////                    tableView.endUpdates()
//                self.allEvents = self.db.queryAll()
//            }
//        }
//
//        // customize the action appearance
//        deleteAction.image = UIImage(named: "trash")
//
//        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
//            // handle action by updating model with deletion
//            let event: Event = self.allEvents[indexPath.row]
//            self.selectedMode = "edit"
//            self.performSegue(withIdentifier: "toAddEvent", sender: event)
//        }
//
//        // customize the action appearance
//        editAction.image = UIImage(named: "pencil-edit")
//
//        return [deleteAction, editAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }
//}

// MARK: Protocol Delegate from CreateEventController

extension EventViewController: EventDelegate {
    func eventCreated(eventName: String) {
//        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
//        SVProgressHUD.setMaximumDismissTimeInterval(1.8)
//        SVProgressHUD.showSuccess(withStatus: "Event \(eventName) Created")
        if searchBar.text?.count == 0 {
            getEvents()
        } else {
            allEvents = db.query(text: searchBar.text!, for: "main")
        }
        tableView.reloadData()
    }
    
    func wentBack() {
        self.slideMenuController()?.addLeftGestures()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateTableTimer), userInfo: nil, repeats: true)
    }
}

extension EventViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        allEvents = db.query(text: searchBar.text!, for: "main")
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            getEvents()
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
}

