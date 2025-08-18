import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Modules.Settings
import qs.Widgets
pragma ComponentBehavior

DankModal {
    id: settingsModal

    property Component settingsContent

    signal closingModal()

    function show() {
        settingsModal.visible = true;
    }

    function hide() {
        settingsModal.visible = false;
    }

    function toggle() {
        if (settingsModal.visible)
            hide();
        else
            show();
    }

    width: 750
    height: 750
    visible: false
    keyboardFocus: "ondemand"
    onBackgroundClicked: hide()
    content: settingsContent

    IpcHandler {
        function open() {
            settingsModal.show();
            return "SETTINGS_OPEN_SUCCESS";
        }

        function close() {
            settingsModal.hide();
            return "SETTINGS_CLOSE_SUCCESS";
        }

        function toggle() {
            settingsModal.toggle();
            return "SETTINGS_TOGGLE_SUCCESS";
        }

        target: "settings"
    }

    settingsContent: Component {
        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    settingsModal.hide();
                    event.accepted = true;
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS

                RowLayout {
                    width: parent.width
                    spacing: Theme.spacingM

                    DankIcon {
                        name: "settings"
                        size: Theme.iconSize
                        color: Theme.primary
                        Layout.alignment: Qt.AlignVCenter
                    }

                    StyledText {
                        text: "Settings"
                        font.pixelSize: Theme.fontSizeXLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                        width: 1
                        height: 1
                    }

                    // Reload Shell button
                    StyledRect {
                        id: reloadButton

                        width: 120
                        height: 32
                        radius: Theme.cornerRadius
                        color: reloadArea.containsMouse ? Theme.primaryHover : Theme.primary
                        // Keep the button vertically centered in the header layout
                        Layout.alignment: Qt.AlignVCenter

                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            DankIcon {
                                name: "restart_alt"
                                size: Theme.iconSizeSmall
                                color: Theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: "Reload"
                                color: Theme.primaryText
                                font.pixelSize: Theme.fontSizeSmall
                                anchors.verticalCenter: parent.verticalCenter
                            }

                        }

                        MouseArea {
                            id: reloadArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Trigger a configuration reload by touching the main shell file
                                const cfg = StandardPaths.writableLocation(StandardPaths.ConfigLocation);
                                const path = cfg + "/quickshell/DankMaterialShell/shell.qml";
                                Quickshell.execDetached(["sh", "-lc", "touch \"" + path + "\""]);
                                if (typeof ToastService !== "undefined")
                                    ToastService.showInfo("Reloading shell…");

                            }
                        }

                    }

                    DankActionButton {
                        circular: false
                        iconName: "close"
                        iconSize: Theme.iconSize - 4
                        iconColor: Theme.surfaceText
                        hoverColor: Theme.errorHover
                        onClicked: settingsModal.hide()
                        Layout.alignment: Qt.AlignVCenter
                    }

                }

                Column {
                    width: parent.width
                    height: parent.height - 50
                    spacing: 0

                    DankTabBar {
                        id: settingsTabBar

                        width: parent.width
                        model: [{
                            "text": "Personalization",
                            "icon": "person"
                        }, {
                            "text": "Time & Weather",
                            "icon": "schedule"
                        }, {
                            "text": "Widgets",
                            "icon": "widgets"
                        }, {
                            "text": "Launcher",
                            "icon": "apps"
                        }, {
                            "text": "Appearance",
                            "icon": "palette"
                        }]
                    }

                    Item {
                        width: parent.width
                        height: parent.height - settingsTabBar.height

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: Theme.spacingL
                            color: "transparent"

                            Loader {
                                id: personalizationLoader

                                anchors.fill: parent
                                active: settingsTabBar.currentIndex === 0
                                visible: active
                                asynchronous: true

                                sourceComponent: Component {
                                    PersonalizationTab {
                                    }

                                }

                            }

                            Loader {
                                id: timeWeatherLoader

                                anchors.fill: parent
                                active: settingsTabBar.currentIndex === 1
                                visible: active
                                asynchronous: true

                                sourceComponent: Component {
                                    TimeWeatherTab {
                                    }

                                }

                            }

                            Loader {
                                id: widgetsLoader

                                anchors.fill: parent
                                active: settingsTabBar.currentIndex === 2
                                visible: active
                                asynchronous: true

                                sourceComponent: Component {
                                    WidgetsTab {
                                    }

                                }

                            }

                            Loader {
                                id: launcherLoader

                                anchors.fill: parent
                                active: settingsTabBar.currentIndex === 3
                                visible: active
                                asynchronous: true

                                sourceComponent: Component {
                                    LauncherTab {
                                    }

                                }

                            }

                            Loader {
                                id: appearanceLoader

                                anchors.fill: parent
                                active: settingsTabBar.currentIndex === 4
                                visible: active
                                asynchronous: true

                                sourceComponent: Component {
                                    AppearanceTab {
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
