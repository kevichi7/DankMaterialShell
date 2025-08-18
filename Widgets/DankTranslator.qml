import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets

Item {
    id: root

    // Public API
    property string placeholderText: "Enter text to translate"
    property string inputText: ""
    property string translatedText: ""
    property string sourceLanguage: "Auto Detect"
    property string targetLanguage: "English"
    property bool featureAvailable: false
    property bool isTranslating: false
    property string resolvedTransBinary: ""
    // Language options (display names aligned with codes)
    readonly property var languageOptions: ["Auto Detect", "English", "Spanish", "French", "German", "Italian", "Portuguese", "Russian", "Japanese", "Korean", "Chinese (Simplified)", "Chinese (Traditional)", "Arabic", "Hindi", "Bengali", "Dutch", "Polish", "Swedish", "Turkish", "Vietnamese", "Greek", "Hebrew", "Thai", "Indonesian", "Czech", "Finnish", "Norwegian", "Danish", "Ukrainian", "Romanian", "Hungarian"]
    readonly property var languageCodes: ["auto", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh-CN", "zh-TW", "ar", "hi", "bn", "nl", "pl", "sv", "tr", "vi", "el", "he", "th", "id", "cs", "fi", "no", "da", "uk", "ro", "hu"]

    // Helper to get language code by name
    function codeFor(name) {
        var idx = languageOptions.indexOf(name);
        if (idx >= 0 && idx < languageCodes.length)
            return languageCodes[idx];

        return "auto";
    }

    function translateNow() {
        if (!featureAvailable) {
            translatedText = "'trans' not available on system";
            return ;
        }
        var text = inputField.text.trim();
        if (!text || text.length === 0) {
            translatedText = "";
            return ;
        }
        var srcCode = codeFor(sourceLanguage);
        var tgtCode = codeFor(targetLanguage);
        if (!tgtCode || tgtCode === "auto")
            tgtCode = "en";

        var pair = srcCode === "auto" ? (":" + tgtCode) : (srcCode + ":" + tgtCode);
        var bin = resolvedTransBinary && resolvedTransBinary.length > 0 ? resolvedTransBinary : "trans";
        transProc.command = [bin, "-b", "-no-ansi", pair, text];
        isTranslating = true;
        translatedText = "";
        transProc.running = true;
    }

    // Layout sizing
    width: parent ? parent.width : 600
    implicitWidth: 600
    implicitHeight: inputRow.height + Theme.spacingS + outputCard.height
    // Check for 'trans' availability
    Component.onCompleted: {
        checkProc.running = true;
    }

    // Header row: language selects and actions
    RowLayout {
        id: inputRow

        width: parent.width
        spacing: Theme.spacingS

        DankDropdown {
            id: srcDropdown

            Layout.preferredWidth: Math.max(260, parent.width * 0.3)
            text: "From"
            description: "Source language"
            options: root.languageOptions
            optionIcons: options.map(function() {
                return "translate";
            })
            enableFuzzySearch: true
            currentValue: root.sourceLanguage
            onValueChanged: (value) => {
                return root.sourceLanguage = value;
            }
        }

        StyledRect {
            width: 36
            height: 36
            radius: Theme.cornerRadius
            color: swapArea.containsMouse ? Theme.primaryHover : Theme.contentBackground()
            border.color: Theme.surfaceVariantAlpha
            border.width: 1
            Layout.preferredWidth: 36
            Layout.alignment: Qt.AlignVCenter

            DankIcon {
                anchors.centerIn: parent
                name: "swap_horiz"
                size: Theme.iconSize - 6
                color: Theme.surfaceText
            }

            StateLayer {
                cornerRadius: parent.radius
                onClicked: {
                    var oldSrc = root.sourceLanguage;
                    var oldTgt = root.targetLanguage;
                    root.sourceLanguage = oldTgt;
                    root.targetLanguage = oldSrc;
                    // Ensure dropdowns stay bound and visually update
                    srcDropdown.currentValue = Qt.binding(function() {
                        return root.sourceLanguage;
                    });
                    tgtDropdown.currentValue = Qt.binding(function() {
                        return root.targetLanguage;
                    });
                }
            }

            MouseArea {
                id: swapArea

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }

        }

        DankDropdown {
            id: tgtDropdown

            Layout.preferredWidth: Math.max(260, parent.width * 0.3)
            text: "To"
            description: "Target language"
            options: root.languageOptions
            optionIcons: options.map(function() {
                return "translate";
            })
            enableFuzzySearch: true
            currentValue: root.targetLanguage
            onValueChanged: (value) => {
                return root.targetLanguage = value;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        StyledRect {
            id: translateButton

            Layout.preferredWidth: 140
            height: 36
            radius: Theme.cornerRadius
            color: translateArea.containsMouse ? Theme.primaryHover : Theme.primary
            enabled: featureAvailable
            Layout.alignment: Qt.AlignVCenter

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacingS

                DankIcon {
                    name: isTranslating ? "hourglass_empty" : "translate"
                    size: Theme.iconSize - 6
                    color: Theme.primaryText
                }

                StyledText {
                    text: isTranslating ? "Translating" : "Translate"
                    color: Theme.primaryText
                    font.pixelSize: Theme.fontSizeMedium
                }

            }

            StateLayer {
                cornerRadius: parent.radius
                onClicked: translateNow()
            }

            MouseArea {
                id: translateArea

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }

        }

    }

    // Input field
    DankTextField {
        id: inputField

        anchors.top: inputRow.bottom
        anchors.topMargin: Theme.spacingS
        width: parent.width
        height: 48
        leftIconName: "text_fields"
        placeholderText: root.placeholderText
        text: root.inputText
        showClearButton: true
        onAccepted: translateNow()
        onTextEdited: root.inputText = text
    }

    // Output card
    StyledRect {
        id: outputCard

        anchors.top: inputField.bottom
        anchors.topMargin: Theme.spacingS
        width: parent.width
        height: Math.max(80, outputText.implicitHeight + Theme.spacingL)
        radius: Theme.cornerRadius
        color: Theme.popupBackground()
        border.color: Theme.primarySelected
        border.width: 1

        StyledText {
            id: outputText

            anchors.fill: parent
            anchors.margins: Theme.spacingM
            text: isTranslating ? "Translating..." : (featureAvailable ? (root.translatedText || "") : "'trans' not installed")
            color: Theme.surfaceText
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            elide: Text.ElideNone
        }

        Row {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: Theme.spacingS
            anchors.topMargin: Theme.spacingS
            spacing: Theme.spacingS

            StyledRect {
                width: 32
                height: 32
                radius: 16
                color: copyArea.containsMouse ? Theme.primaryHover : Theme.contentBackground()
                enabled: root.translatedText.length > 0
                border.color: Theme.surfaceVariantAlpha
                border.width: 1

                DankIcon {
                    anchors.centerIn: parent
                    name: "content_copy"
                    size: Theme.iconSize - 8
                    color: Theme.surfaceText
                }

                StateLayer {
                    cornerRadius: 16
                    onClicked: {
                        if (root.translatedText && root.translatedText.length > 0) {
                            copyProc.command = ["bash", "-lc", "wl-copy --type text/plain --foreground <<'EOF'\n" + root.translatedText + "\nEOF\n"];
                            copyProc.running = true;
                        }
                    }
                }

                MouseArea {
                    id: copyArea

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

            }

        }

    }

    // Processes
    Process {
        id: checkProc

        // Try common locations to find 'trans' in diverse setups
        command: ["bash", "-lc", "for p in trans /run/current-system/sw/bin/trans /usr/bin/trans /bin/trans $HOME/.nix-profile/bin/trans $HOME/.local/bin/trans; do command -v \"$p\" >/dev/null 2>&1 && echo \"$p\" && exit 0; done; echo missing"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var out = (text || "").trim();
                if (out && out !== "missing") {
                    root.resolvedTransBinary = out;
                    root.featureAvailable = true;
                } else {
                    root.featureAvailable = false;
                }
            }
        }

    }

    Process {
        id: transProc

        command: ["trans", "-b", ":en", "hello"]
        running: false
        onExited: (exitCode) => {
            isTranslating = false;
            if (exitCode !== 0)
                translatedText = "Translation failed";

        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (text && text.length > 0)
                    root.translatedText = text.trim();

            }
        }

    }

    Process {
        id: copyProc

        command: ["bash", "-lc", "echo"]
        running: false
    }

}
