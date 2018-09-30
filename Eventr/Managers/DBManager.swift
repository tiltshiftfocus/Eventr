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
    
    let createStmt = "CREATE TABLE IF NOT EXISTS events ( ID integer PRIMARY KEY, name text NOT NULL, when_db integer NOT NULL DEFAULT(CAST((julianday('now') - 2440587.5)*86400000 AS INTEGER)), image blob, isAvailable integer DEFAULT(1));"
    
    init() {
        print(dataFilePath!)
        do {
            let db = self.openDB()
            guard db.open() else {
                print("Unable to open database")
                return
            }
            
            try db.executeUpdate(createStmt, values: nil)
            db.close()
        } catch {
            print(error)
        }
        
    }
    
    func openDB() -> FMDatabase {
        let db: FMDatabase = FMDatabase(url: dataFilePath)
        guard db.open() else {
            print("Unable to open database")
            return db
        }
        return db
    }
    
    func queryAll(for type: String) -> [Event] {
        let db = self.openDB()
        var stmt: String?
        if type == "main" {
            stmt = "SELECT * FROM events WHERE isAvailable = 1 ORDER BY when_db desc;"
        } else if type == "archive" {
            stmt = "SELECT * FROM events WHERE isAvailable = 0 ORDER BY when_db desc;"
        }
        var events = [Event]()
        do {
            let rs = try db.executeQuery(stmt!, values: nil)
            while rs.next() {
                let id = rs.longLongInt(forColumn: "ID")
                let name = rs.string(forColumn: "name")!
                let datetime = rs.longLongInt(forColumn: "when_db")
                let active = rs.bool(forColumn: "isAvailable")
                events.append(Event(id: id, name: name, dateOfEvent: Date(timeIntervalSince1970: Double(datetime/1000)), active: active))
            }
            db.close()
        } catch {
            print(error)
        }
        
        return events
        
    }
    
    func query(text: String, for type: String) -> [Event] {
        let db = self.openDB()
        var stmt: String?
        if type == "main" {
            stmt = "SELECT * FROM events WHERE isAvailable = 1 AND name LIKE '%\(text)%' ORDER BY when_db desc;"
        } else if type == "archive" {
            stmt = "SELECT * FROM events WHERE isAvailable = 0 AND name LIKE '%\(text)%' ORDER BY when_db desc;"
        }
        var events = [Event]()
        do {
            let rs = try db.executeQuery(stmt!, values: nil)
            while rs.next() {
                let id = rs.longLongInt(forColumn: "ID")
                let name = rs.string(forColumn: "name")!
                let datetime = rs.longLongInt(forColumn: "when_db")
                let active = rs.bool(forColumn: "isAvailable")
                events.append(Event(id: id, name: name, dateOfEvent: Date(timeIntervalSince1970: Double(datetime/1000)), active: active))
            }
            db.close()
        } catch {
            print(error)
        }
        
        return events
    }
    
    
    
    func insert(name: String, datetime: Date) {
        let db = self.openDB()
        let stmt = "INSERT INTO events (name, when_db) VALUES (?, ?);"
        
        do {
            let unixTime: Int64 = Int64(datetime.timeIntervalSince1970 * 1000)
            
            try db.executeUpdate(stmt, values: [name, unixTime])
            print("inserted!")
            db.close()
        } catch {
            print(error)
        }
    }
    
    func delete(id: Int64) -> Bool {
        let db = self.openDB()
        let stmt = "DELETE FROM events WHERE ID = ?;"
        do {
            try db.executeUpdate(stmt, values: [id])
            print("deleted")
            db.close()
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func archive(id: Int64) -> Bool {
        let db = self.openDB()
        let stmt = "UPDATE events SET isAvailable = 0 WHERE ID = ?;"
        do {
            try db.executeUpdate(stmt, values: [id])
            print("archived")
            db.close()
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func unarchive(id: Int64) -> Bool {
        let db = self.openDB()
        let stmt = "UPDATE events SET isAvailable = 1 WHERE ID = ?;"
        do {
            try db.executeUpdate(stmt, values: [id])
            print("deleted")
            db.close()
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    func update(id: Int64, name: String, datetime: Date) {
        let db = self.openDB()
        let stmt = "UPDATE events SET name = ?, when_db = ? WHERE ID = ?;"
        
        do {
            let unixTime: Int64 = Int64(datetime.timeIntervalSince1970 * 1000)
            
            try db.executeUpdate(stmt, values: [name, unixTime, id])
            print("updated!")
            db.close()
        } catch {
            print(error)
        }
    }
    
    
}
