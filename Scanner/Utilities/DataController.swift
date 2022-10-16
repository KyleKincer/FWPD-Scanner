//
//  DataController.swift
//  Scanner
//
//  Created by Kyle Kincer on 10/16/22.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Scanner")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("CoreData failed to load! \(error.localizedDescription)")
            }
        }
    }
}
