import QtQuick 2.11
import org.kde.plasma.private.battery
import org.kde.plasma.workspace.components as PW

Row {
    id: batteryRow
    spacing: 8

    property color textColor: "white"

    BatteryControlModel {
        id: batteryControl
    }

    visible: batteryControl.hasInternalBatteries

    PW.BatteryIcon {
        pluggedIn: batteryControl.pluggedIn
        hasBattery: batteryControl.hasCumulative
        percent: batteryControl.percent
        width: 24
        height: 24
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: batteryControl.percent + "%"
        color: batteryRow.textColor
        font.pointSize: root.font.pointSize * 0.95
        font.family: root.font.family
        anchors.verticalCenter: parent.verticalCenter
    }
}
