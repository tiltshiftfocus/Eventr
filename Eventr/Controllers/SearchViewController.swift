//
//  SearchViewController.swift
//  Eventr
//
//  Created by Jerry on 30/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

enum Sections: Int {
    case active = 0
    case archived
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hintView: UIView!
    
    let sectionHeaderHeight: CGFloat = 50.0
    
    var archivedEvents = [Event]()
    var activeEvents = [Event]()
    
    let dateFormatter = DateFormatter()
    let db = DBManager.db
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        updateView()
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCell")
        tableView.backgroundColor = UIColor.clear
    }
    
    func performSearch(for text: String) {
        archivedEvents = db.query(text: text, for: "archive")
        activeEvents = db.query(text: text, for: "main")
        updateView()
        tableView.reloadData()
    }
    
    func updateView() {
        if archivedEvents.count == 0 && activeEvents.count == 0 {
            self.tableView.alpha = 0
            UIView.animate(withDuration: 0.35) {
                self.hintView.alpha = 0.8
                
            }
        } else {
            self.hintView.alpha = 0
            UIView.animate(withDuration: 0.35) {
                self.tableView.alpha = 1
            }
        }
    }

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sect = Sections(rawValue: section) {
            switch sect {
            case .active:
                return activeEvents.count
            case .archived:
                return archivedEvents.count
            }
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        if let sect = Sections(rawValue: indexPath.section) {
            var thisEvents: [Event]?
            if sect == Sections.active {
                thisEvents = activeEvents
            } else if sect == Sections.archived {
                thisEvents = archivedEvents
            }
            
            let event = thisEvents![indexPath.row]
            cell.eventLabel?.text = event.name
            
            dateFormatter.dateFormat = "dd"
            cell.dateLabel?.text = dateFormatter.string(from: event.dateOfEvent)
            
            if event.isWeekend {
                cell.dateLabel?.textColor = .red
            } else {
                cell.dateLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.56)
            }
            
            if !event.active {
                cell.archivedIcon.isHidden = false
            }
            
            dateFormatter.dateFormat = "MMM"
            cell.monthLabel?.text = dateFormatter.string(from: event.dateOfEvent)
            dateFormatter.dateFormat = "yyyy"
            cell.yearLabel?.text = dateFormatter.string(from: event.dateOfEvent)
            
            cell.relativeTimeLabel?.attributedText = event.formattedRelative
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionHeaderHeight))
        view.backgroundColor = UIColor.clear
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: sectionHeaderHeight))
        label.textColor = UIColor.white
        label.font = UIFont(name: "Avenir Next", size: 16.0)?.bold()
        if let sect = Sections(rawValue: section) {
            if sect == Sections.active {
                label.text = "Active"
            } else if sect == Sections.archived {
                label.text = "Archived"
            }
        }
        view.addSubview(label)
        return view
    }
    
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(for: searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
//            getEvents()
            searchBar.resignFirstResponder()
        }
    }
}
