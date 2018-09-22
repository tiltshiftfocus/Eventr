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
        print(dataFilePath!)
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
                let id = rs.longLongInt(forColumn: "ID")
                let name = rs.string(forColumn: "name")!
                let datetime = rs.longLongInt(forColumn: "when_db")
                events.append(Event(id: id, name: name, dateOfEvent: Date(timeIntervalSince1970: Double(datetime/1000))))
            }
        } catch {
            print(error)
        }
        
        return events
        
    }
    
    func insert(name: String, datetime: Date) {
        let stmt = "INSERT INTO events (name, when_db) VALUES (?, ?);"
        
        do {
            
            let unixTime: Double = datetime.timeIntervalSince1970 * 1000
            
            try db.executeUpdate(stmt, values: [name, unixTime])
            print("inserted!")
        } catch {
            print(error)
        }
    }
    
    func delete(id: Int64) -> Bool {
        let stmt = "DELETE FROM events WHERE ID = ?;"
        do {
            try db.executeUpdate(stmt, values: [id])
            print("deleted")
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func update(id: Int64, name: String, datetime: Date) {
        let stmt = "UPDATE events SET name = ?, when_db = ? WHERE ID = ?;"
        
        do {
            let unixTime: Double = datetime.timeIntervalSince1970 * 1000
            try db.executeUpdate(stmt, values: [name, unixTime, id])
            print("updated!")
        } catch {
            print(error)
        }
    }
    
    
}
