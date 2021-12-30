//
//  SensitiveData.swift
//  iOS-Shack-v2
//
//  Created by Sven on 31/8/20.
//  Copyright © 2020 Sven. All rights reserved.
//


import Foundation
import UIKit
import CoreData
import KeychainSwift
//import SQLCipher
import SQLite3


class SensitiveDataController: UIViewController {

        var db: OpaquePointer?
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            
            var myLabel = MyLabel()
            
            myLabel = MyLabel(frame: CGRect(x: 50, y: 50, width: 300, height: 150))
            myLabel.text  = "Check the local storage of the app's \n sandbox and see if you can find \n any sensitive information."
            myLabel.numberOfLines = 3
            self.view.addSubview(myLabel)
            
            pListCreation()
            
            sqlite()
            
    //        sqliteEncrypted()
            
            
            // KeyChain
            let keychain = KeychainSwift()
            keychain.set("masterAccessCode123", forKey: "Secret")
            print(keychain.get("Secret"))
            
        }
    

        func sqlite() {
            // SQLite Database
            //the database file
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("Database.sqlite")
            
            //opening the database
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            
            //droping table
            if sqlite3_exec(db, "DROP TABLE Users", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error dropping table: \(errmsg)")
            }
            
            //creating table
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            
            
            //creating a statement
            var stmt: OpaquePointer?
            
            //the insert query
            let queryString = "INSERT INTO Users (name, password) VALUES (?,?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let name = "john smith";
            
            //binding the parameters
            if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            let password = "SuperSecretPassword";
            
            if sqlite3_bind_text(stmt, 2, password, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
        }
        
        func pListCreation() {
            let fileManager = FileManager.default
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let path = documentDirectory.appending("/debug.plist")
            
            if (!fileManager.fileExists(atPath: path)) {
                let dicContent:[String: String] = ["username": "debug@foo.org", "password":"debugPass"]
                let plistContent = NSDictionary(dictionary: dicContent)
                let success:Bool = plistContent.write(toFile: path, atomically: true)
                if success {
                    print("file has been created!")
                }else{
                    print("unable to create the file")
                }
                
            }else{
                print("file already exist")
            }
        }

        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    }
