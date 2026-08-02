import QtQuick 2.11

Row {
    id: batteryRow
    spacing: 8

    property int percentage: 0
    property string status: "Discharging"
    property color textColor: "white"

    function updateBattery() {
        var xhrCap = new XMLHttpRequest();
        xhrCap.onreadystatechange = function() {
            if (xhrCap.readyState === XMLHttpRequest.DONE && xhrCap.status === 200) {
                batteryRow.percentage = parseInt(xhrCap.responseText.trim());
            }
        }
        xhrCap.open("GET", "file:///sys/class/power_supply/BAT0/capacity");
        xhrCap.send();

        var xhrStat = new XMLHttpRequest();
        xhrStat.onreadystatechange = function() {
            if (xhrStat.readyState === XMLHttpRequest.DONE && xhrStat.status === 200) {
                batteryRow.status = xhrStat.responseText.trim();
            }
        }
        xhrStat.open("GET", "file:///sys/class/power_supply/BAT0/status");
        xhrStat.send();
    }

    Component.onCompleted: {
        updateBattery();
    }

    Timer {
        interval: 10000 // refresh every 10s
        running: true
        repeat: true
        onTriggered: batteryRow.updateBattery()
    }

    // Battery Icon
    Item {
        width: 32
        height: 16
        anchors.verticalCenter: parent.verticalCenter

        // Outer shell
        Rectangle {
            id: shell
            anchors.fill: parent
            anchors.rightMargin: 3
            border.width: 1.5
            border.color: batteryRow.textColor
            color: "transparent"
            radius: 3

            // Charge level
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: Math.max(0, Math.min(parent.width - 4, (parent.width - 4) * (batteryRow.percentage / 100.0)))
                radius: 1
                color: {
                    if (batteryRow.percentage < 20) return "#ff4444"; // low battery is red
                    if (batteryRow.percentage < 50) return "#ffbb33"; // medium is orange/yellow
                    return "#00c851"; // normal/high is green
                }
            }
        }

        // Positive terminal knob
        Rectangle {
            width: 3
            height: 6
            anchors.left: shell.right
            anchors.verticalCenter: shell.verticalCenter
            color: batteryRow.textColor
            radius: 1
        }
    }

    // Charging indicator and Percentage text
    Text {
        text: (batteryRow.status === "Charging" ? "⚡ " : "") + batteryRow.percentage + "%"
        color: batteryRow.textColor
        font.pointSize: root.font.pointSize * 0.95
        font.family: root.font.family
        anchors.verticalCenter: parent.verticalCenter
    }
}
