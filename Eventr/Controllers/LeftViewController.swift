//
//  LeftViewController.swift
//  Eventr
//
//  Created by Jerry on 23/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

enum LeftMenu: Int {
    case events = 0
    case archived
}

class LeftViewController: UIViewController {
    let menus = [
        "Events",
        "Archived"
    ]
    
    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.backgroundColor = UIColor.clear
        menuTableView.rowHeight = 70.0
        setupDrawerControllers()
    }
    
    override func viewDidLayoutSubviews() {
        self.slideMenuController()?.changeMainViewController(ViewControllers.shared.eventsBoard, close: true)
    }
    
    // MARK: Drawer Configurations and Functions
    func setupDrawerControllers() {
        if let _ = ViewControllers.shared.eventsBoard {
        } else {
            ViewControllers.shared.eventsBoard = storyboard?.instantiateViewController(withIdentifier: "Main")
        }
        
        if let _ = ViewControllers.shared.archivedBoard {
        } else {
            ViewControllers.shared.archivedBoard = storyboard?.instantiateViewController(withIdentifier: "Archive")
        }
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .events:
            self.slideMenuController()?.changeMainViewController(ViewControllers.shared.eventsBoard, close: true)
        case .archived:
            self.slideMenuController()?.changeMainViewController(ViewControllers.shared.archivedBoard, close: true)
        }
    }

}

extension LeftViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel!.text = menus[indexPath.row]
        cell.textLabel!.font = UIFont(name: "Avenir Next", size: 17.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
           self.changeViewController(menu)
        }
    }
    
    
}
