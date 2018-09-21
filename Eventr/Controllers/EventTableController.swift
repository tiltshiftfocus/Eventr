//
//  ViewController.swift
//  Eventr
//
//  Created by Jerry on 19/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit
import SwipeCellKit

class EventTableController: UITableViewController {
    
    let dateFormatter = DateFormatter()
    
    let defaults = UserDefaults.standard
    
    var aray = [Event]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Events.sqlite")
    let db = DBManager.db

//    var travelersProtocols = ["The mission comes first.", "Never jeopardize your cover.", "Don’t take a life; don’t save a life, unless otherwise directed. Do not interfere.f nkdlsjfklsdjflk jsdkfj sdlkjfklsdjfklsdkljfhsdk bnsdkjfh sdkjh fkjsdhkjsdh fkjsdhfkj dshjkfsdh jkfhsdkj hkjsdhfkjsdh fkljdshfjkdshfk ljhdskljf hds fhjd shfkl jdshf lkds"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        setUpTableView()
        aray = db.queryAll()
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customEventCell", for: indexPath) as! CustomEventCell
        cell.delegate = self
        
        tableView.indexPath(for: cell)
        
        let event = aray[indexPath.row]
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
        
        let alert = UIAlertController(title: "Add New Event", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Event", style: .default) { (action) in
//            self.aray.append(textField.text!)
//            self.defaults.set(self.aray, forKey: "SavedArray")
            
            self.tableView.reloadData()
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter an event name"
//            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension EventTableController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash")
        
        return [deleteAction]
    }
}

extension EventTableController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        <#code#>
    }
    
    
}

