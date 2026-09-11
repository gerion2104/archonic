import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

ShellRoot {
    id: root
    property bool shown: false

    readonly property color bg:      "#f21e1e2e"
    readonly property color card:    "#66313244"
    readonly property color text:    "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color accent:  "#cba6f7"

    IpcHandler {
        target: "audio"
        function toggle(): void { root.shown = !root.shown }
        function hide(): void { root.shown = false }
    }

    PanelWindow {
        visible: root.shown
        anchors { top: true; right: true }
        margins { top: 40; right: 14 }
        implicitWidth: 340
        implicitHeight: 620
        color: "transparent"

        component Section: Rectangle {
            width: parent.width
            color: root.card
            radius: 10
        }

        component Pill: Rectangle {
            property alias label: t.text
            signal clicked()
            height: 30
            radius: 8
            color: ma.containsMouse ? "#55585b70" : "#33585b70"
            Text { id: t; anchors.centerIn: parent; color: root.text; font.pixelSize: 13 }
            MouseArea {
                id: ma; anchors.fill: parent; hoverEnabled: true
                onClicked: parent.clicked()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: root.bg
            radius: 14
            border.color: "#59cba6f7"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                // ---------- WLAN ----------
                Section {
                    height: 96
                    Column {
                        anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Row {
                            width: parent.width; spacing: 10
                            Text { text: "\uf1eb"; color: root.accent; font.pixelSize: 18
                                   font.family: "JetBrainsMono Nerd Font Mono" }
                            Text { text: "WLAN"; color: root.text; font.pixelSize: 14
                                   font.bold: true; width: parent.width - 90 }
                            Switch { onToggled: wifiProc.running = true }
                        }
                        Pill {
                            width: parent.width
                            label: "Netzwerk-Einstellungen"
                            onClicked: netProc.running = true
                        }
                    }
                }

                // ---------- Lautstärke ----------
                Section {
                    height: 116
                    Column {
                        anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Row {
                            spacing: 10
                            Text { text: "\uf028"; color: root.accent; font.pixelSize: 18
                                   font.family: "JetBrainsMono Nerd Font Mono" }
                            Text { text: "Lautstärke"; color: root.text; font.pixelSize: 14; font.bold: true }
                            Text { text: Math.round(vol.value) + "%"; color: root.subtext; font.pixelSize: 13 }
                        }
                        Slider {
                            id: vol
                            width: parent.width
                            from: 0; to: 100; value: 50
                            onMoved: volProc.running = true
                        }
                        Row {
                            width: parent.width; spacing: 8
                            Pill { width: (parent.width - 16) / 3; label: "\u2212"
                                   onClicked: { vol.value = Math.max(0, vol.value - 5); volProc.running = true } }
                            Pill { width: (parent.width - 16) / 3; label: "\uf026"
                                   onClicked: muteProc.running = true }
                            Pill { width: (parent.width - 16) / 3; label: "+"
                                   onClicked: { vol.value = Math.min(100, vol.value + 5); volProc.running = true } }
                        }
                    }
                }

                // ---------- Mikrofon ----------
                Section {
                    height: 76
                    Column {
                        anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Row {
                            spacing: 10
                            Text { text: "\uf130"; color: root.accent; font.pixelSize: 18
                                   font.family: "JetBrainsMono Nerd Font Mono" }
                            Text { text: "Mikrofon"; color: root.text; font.pixelSize: 14; font.bold: true }
                            Text { text: Math.round(mic.value) + "%"; color: root.subtext; font.pixelSize: 13 }
                        }
                        Slider {
                            id: mic
                            width: parent.width
                            from: 0; to: 100; value: 50
                            onMoved: micProc.running = true
                        }
                    }
                }

                // ---------- Helligkeit ----------
                Section {
                    height: 116
                    Column {
                        anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Row {
                            spacing: 10
                            Text { text: "\uf185"; color: root.accent; font.pixelSize: 18
                                   font.family: "JetBrainsMono Nerd Font Mono" }
                            Text { text: "Helligkeit"; color: root.text; font.pixelSize: 14; font.bold: true }
                            Text { text: Math.round(bri.value) + "%"; color: root.subtext; font.pixelSize: 13 }
                        }
                        Slider {
                            id: bri
                            width: parent.width
                            from: 1; to: 100; value: 80
                            onMoved: briProc.running = true
                        }
                        Row {
                            width: parent.width; spacing: 8
                            Pill { width: (parent.width - 8) / 2; label: "\u2212"
                                   onClicked: { bri.value = Math.max(1, bri.value - 5); briProc.running = true } }
                            Pill { width: (parent.width - 8) / 2; label: "+"
                                   onClicked: { bri.value = Math.min(100, bri.value + 5); briProc.running = true } }
                        }
                    }
                }

                // ---------- Bluetooth ----------
                Section {
                    height: 96
                    Column {
                        anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Row {
                            width: parent.width; spacing: 10
                            Text { text: "\uf293"; color: root.accent; font.pixelSize: 18
                                   font.family: "JetBrainsMono Nerd Font Mono" }
                            Text { text: "Bluetooth"; color: root.text; font.pixelSize: 14
                                   font.bold: true; width: parent.width - 90 }
                            Switch { onToggled: btProc.running = true }
                        }
                        Pill {
                            width: parent.width
                            label: "Bluetooth-Einstellungen"
                            onClicked: btSettings.running = true
                        }
                    }
                }
            }
        }

        Process { id: volProc;  command: ["wpctl","set-volume","@DEFAULT_AUDIO_SINK@",   Math.round(vol.value)+"%"] }
        Process { id: micProc;  command: ["wpctl","set-volume","@DEFAULT_AUDIO_SOURCE@", Math.round(mic.value)+"%"] }
        Process { id: muteProc; command: ["wpctl","set-mute","@DEFAULT_AUDIO_SINK@","toggle"] }
        Process { id: wifiProc; command: ["sh","-c","nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"] }
        Process { id: netProc;  command: ["alacritty","--class","floatterm","-e","nmtui"] }
        Process { id: briProc;  command: ["brightnessctl","set", Math.round(bri.value)+"%"] }
        Process { id: btProc;   command: ["sh","-c","bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"] }
        Process { id: btSettings; command: ["alacritty","--class","floatterm","-e","bluetoothctl"] }
    }
}
