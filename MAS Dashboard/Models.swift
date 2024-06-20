//
//  Models.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 26/10/2023.
//

import Foundation

struct Material {
    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var desc: String!
    public private(set) var type: String!
    public private(set) var available: Bool!
}


struct Badge {
    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var desc: String!
    public private(set) var available: Bool!
    public private(set) var lastUpdated: String!
    public private(set) var prerequisites: Bool!
    public private(set) var prerequisiteBadges: [String]?
    public private(set) var members: [String]?
}

struct RawUser {
    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var leader: String!
    public private(set) var dateOfBirth: String!
    public private(set) var comments: String!
    public private(set) var mobile: String!
    public private(set) var flag: String!
    public private(set) var source: String!
    public private(set) var year: Int!
}


struct User {
    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var dateOfBirth: String!
    public private(set) var mobile: String!
    public private(set) var dash: Int!
    public private(set) var gender: String!

    public private(set) var comments: [Comment]?

    public private(set) var createdAt: String!
    public private(set) var lastUpdated: String!
}

struct Comment {
    public private(set) var id: String!
    public private(set) var sender: String!
    public private(set) var message: String!
    public private(set) var timestamp: String!
}

struct Group {
    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var gender: String!
    
    public private(set) var dashes: [Int]!
    public private(set) var leaders: [User]!
    
    public private(set) var createdAt: String!
    public private(set) var lastUpdated: String!
}

struct Patrol {
    public private(set) var id: String!
    public private(set) var name: String!
    public private(set) var desc: String!
    public private(set) var active: Bool!
    public private(set) var chief: User!
    public private(set) var vice: User!
    public private(set) var troisieme: User!

    public private(set) var group: Group!
    public var members: [User]!
    
    
    public private(set) var createdAt: String!
    public private(set) var lastUpdated: String!
}

struct BadgeActivity {
    public private(set) var id: String!
    public private(set) var winner: User!
    public private(set) var badge: Badge!
    public private(set) var leader: User!
    public private(set) var timestamp: String!
    public private(set) var createdAt: String!
}


struct Event {
    public private(set) var id: String
    public private(set) var title: String
    public private(set) var locationDesc: String
    public private(set) var locationLink: String
    public private(set) var desc: String
    public private(set) var badgeID: String
    public private(set) var groupID: String
    public private(set) var price: Int
    public private(set) var maxLimit: Int
    public private(set) var date: String
    
    // Empty initializer
    init() {
        self.id = ""
        self.title = ""
        self.locationDesc = ""
        self.locationLink = ""
        self.desc = ""
        self.badgeID = ""
        self.groupID = ""
        self.price = 0
        self.maxLimit = 0
        self.date = ""
    }
    
    // Memberwise initializer
    init(id: String, title: String, locationDesc: String, locationLink: String, desc: String, badgeID: String, groupID: String, price: Int, maxLimit: Int, date: String) {
        self.id = id
        self.title = title
        self.locationDesc = locationDesc
        self.locationLink = locationLink
        self.desc = desc
        self.badgeID = badgeID
        self.groupID = groupID
        self.price = price
        self.maxLimit = maxLimit
        self.date = date
    }
}


struct Ticket {
    public private(set) var event: Event
    public private(set) var userID: String
    public private(set) var timestamp: String
    public private(set) var trxID: String
    public private(set) var amount: Int
    
    // Empty initializer
    init() {
        self.event = Event()
        self.userID = ""
        self.timestamp = ""
        self.trxID = ""
        self.amount = 0
    }
    
    // Memberwise initializer
    init(event: Event, userID: String, timestamp: String, trxID: String, amount: Int) {
        self.event = event
        self.userID = userID
        self.timestamp = timestamp
        self.trxID = trxID
        self.amount = amount
    }
}
