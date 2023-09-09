//
//  Prospect.swift
//  HotProspectsApp
//
//  Created by Danjuma Nasiru on 02/03/2023.
//

import SwiftUI

class Prospect: Identifiable, Codable, Equatable, Comparable {
    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.name < rhs.name
    }
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var isContacted = false
}




