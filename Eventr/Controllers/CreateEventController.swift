//
//  CreateEventController.swift
//  Eventr
//
//  Created by Jerry on 21/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

protocol EventDelegate {
    func eventCreated(eventName: String)
    func wentBack()
}

class CreateEventController: UIViewController {
    
    var delegate: EventDelegate?
    let db = DBManager.db;
    
    var id: Int64 = -1
    var name: String = ""
    var datetime: Date = Date()

    @IBOutlet weak var eventNameTextView: UITextView!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if id > -1 {
            self.title = "Update Event"
        }
        
        initView()
        validate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.wentBack()
    }
    
    func initView() {
        // MARK: Customize TextView
        eventNameTextView.layer.borderColor = UIColor.gray.cgColor
        eventNameTextView.layer.borderWidth = 0.3
        eventNameTextView.layer.cornerRadius = 5.0
        
        eventNameTextView.delegate = self
        eventNameTextView.text = name
        dateTimePicker.date = datetime
        eventNameTextView.becomeFirstResponder()
    }
    
    func validate() {
        let text: String = eventNameTextView.text ?? ""
        saveButton.isEnabled = !text.isEmpty
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
        delegate?.eventCreated(eventName: eventNameTextView.text)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: TextView Delegate

extension CreateEventController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            eventNameTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validate()
    }
    
}
