import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Common
import qs.Widgets

PanelWindow {
    id: root

    property bool translatorVisible: false
    property real triggerX: (Screen.width - 600) / 2
    property real triggerY: Theme.barHeight + Theme.spacingS
    property real triggerWidth: 60
    property string triggerSection: "center"
    property var triggerScreen: null

    function setTriggerPosition(x, y, width, section, screen) {
        triggerX = x;
        triggerY = y;
        triggerWidth = width;
        triggerSection = section;
        triggerScreen = screen;
    }

    visible: translatorVisible
    screen: triggerScreen
    implicitWidth: 900
    implicitHeight: 560
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: translatorVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            var localPos = mapToItem(contentLoader, mouse.x, mouse.y);
            if (localPos.x < 0 || localPos.x > contentLoader.width || localPos.y < 0 || localPos.y > contentLoader.height)
                translatorVisible = false;

        }
    }

    Loader {
        id: contentLoader

        readonly property real screenWidth: root.screen ? root.screen.width : Screen.width
        readonly property real screenHeight: root.screen ? root.screen.height : Screen.height
        readonly property real targetWidth: Math.min(900, screenWidth - Theme.spacingL * 2)
        readonly property real targetHeight: Math.min(600, screenHeight - Theme.barHeight - Theme.spacingS * 2)
        readonly property real calculatedX: {
            var centerX = root.triggerX + (root.triggerWidth / 2) - (targetWidth / 2);
            if (centerX >= Theme.spacingM && centerX + targetWidth <= screenWidth - Theme.spacingM)
                return centerX;

            if (centerX < Theme.spacingM)
                return Theme.spacingM;

            if (centerX + targetWidth > screenWidth - Theme.spacingM)
                return screenWidth - targetWidth - Theme.spacingM;

            return centerX;
        }

        asynchronous: true
        active: translatorVisible
        width: targetWidth
        height: item ? item.implicitHeight : targetHeight
        x: calculatedX
        y: root.triggerY
        opacity: translatorVisible ? 1 : 0
        scale: translatorVisible ? 1 : 0.9

        Behavior on opacity {
            NumberAnimation {
                duration: Anims.durMed
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Anims.emphasized
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: Anims.durMed
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Anims.emphasized
            }

        }

        sourceComponent: Rectangle {
            id: dropdownContent

            implicitHeight: contentColumn.height + Theme.spacingL * 2
            radius: Theme.cornerRadius
            color: Theme.popupBackground()
            border.color: Theme.outlineMedium
            border.width: 1
            clip: true
            antialiasing: true
            smooth: true
            focus: true
            Component.onCompleted: {
                if (root.translatorVisible)
                    forceActiveFocus();

            }
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    root.translatorVisible = false;
                    event.accepted = true;
                }
            }

            Column {
                id: contentColumn

                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingL

                Item {
                    width: parent.width
                    height: 32

                    StyledText {
                        text: "Translator"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledRect {
                        width: 32
                        height: 32
                        radius: 16
                        color: closeArea.containsMouse ? Theme.errorHover : "transparent"
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        border.color: Theme.outlineMedium
                        border.width: 1

                        DankIcon {
                            anchors.centerIn: parent
                            name: "close"
                            size: Theme.iconSize - 6
                            color: closeArea.containsMouse ? Theme.error : Theme.surfaceText
                        }

                        MouseArea {
                            id: closeArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.translatorVisible = false
                        }

                    }

                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.outlineMedium
                    radius: 1
                    opacity: 0.5
                }

                // The actual translator widget
                DankTranslator {
                    id: translator

                    width: parent.width
                }

            }

        }

    }

}
