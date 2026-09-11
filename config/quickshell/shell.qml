import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls

ShellRoot {
    id: root
    property bool shown: false
    onShownChanged: {
        grab.active = root.shown
        if (root.shown) {
            readVol.running = true
            readMic.running = true
            readWifi.running = true
            readBt.running = true
        }
    }

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
        id: panel
        focusable: root.shown
        visible: root.shown
        anchors { top: true; right: true }
        margins { top: 40; right: 14 }
        implicitWidth: 340
        implicitHeight: 500
        color: "transparent"

        // Klick ausserhalb schliesst die Karte. active wird bewusst
        // imperativ gesetzt -- Quickshell schreibt selbst hinein und
        // wuerde eine Bindung zerstoeren.
        HyprlandFocusGrab {
            id: grab
            windows: [ panel ]
            onCleared: root.shown = false
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.shown = false
        }

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
                            Switch { id: wifiSwitch; onToggled: wifiProc.running = true }
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
                    height: 76
                    Column {
                        anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Row {
                            spacing: 10
                            Text {
                                id: volIcon
                                text: muted ? "\uf026" : "\uf028"
                                property bool muted: false
                                color: muted ? "#f38ba8" : root.accent
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font Mono"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { parent.muted = !parent.muted; muteProc.running = true }
                                }
                            }
                            Text { text: "Lautstärke"; color: root.text; font.pixelSize: 14; font.bold: true }
                            Text { text: Math.round(vol.value) + "%"; color: root.subtext; font.pixelSize: 13 }
                        }
                        Slider {
                            id: vol
                            width: parent.width
                            from: 0; to: 100; value: 50
                            onMoved: volProc.running = true
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
                    height: 76
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
                            Switch { id: btSwitch; onToggled: btProc.running = true }
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

        // --- Ist-Zustand einlesen -------------------------------------
        // wpctl gibt "Volume: 0.42" bzw. "Volume: 0.42 [MUTED]" aus.
        Process {
            id: readVol
            command: ["wpctl","get-volume","@DEFAULT_AUDIO_SINK@"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const m = text.match(/Volume:\s*([0-9.]+)/)
                    if (m) vol.value = Math.round(parseFloat(m[1]) * 100)
                    volIcon.muted = text.includes("MUTED")
                }
            }
        }

        Process {
            id: readMic
            command: ["wpctl","get-volume","@DEFAULT_AUDIO_SOURCE@"]
            stdout: StdioCollector {
                onStreamFinished: {
                    const m = text.match(/Volume:\s*([0-9.]+)/)
                    if (m) mic.value = Math.round(parseFloat(m[1]) * 100)
                }
            }
        }

        Process {
            id: readWifi
            command: ["nmcli","radio","wifi"]
            stdout: StdioCollector {
                onStreamFinished: wifiSwitch.checked = text.trim() === "enabled"
            }
        }

        Process {
            id: readBt
            command: ["sh","-c","bluetoothctl show 2>/dev/null | grep -c 'Powered: yes'"]
            stdout: StdioCollector {
                onStreamFinished: btSwitch.checked = text.trim() !== "0"
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
