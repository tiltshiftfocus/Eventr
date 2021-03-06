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
    
    private let refreshControl = UIRefreshControl()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        getEvents()
    }
    
    func setUpTableView() {
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        tableView.backgroundColor = UIColor.clear
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
    }
    
    @objc func refresh() {
        getEvents()
    }
    
    func getEvents() {
        if searchBar.text?.count == 0 {
            allEvents = db.queryAll(for: "archive")
            updateView()
        } else {
            allEvents = db.query(text: searchBar.text!, for: "archive")
        }
        self.refreshControl.endRefreshing()
        tableView.reloadData()
        
    }
    
    func updateView() {
        if allEvents.count == 0 {
            self.tableView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.emptyListView.alpha = 1
                
            }
        } else {
            self.emptyListView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.tableView.alpha = 1
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
        
        cell.archivedIcon.isHidden = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let id = self.allEvents[indexPath.row].id
            let result = self.db.delete(id: id)
            if result == true {
                self.allEvents = self.allEvents.filter{ $0.id != id }
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                self.updateView()
            }
        }
        deleteAction.backgroundColor = UIColor.red


        let unarchiveAction = UITableViewRowAction(style: .normal, title: "Unarchive") { (action, indexPath) in
            let id = self.allEvents[indexPath.row].id
            let result = self.db.unarchive(id: id)
            if result == true {
                self.allEvents = self.allEvents.filter{ $0.id != id }
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                self.updateView()
            }
        }
        unarchiveAction.backgroundColor = UIColor(rgb: 0xbbdefb)

        return [deleteAction, unarchiveAction]

    }
    
}

// MARK: Protocol Delegate from CreateEventController

extension ArchiveViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getEvents()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            getEvents()
            searchBar.resignFirstResponder()
        }
    }
}
