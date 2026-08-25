//
// This file is part of SDDM Sugar Candy.
// A theme for the Simple Display Desktop Manager.
//
// Copyright (C) 2018–2020 Marian Arlt
//
// SDDM Sugar Candy is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or any later version.
//
// You are required to preserve this and any additional legal notices, either
// contained in this file or in other files that you received along with
// SDDM Sugar Candy that refer to the author(s) in accordance with
// sections §4, §5 and specifically §7b of the GNU General Public License.
//
// SDDM Sugar Candy is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SDDM Sugar Candy. If not, see <https://www.gnu.org/licenses/>
//

import QtQuick 2.11
import Qt.labs.folderlistmodel 2.15

// SDDM's userModel has no concept of "is this user currently logged in".
// systemd-logind exposes that as one world-readable file per session under
// /run/systemd/sessions/<id>, containing USER=, STATE= and SERVICE= lines.
// This component polls that directory and exposes the set of usernames that
// have an "active" or "online" session whose SERVICE is "sddm" - i.e. an
// actual graphical session started via this greeter, as opposed to e.g. a
// plain tty login (SERVICE=login) or the per-user systemd manager instance
// (SERVICE=systemd-user) which also show up under logind but aren't a real
// desktop session. On non-systemd systems the folder simply won't exist and
// activeUsers stays empty.
Item {
    id: loggedInUsers

    property bool enabled: config.ShowLoggedInIndicator != "false"
    property var activeUsers: []

    function isLoggedIn(username) {
        return activeUsers.indexOf(username) !== -1
    }

    function readFile(url) {
        var xhr = new XMLHttpRequest()
        try {
            xhr.open("GET", url, false)
            xhr.send()
            if (xhr.status === 200 || xhr.status === 0) {
                return xhr.responseText
            }
        } catch (err) {
            console.log("LoggedInUsers: could not read", url, err)
        }
        return ""
    }

    function refresh() {
        if (!enabled) return
        var users = []
        for (var i = 0; i < sessionFilesInstantiator.count; ++i) {
            var obj = sessionFilesInstantiator.objectAt(i)
            if (!obj || !obj.filePath) continue
            var content = readFile("file://" + obj.filePath)
            if (content === "") continue
            var userMatch = content.match(/^USER=(.*)$/m)
            var stateMatch = content.match(/^STATE=(.*)$/m)
            var serviceMatch = content.match(/^SERVICE=(.*)$/m)
            if (userMatch && stateMatch && serviceMatch) {
                var state = stateMatch[1].trim()
                var service = serviceMatch[1].trim()
                if (service === "sddm" && (state === "active" || state === "online")) {
                    var name = userMatch[1].trim()
                    if (users.indexOf(name) === -1) users.push(name)
                }
            }
        }
        activeUsers = users
    }

    FolderListModel {
        id: sessionFolder
        folder: loggedInUsers.enabled ? "file:///run/systemd/sessions" : ""
        showDirs: false
    }

    Instantiator {
        id: sessionFilesInstantiator
        model: sessionFolder
        delegate: QtObject {
            readonly property string filePath: model.filePath
        }
        onObjectAdded: loggedInUsers.refresh()
        onObjectRemoved: loggedInUsers.refresh()
    }

    Timer {
        interval: 5000
        running: loggedInUsers.enabled
        repeat: true
        onTriggered: loggedInUsers.refresh()
    }

    Component.onCompleted: refresh()
}
