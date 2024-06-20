//
//  UserService.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 19/06/2024.
//

import Foundation


import Foundation
import Firebase
import AVFoundation

class UserService {
    
    
    static let instance = UserService()
    let ref = Database.database().reference()
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    var selectedRawUser = RawUser()
    var selectedUser = User()
    
    var rawUsers = [RawUser]()
    var users = [User]()
    var groups = [Group]()
    var patrols = [Patrol]()
    var selectedGroup = Group()
    var selectedPatrol = Patrol()
    
    var availableDashes = [Int]()
    var availableLeaders = [User]()
    
    var chosenMode = ""
    
    func pullRawUsers(completion: @escaping CompletionHandler) {
        rawUsers.removeAll()
        ref.child("rawUsers").getData { error, snapshot in
            guard let value = snapshot?.value as? NSDictionary else {
                completion(false)
                return }
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary
                let rawUser = RawUser(id:  id as! String,
                                      name: subvalue!.value(forKey: "Name") as? String ?? "",
                                      leader: subvalue!.value(forKey: "Leaders") as? String ?? "",
                                      dateOfBirth: subvalue!.value(forKey: "Date Of Birth") as? String ?? "",
                                      comments: subvalue!.value(forKey: "Comments") as? String ?? "",
                                      mobile: String((subvalue!.value(forKey: "Mobile") as? Int ?? 0)),
                                      flag: subvalue!.value(forKey: "Flag") as? String ?? "",
                                      source: subvalue!.value(forKey: "Source") as? String ?? "",
                                      year: subvalue!.value(forKey: "Year") as? Int ?? 0
                )
                self.rawUsers.append(rawUser)
            }
            print(self.rawUsers.count)
            completion(true)
        }
    }
    
    func pullUsers(completion: @escaping CompletionHandler) {
        users.removeAll()
        ref.child("users").getData(completion: { error, snapshot in
            guard let value = snapshot?.value as? NSDictionary else { return }
            for id in value.allKeys {
                var comments = [Comment]()
                guard let subvalue = value.value(forKey: id as! String) as? NSDictionary else {
                    completion(false)
                    return }
                let commentsDict = subvalue.value(forKey: "comments") as? NSDictionary ?? NSDictionary()
                for commentID in commentsDict.allKeys {
                    guard let subsubvalue = commentsDict.value(forKey: commentID as! String) as? NSDictionary else { return }
                    let newComment = Comment(id: commentID as! String,
                                             sender: subsubvalue.value(forKey: "sender") as! String,
                                             message: subsubvalue.value(forKey: "message") as! String,
                                             timestamp: subsubvalue.value(forKey: "timestamp") as! String)
                    comments.append(newComment)
                }
                
                let user = User(id: id as! String,
                                      name: subvalue.value(forKey: "name") as? String ?? "",
                                      dateOfBirth: subvalue.value(forKey: "dateOfBirth") as? String ?? "",
                                      mobile: subvalue.value(forKey: "mobile") as? String ?? "",
                                      dash: subvalue.value(forKey: "dash") as? Int ?? 0,
                                      gender: subvalue.value(forKey: "gender") as? String ?? "",
                                      comments: comments,
                                      createdAt: subvalue.value(forKey: "createdAt") as? String ?? "",
                                      lastUpdated: subvalue.value(forKey: "lastUpdated") as? String ?? "")
                self.users.append(user)
            }
            self.users.sort { $0.name < $1.name }
            completion(true)
        })
    }
    
    func fixGender() {
        for user in users {
            ref.child("users").child(user.id).updateChildValues(["gender": "Female"])
        }
    }
    
    func uploadUsers(completion: @escaping CompletionHandler) {
        for user in users {
            let key = ref.child("users").childByAutoId().key!
            ref.child("users").child(key).updateChildValues([
                "name": user.name!,
                "dateOfBirth": user.dateOfBirth ?? "",
                "mobile": user.mobile!,
                "gender": user.gender!,
                "dash": user.dash!,
                "lastUpdated": user.lastUpdated!,
                "createdAt": user.createdAt!
            ])
            for comment in user.comments! {
                let commentKey = ref.child("users").child(key).child("comments").childByAutoId().key!
                ref.child("users").child(key).child("comments").child(commentKey).updateChildValues([
                    "sender": comment.sender!,
                    "message": comment.message!,
                    "timestamp": comment.timestamp!
                ])
            }
        }
        print("created \(users.count) user")
        completion(true)
    }
   
    func convertUsers(completion: @escaping CompletionHandler) {
        users.removeAll()
        if rawUsers.count > 0 {
            for (index, raw) in rawUsers.enumerated().reversed() {
                if Int(raw.mobile.replacingOccurrences(of: " ", with: ""))! > 100000 {
                    let dateFormatter : DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                    let date = Date()
                    let dateString = dateFormatter.string(from: date)
                    
                    var comments = [Comment]()
                    let comment = Comment(id: "", sender: "bot", message: "Data imported from \(raw.source!)", timestamp: dateString)
                    comments.append(comment)
                    if raw.flag != "" {
                        let comment = Comment(id: "", sender: "bot", message: "This user has been flagged \(raw.flag!)", timestamp: dateString)
                        comments.append(comment)
                    }
                    if raw.leader != "" {
                        let comment = Comment(id: "", sender: "bot", message: "The current leader for this user is \(raw.leader!)", timestamp: dateString)
                        comments.append(comment)
                    }
                    if raw.comments != ""{
                        let comment = Comment(id: "", sender: "bot", message: "old comment found: \(raw.comments!)", timestamp: dateString)
                        comments.append(comment)
                    }
                    var dash = 0
                    switch raw.year {
                    case 14:
                        dash = 3
                    case 13:
                        dash = 4
                    case 12:
                        dash = 5
                    default:
                        print("hamada")
                    }
                    
                    let user = User(id: "",
                                    name: raw.name,
                                    dateOfBirth: raw.dateOfBirth,
                                    mobile: raw.mobile.replacingOccurrences(of: " ", with: ""),
                                    dash: dash,
                                    gender: "Female",
                                    comments: comments,
                                    createdAt: dateString,
                                    lastUpdated: dateString
                    )
                    users.append(user)
                    rawUsers.remove(at: index)
                    ref.child("rawUsers").child(String(index)).removeValue()
                    print("deleting \(index)")
                }
            }
            completion(true)
        }
    }
    
    func updateGroup(name: String, dashes: [Int], gender: String, leaders: [User], patrols: [Patrol], completion: @escaping CompletionHandler) {
        var key = ""
        var createdAt = ""
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        if selectedGroup.id == nil {
            //new
            key = ref.child("groups").childByAutoId().key!
            createdAt = dateStr
        } else {
            key = selectedGroup.id
            createdAt = selectedGroup.createdAt
        }
        var leadersArray = [String]()
        for leader in leaders {
            leadersArray.append(leader.id)
        }
        ref.child("groups").child(key).updateChildValues([
            "name": name,
            "gender": gender,
            "dashes": dashes,
            "leaders": leadersArray,
            "createdAt": createdAt,
            "lastUpdated": dateStr
        ])
        NotificationCenter.default.post(name: NOTIF_UPDATE_GROUPS, object: nil)
        completion(true)
    }
    
    func updatePatrol(patrol: Patrol, completion: @escaping CompletionHandler) {
        let group = selectedGroup
        var key = patrol.id
        var createdAt = patrol.createdAt
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        if key == "" {
            //new
            key = ref.child("patrols").childByAutoId().key
            createdAt = dateStr
            patrols.append(patrol)
        } else {
            for (index, apatrol) in patrols.enumerated() {
                if apatrol.id == patrol.id {
                    patrols[index] = patrol
                    break
                }
            }
        }
        var membersArray = [String]()
        for member in patrol.members {
            membersArray.append(member.id)
        }
        var chief = ""
        var troisieme = ""
        var vice = ""
        ref.child("patrols").child(key!).updateChildValues([
            "name": patrol.name,
            "desc": patrol.desc,
            "active": patrol.active,
            "chief": patrol.chief.id ?? "",
            "vice": patrol.vice.id ?? "",
            "troisieme": patrol.troisieme.id ?? "",
            "group": group.id,
            "members": membersArray,
            "createdAt": createdAt!,
            "lastUpdated": dateStr
        ])
        NotificationCenter.default.post(name: NOTIF_UPDATE_PATROLS, object: nil)
        completion(true)
    }
//    struct Patrol {
//        public private(set) var id: String!
//        public private(set) var name: String!
//
//        public private(set) var group: Group!
//        public private(set) var members: [User]!
//
//        public private(set) var createdAt: String!
//        public private(set) var lastUpdated: String!
//    }
    
    func pullGroups(completion: @escaping CompletionHandler) {
        groups.removeAll()
        ref.child("groups").getData { error, snapshot in
            guard let value = snapshot?.value as? NSDictionary else { return }
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary

                //leaders
                var leaders = [User]()
                if let leadersDict = subvalue!.value(forKey: "patrols") as? NSArray {
                    for leaderItem in leadersDict {
                        for user in self.users {
                            if user.id == leaderItem as? String {
                                leaders.append(user)
                            }
                        }
                    }
                }
                //group assembly
                let group = Group(id: id as? String,
                                  name: subvalue?.value(forKey: "name") as? String,
                                  gender: subvalue?.value(forKey: "gender") as? String,
                                  dashes: subvalue?.value(forKey: "dashes") as? [Int] ?? [Int](),
                                  leaders: leaders,
                                  createdAt: subvalue?.value(forKey: "createdAt") as? String ?? String(),
                                  lastUpdated: subvalue?.value(forKey: "lastUpdated") as? String ?? String()
                )
                self.groups.append(group)
            }
            completion(true)
        }
    }
    func queryAvailableDashes() {
        availableDashes.removeAll()
        for user in users {
            if !availableDashes.contains(user.dash) {
                availableDashes.append(user.dash)
            }
        }
    }
    func queryLeaders() {
        availableLeaders.removeAll()
        for user in users {
            if user.dash <= 0 {
                availableLeaders.append(user)
            }
        }
    }
    func pullPatrols(completion: @escaping CompletionHandler) {
        patrols.removeAll()
        ref.child("patrols").getData { Error, snapshot in
            guard let value = snapshot?.value as? NSDictionary else { completion(false); return }
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary
                var chief = User()
                var vice = User()
                var troisieme = User()
                let membersArray = subvalue?.value(forKey: "members") as? [String] ?? [String]()
                var members = [User]()
                
                for member in membersArray {
                    for user in self.users {
                        if user.id == member {
                            members.append(user)
                            break
                        }
                    }
                }
                
                for user in members {
                    switch user.id{
                    case subvalue?.value(forKey: "chief") as! String:
                        chief = user
                    case subvalue?.value(forKey: "vice") as! String:
                        vice = user
                    case subvalue?.value(forKey: "troisieme") as! String:
                        troisieme = user
                    default:
                        print("lolo")
                    }
                }
                var group = Group()
                for agroup in self.groups {
                    if agroup.id == subvalue?.value(forKey: "group") as! String {
                        group = agroup
                        break
                    }
                }
                let patrol = Patrol(id: id as? String,
                                    name: subvalue?.value(forKey: "name") as? String,
                                    desc: subvalue?.value(forKey: "desc") as? String ?? "",
                                    active: subvalue?.value(forKey: "active") as? Bool,
                                    chief: chief,
                                    vice: vice,
                                    troisieme: troisieme,
                                    group: group,
                                    members: members,
                                    createdAt: subvalue?.value(forKey: "createdAt") as? String,
                                    lastUpdated: subvalue?.value(forKey: "lastUpdated") as? String)
                self.patrols.append(patrol)
            }
            completion(true)
        }
    }
    
}
