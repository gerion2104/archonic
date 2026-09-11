import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

ShellRoot {
    id: root
    property bool shown: false

    IpcHandler {
        target: "audio"
        function toggle(): void { root.shown = !root.shown }
        function show(): void { root.shown = true }
        function hide(): void { root.shown = false }
    }

    PanelWindow {
        visible: root.shown
        anchors { top: true; right: true }
        margins { top: 40; right: 14 }
        implicitWidth: 300
        implicitHeight: 150
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f01e1e2e"
            radius: 12
            border.color: "#59cba6f7"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                Text { text: "Ausgabe"; color: "#cdd6f4"; font.pixelSize: 13 }
                Slider {
                    id: outVol
                    width: parent.width
                    from: 0; to: 100; value: 50
                    onMoved: outProc.running = true
                }

                Text { text: "Mikrofon"; color: "#cdd6f4"; font.pixelSize: 13 }
                Slider {
                    id: inVol
                    width: parent.width
                    from: 0; to: 100; value: 50
                    onMoved: inProc.running = true
                }
            }
        }

        Process {
            id: outProc
            command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
                      Math.round(outVol.value) + "%"]
        }
        Process {
            id: inProc
            command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@",
                      Math.round(inVol.value) + "%"]
        }
    }
}
