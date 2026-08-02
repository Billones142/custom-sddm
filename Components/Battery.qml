import QtQuick 2.11

Item {
    id: batteryWrapper
    width: loader.item ? loader.item.width : 0
    height: loader.item ? loader.item.height : 0

    property color textColor: "white"

    onTextColorChanged: {
        if (loader.item) {
            loader.item.textColor = textColor;
        }
    }

    Loader {
        id: loader
        source: "BatteryPlasma.qml"
        onStatusChanged: {
            if (status === Loader.Error) {
                console.log("BatteryPlasma load failed, falling back to BatteryXHR");
                source = "BatteryXHR.qml";
            }
        }
        onLoaded: {
            if (item) {
                item.textColor = batteryWrapper.textColor;
            }
        }
    }
}
