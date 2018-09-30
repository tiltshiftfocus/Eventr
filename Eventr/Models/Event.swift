//
//  Event.swift
//  Eventr
//
//  Created by Jerry on 20/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import UIKit

class Event {
    var id: Int64 = 0
    var name: String = ""
    var dateOfEvent: Date = Date()
    var formattedRelative: NSAttributedString = NSAttributedString(string: "")
    var isWeekend: Bool = false
    var active: Bool = true
    
    var cal = Calendar(identifier: .gregorian)
    
    init(id: Int64, name: String, dateOfEvent: Date = Date(), active: Bool) {
        self.id = id
        self.name = name
        self.dateOfEvent = dateOfEvent
        self.formattedRelative = relativeTimeFormatter(date1: dateOfEvent)
        self.active = active
        setWeekEnd()
    }
    
    func setWeekEnd() {
        cal.firstWeekday = 1
        if cal.isDateInWeekend(self.dateOfEvent) {
            self.isWeekend = true
        }
    }
    
    func updateRelative() {
        self.formattedRelative = relativeTimeFormatter(date1: dateOfEvent)
    }
    
    func relativeTimeFormatter(date1: Date) -> NSAttributedString {
        let date2 = Date()
        let calendar = Calendar.current
        
        var difference: DateComponents?
        var negative: Bool = false
        
        if date1 > date2 {
            difference = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date2, to: date1)
            negative = true
        } else {
            negative = false
            difference = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date1, to: date2)
        }
        
        let builtString: NSAttributedString = buildRelativeTimeString(difference: difference!, negative: negative)
        
        return builtString
    }
    
    func buildRelativeTimeString(difference: DateComponents, negative: Bool) -> NSAttributedString {
        let boldFont: [NSAttributedStringKey: Any] = [.font : UIFont.boldSystemFont(ofSize: 14)]
        
        var relativeText = ""
        
        let i = difference.year!
        var j = 0
        
        if i > 0 {
            relativeText += "\(difference.year!) year"
            j += 1
            if i > 1 {
                relativeText += "s"
            }
            relativeText += ", "
        }
        if difference.month! > 0 {
            relativeText += "\(difference.month!) month"
            j += 1
            if difference.month! > 1 {
                relativeText += "s"
            }
            relativeText += ", "
        }
        if difference.day! > 0 && j < 3 {
            relativeText += "\(difference.day!) day"
            j += 1
            if difference.day! > 1 {
                relativeText += "s"
            }
            relativeText += ", "
        }
        if difference.hour! > 0 && j < 3 {
            relativeText += "\(difference.hour!) hour"
            j += 1
            if difference.hour! > 1 {
                relativeText += "s"
            }
            relativeText += ", "
        }
        if difference.minute! > 0 && j < 3 {
            relativeText += "\(difference.minute!) minute"
            j += 1
            if difference.minute! > 1 {
                relativeText += "s"
            }
            relativeText += ", "
        }
        if j < 3 {
            relativeText += "\(difference.second!) second"
            j += 1
            if difference.second! > 1 {
                relativeText += "s"
            }
            relativeText += ", "
        }
        
        let endIndex = relativeText.index(relativeText.endIndex, offsetBy: -2)
        let ss1: String = "\(relativeText[..<endIndex])"
        relativeText = ss1
        
        var futureOrPast = " ago"
        if(negative == true){
            futureOrPast = " later"
        }
        
        let agoString: NSAttributedString = NSAttributedString(string: futureOrPast, attributes: boldFont)
        let finalString: NSMutableAttributedString = NSMutableAttributedString(string: relativeText)
        finalString.append(agoString)
        
        return finalString
    }
}
