import QtQuick 2.0
import Ubuntu.Components 1.1

Action {
    iconName: "go-to"
    iconSource: "../icons/uMetronome-icon.svg"
    text: i18n.tr("Metronome")

    onTriggered: {
        tabs.selectedTabIndex = 0;
    }
}
