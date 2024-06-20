//
//  Constants.swift
//  MAS Dashboard
//
//  Created by Michael Asham on 26/10/2023.
//

import Foundation




let NOTIF_UPDATE_BADGES = Notification.Name("NotifUpdateBadges")
let NOTIF_UPDATE_GROUPS = Notification.Name("NotifUpdateGroups")
let NOTIF_UPDATE_PATROLS = Notification.Name("NotifUpdatePatrols")
let NOTIF_SWITCH_CLICK = Notification.Name("NotifSwitchClick")
let NOTIF_UPDATE_MATERIALS = Notification.Name("NotifUpdateMaterials")
let NOTIF_ADD_IMAGE = Notification.Name("NotifAddImage")
let NOTIF_ADD_VIDEO = Notification.Name("NotifAddVideo")
let NOTIF_REMOVE_MEDIA = Notification.Name("NotifRemoveMedia")
var materialMediaCount = 0



typealias CompletionHandler = (_ Success: Bool) -> ()

let NSP_STR = "log=\(true),forcePolling=\(true)"
