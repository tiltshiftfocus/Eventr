//
//  CreateEventController.swift
//  Eventr
//
//  Created by Jerry on 21/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

protocol EventDelegate {
    func eventCreated()
}

class CreateEventController: UIViewController {
    
    var delegate: EventDelegate?
    let db = DBManager.db;
    
    var id: Int64 = -1
    var name: String = ""
    var datetime: Date = Date()

    @IBOutlet weak var eventNameTextView: UITextView!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventNameTextView.text = name
        dateTimePicker.date = datetime
    }

    @IBAction func dateTimePickerChanged(_ sender: UIDatePicker) {
        datetime = sender.date
    }
    
    @IBAction func onSaveButtonPressed(_ sender: UIButton) {
        if id == -1 {
            db.insert(name: eventNameTextView.text, datetime: datetime)
        } else if id > 0 {
            db.update(id: id, name: name, datetime: datetime)
        }
        delegate?.eventCreated()
        navigationController?.popViewController(animated: true)
    }
}
