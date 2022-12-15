//
//  Drops.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/14/22.
//

import SwiftUI
import Drops

func loggedInDrop(username: String) -> Drop {
    return Drop(title: "Howdy, \(username)!",
                subtitle: "Successfully signed in",
                icon: UIImage(systemName: "person.fill.checkmark"))
}

