//
//  DoablesService.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 26/10/2023.
//

import Foundation
import Firebase
import AVFoundation

class DoablesService {
    
    
    static let instance = DoablesService()
    let ref = Database.database().reference()
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    var badges = [Badge]()
    var materials = [Material]()
    var badgeActivities = [BadgeActivity]()
    var events = [Event]()
    
    var selectedBadge = Badge()
    var selectedMaterial = Material()
    var selectedEvent = Event()
    
    var chosenMode = ""
    var selectedBadgeActivity = BadgeActivity()
    
    func pullBadges(completion: @escaping CompletionHandler) {
        self.badges.removeAll()
        ref.child("badges").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary
                guard let badge = Badge(id: id as! String,
                                        name: subvalue!.value(forKey: "name") as? String,
                                        desc: subvalue!.value(forKey: "desc") as? String,
                                        available:  subvalue!.value(forKey: "available") as? Bool,
                                        lastUpdated: subvalue!.value(forKey: "lastUpdated") as? String,
                                        prerequisites:  subvalue!.value(forKey: "prerequisites") as? Bool,
                                        prerequisiteBadges:  subvalue!.value(forKey: "prerequisiteBadges") as? [String] ?? [String](),
                                        members:  subvalue!.value(forKey: "members") as? [String] ?? [String]()) as? Badge else { return }
                self.badges.append(badge)
            }
            completion(true)
        }
    }
    
    func pullMaterials(completion: @escaping CompletionHandler) {
        self.materials.removeAll()
        ref.child("materials").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? NSDictionary else { return }
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary
                let material = Material(id: id as! String,
                                              name: subvalue!.value(forKey: "name") as! String,
                                              desc: subvalue!.value(forKey: "desc") as! String,
                                              type: subvalue!.value(forKey: "type") as! String,
                                              available: subvalue!.value(forKey: "available") as! Bool)
                self.materials.append(material)
            }
            self.materials.sort { $0.type > $1.type }
            completion(true)
        }
    }
    
    func addMaterial(material: Material, completion: @escaping CompletionHandler) {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        var newID = ref.child("materials").childByAutoId().key
        ref.child("materials").child(newID!).updateChildValues([
            "name": material.name!,
            "desc": material.desc!,
            "type": material.type!,
            "available": material.available!,
            "creationDate": dateStr,
            "lastUpdated": dateStr
        ])
        NotificationCenter.default.post(name: NOTIF_UPDATE_MATERIALS, object: nil)
        completion(true)
    }
    
    func editMaterialDetails(material: Material, completion: @escaping CompletionHandler) {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        ref.child("materials").child(selectedMaterial.id).updateChildValues([
            "lastUpdated": dateStr,
            "name": material.name,
            "type": material.type,
            "desc": material.desc,
            "available": material.available
        ])
        NotificationCenter.default.post(name: NOTIF_UPDATE_MATERIALS, object: nil)
        completion(true)
    }
    
    func addBadge(badge: Badge, image: UIImage, completion: @escaping CompletionHandler) {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        var newID = ref.child("badges").childByAutoId().key
        ref.child("badges").child(newID!).updateChildValues([
            "name": badge.name!,
            "desc": badge.desc!,
            "available": badge.available!,
            "prerequisites": badge.prerequisites!,
            "prerequisiteBadges": badge.prerequisiteBadges!,
            "creationDate": dateStr,
            "lastUpdated": dateStr
        ])
        var imageRef = storageRef.child("badges/\(newID!).png")
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        imageRef.putData(image.pngData()!, metadata: metadata)
        NotificationCenter.default.post(name: NOTIF_UPDATE_BADGES, object: nil)
        completion(true)
    }
    

    func updateBadgeDetails(badge: Badge, completion: @escaping CompletionHandler) {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        ref.child("badges").child(self.selectedBadge.id).updateChildValues([
            "name": badge.name!,
            "desc": badge.desc!,
            "available": badge.available!,
            "prerequisites": badge.prerequisites!,
            "prerequisiteBadges": badge.prerequisiteBadges!,
            "lastUpdated": dateStr
        ])
        NotificationCenter.default.post(name: NOTIF_UPDATE_BADGES, object: nil)
        completion(true)
    }
    
    func replaceImage(image: UIImage, completion: @escaping CompletionHandler) {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        let dateStr : String = formatter.string(from: NSDate.init(timeIntervalSinceNow: 0) as Date)
        
        let badge = self.selectedBadge
        
        let imageRef = storageRef.child("badges/\(badge.id!).png")
        imageRef.delete { error in
            let jpegmetadata = StorageMetadata()
            jpegmetadata.contentType = "image/png"
            imageRef.putData(image.pngData()!, metadata: jpegmetadata)
            self.ref.child("badges").child(self.selectedBadge.id).updateChildValues(["lastUpdated": dateStr])
            completion(true)
        }
        
    }
    func fixDateTimeIssue() {
        for badge in badges {
            // Original date string
            let originalDateString = badge.lastUpdated
            
            // Create a DateFormatter for parsing the original date string
            let originalDateFormatter = DateFormatter()
            originalDateFormatter.dateFormat = "dd/MM/yyyy"
            
            // Parse the original date string into a Date object
            if let originalDate = originalDateFormatter.date(from: originalDateString!) {
                // Create a DateFormatter for formatting the date with time
                let formattedDateFormatter = DateFormatter()
                formattedDateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                
                // Format the Date object with the desired format
                let formattedDateString = formattedDateFormatter.string(from: originalDate)
                ref.child("badges").child(badge.id).updateChildValues(["lastUpdated": formattedDateString])
                
            }
        }
    }
    func uploadMaterialImage(image: UIImage, completion: @escaping CompletionHandler) {
        let id = selectedMaterial.id!
        let jpegmetadata = StorageMetadata()
        jpegmetadata.contentType = "image/jpeg"
        let imageRef1 = storageRef.child("materials/\(id)0.jpg")
        imageRef1.getData(maxSize: 1 * 1024 * 1024) { result, error in
            if let error = error {
                //post to image 1
                imageRef1.putData(image.jpegData(compressionQuality: CGFloat(0.01))!, metadata: jpegmetadata) { m, error in
                    if error != nil {
                        completion(false)
                    } else {
                        completion(true)

                    }
                }
            } else {
//                image 1 available, check for image 2
                let imageRef2 = self.storageRef.child("materials/\(id)1.jpg")
                imageRef2.getData(maxSize: 1 * 1024 * 1024) { result, error in
                    if let error = error {
                        //post to image 2

                        imageRef2.putData(image.jpegData(compressionQuality: CGFloat(0.01))!, metadata: jpegmetadata) { m, error in
                            if error != nil {
                                completion(false)
                            } else {
                                completion(true)

                            }
                        }
                    } else {
                        let imageRef3 = self.storageRef.child("materials/\(id)2.jpg")
                        //post to image 3
                        imageRef3.putData(image.jpegData(compressionQuality: CGFloat(0.01))!, metadata: jpegmetadata) { m, error in
                            if error != nil {
                                completion(false)
                            } else {
                                completion(true)

                            }
                        }
                    }
                }
            }
        }

    }
    
    func uploadVideo(url: URL, completion: @escaping CompletionHandler) {
        guard let videoData = try? Data(contentsOf: url) else { return }
        let material = self.selectedMaterial
        let name = "\(material.id!)).mp4"
        let metaData = StorageMetadata()
        metaData.contentType = "video/mp4"
        let videoRef = storageRef.child("materials/\(name)")
        videoRef.putData(videoData) { metaData, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    

    
    func upload(file: URL, completion: @escaping CompletionHandler) {
        let material = self.selectedMaterial
        let name = "\(material.id!)).mp4"
       do {
           let data = try Data(contentsOf: file)
           let storageRef =
       Storage.storage().reference().child("materials").child(name)
           if let uploadData = data as Data? {
               let metaData = StorageMetadata()
               metaData.contentType = "video/mp4"
               storageRef.putData(uploadData, metadata: metaData
                                  , completion: { (metadata, error) in
                                   if let error = error {
                                       completion(false)
                                   }else{
                                       storageRef.downloadURL { (url, error) in
                                           guard let downloadURL = url else {
                                               completion(false)
                                               return
                                           }
                                           completion(true)
                                       }
                                   }
                                  })
           }
       } catch let error {
           print(error.localizedDescription)
       }
       
   }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        try! FileManager.default.removeItem(at: outputURL as URL)
        let asset = AVURLAsset(url: inputURL as URL, options: nil)

        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously(completionHandler: {
            handler(exportSession)
        })
    }
    func getImageFormat(data: Data) -> String? {
        var c = [UInt8](repeating: 0, count: 1)
        (data as NSData).getBytes(&c, length: 1)

        switch c {
        case [0xFF]:
            return "JPEG"
        case [0x89]:
            return "PNG"
        default:
            return nil
        }
    }

    func checkImageFormat(_ image: UIImage) -> String? {
        if let data = image.jpegData(compressionQuality: 1.0) {
            return getImageFormat(data: data)
        } else if let data = image.pngData() {
            return getImageFormat(data: data)
        }
        
        return nil
    }
    
    
    func createBadgeActivity(badge: Badge, winner: User, leader: User, timestamp: String, completion: @escaping CompletionHandler) {
        let dateFormatter : DateFormatter = DateFormatter()
        //  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        ref.child("badgeActivity").childByAutoId().updateChildValues([
            "badge": badge.id!,
            "winner": winner.id!,
            "leader": leader.id!,
            "timestamp": timestamp,
            "createdAt": dateString
        ])
        badgeActivities.append(BadgeActivity(id: "", winner: winner, badge: badge, leader: leader, timestamp: timestamp))
        completion(true)
    }
    
    func pullBadgeActivities(completion: @escaping CompletionHandler) {
        badgeActivities.removeAll()
        ref.child("badgeActivity").getData { Error, snapshot in
            guard let value = snapshot?.value as? NSDictionary else {
                completion(false)
                return
            }
            UserService.instance.queryLeaders()
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary
                var winner = User()
                var wonBadge = Badge()
                var moderatingLeader = User()
                for user in UserService.instance.users {
                    if user.id == subvalue!.value(forKey: "winner") as! String {
                        winner = user
                    }
                }
                for badge in self.badges {
                    if badge.id == subvalue!.value(forKey: "badge") as! String {
                        wonBadge = badge
                    }
                }
                for leader in UserService.instance.availableLeaders {
                    if leader.id == subvalue!.value(forKey: "leader") as? String ?? "" {
                        moderatingLeader = leader
                    }
                }
                
                let badgeActivity = BadgeActivity(id: id as! String,
                                                  winner: winner,
                                                  badge: wonBadge,
                                                  leader: moderatingLeader,
                                                  timestamp: subvalue?.value(forKey: "timestamp") as! String,
                                                  createdAt: subvalue?.value(forKey: "createdAt") as! String)
                self.badgeActivities.append(badgeActivity)
            }
            completion(true)
        }
    }
    
    func pullEvents(completion: @escaping CompletionHandler) {
        ref.child("events").getData { error, snapshot in
            self.events.removeAll()
            guard let value = snapshot?.value as? NSDictionary else {
                completion(false)
                return }
            for id in value.allKeys {
                let subvalue = value.value(forKey: id as! String) as? NSDictionary
                let title = subvalue?.value(forKey: "title") as! String
                let locationDesc = subvalue?.value(forKey: "locationDesc") as! String
                let locationLink = subvalue?.value(forKey: "locationLink") as! String
                let desc = subvalue?.value(forKey: "desc") as! String
                let badgeID = subvalue?.value(forKey: "badgeID") as! String
                let groupID = subvalue?.value(forKey: "groupID") as! String
                let price = subvalue?.value(forKey: "price") as! Int
                let maxLimit = subvalue?.value(forKey: "maxLimit") as! Int

                let date = subvalue?.value(forKey: "date") as! String

                let event = Event(id: id as! String,
                                  title: title,
                                  locationDesc: locationDesc,
                                  locationLink: locationLink,
                                  desc: desc,
                                  badgeID: badgeID,
                                  groupID: groupID,
                                  price: price,
                                  maxLimit: maxLimit,

                                  date: date)
                self.events.append(event)
            }
            completion(true)
        }
    }
    
    func updateEvent(event: Event, completion: @escaping CompletionHandler) {
        var key = event.id
        if key == "" {
            key = ref.child("events").childByAutoId().key!
            let newEvent = Event(id: key,
                                 title: event.title,
                                 locationDesc: event.locationDesc,
                                 locationLink: event.locationLink,
                                 desc: event.desc,
                                 badgeID: event.badgeID,
                                 groupID: event.groupID,
                                 price: event.price,
                                 maxLimit: event.maxLimit,
                                 date: event.date)
            selectedEvent = newEvent
        } else {
            for i in 0..<events.count {
                if events[i].id == event.id {
                    events[i] = event
                }
            }
        }
        ref.child("events").child(key).updateChildValues([
            "title": event.title,
            "locationDesc": event.locationDesc,
            "locationLink": event.locationLink,
            "desc": event.desc,
            "badgeID": event.badgeID,
            "groupID": event.groupID,
            "price": event.price,
            "maxLimit": event.maxLimit,
            "date": event.date
        ])
        completion(true)
    }
}
