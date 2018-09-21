//
//  DBController.swift
//  Eventr
//
//  Created by Jerry on 21/9/18.
//  Copyright © 2018 Jerry. All rights reserved.
//

import Foundation
import FMDB

class DBManager {
    static let db = DBManager()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Events.sqlite")
    
    let createStmt = "CREATE TABLE IF NOT EXISTS events ( ID integer PRIMARY KEY, name text NOT NULL, when_db integer NOT NULL DEFAULT(CAST((julianday('now') - 2440587.5)*86400000 AS INTEGER)), image blob );"
    
    var db: FMDatabase;
    
    init() {
        print(dataFilePath)
        do {
            db = FMDatabase(url: dataFilePath)
            guard db.open() else {
                print("Unable to open database")
                return
            }
            
            try db.executeUpdate(createStmt, values: nil)
            
        } catch {
            print(error)
        }
        
    }
    
    func queryAll() -> [Event] {
        let stmt = "SELECT * FROM events ORDER BY when_db desc;"
        var events = [Event]()
        do {
            let rs = try db.executeQuery(stmt, values: nil)
            while rs.next() {
                let name = rs.string(forColumn: "name")!
                let datetime = rs.longLongInt(forColumn: "when_db")
                events.append(Event(name: name, dateOfEvent: Date(timeIntervalSince1970: Double(datetime/1000))))
            }
        } catch {
            print(error)
        }
        
        return events
        
    }
    
    
}
