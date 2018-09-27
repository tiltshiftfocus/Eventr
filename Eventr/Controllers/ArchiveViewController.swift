//
//  ArchiveViewController.swift
//  Eventr
//
//  Created by Jerry on 27/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit
import SVProgressHUD

class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyListView: UIView!
    
    let dateFormatter = DateFormatter()
    
    let db = DBManager.db
    var allEvents = [Event]()
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        self.slideMenuController()?.openLeft()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        dateFormatter.locale = Locale(identifier: "en_US")
        
        setUpTableView()
        getEvents()
    }
    
    func setUpTableView() {
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        tableView.backgroundColor = UIColor.clear
    }
    
    func getEvents() {
        allEvents = db.queryAll(for: "archive")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
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
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Archive") { (action, indexPath) in
//            let id = self.allEvents[indexPath.row].id
//            let result = self.db.archive(id: id)
//            if result == true {
//                self.allEvents = self.allEvents.filter{ $0.id != id }
//                tableView.beginUpdates()
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                tableView.endUpdates()
//                self.getEvents()
//            }
//        }
//        deleteAction.backgroundColor = UIColor.red
//
//
//        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
//            let event: Event = self.allEvents[indexPath.row]
//            self.selectedMode = "edit"
//            self.performSegue(withIdentifier: "toAddEvent", sender: event)
//        }
//        editAction.backgroundColor = UIColor(rgb: 0xbbdefb)
//
//        return [deleteAction, editAction]
//
//    }
    
}

// MARK: Protocol Delegate from CreateEventController

extension ArchiveViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        allEvents = db.query(text: searchBar.text!, for: "archive")
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
