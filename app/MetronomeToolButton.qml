import QtQuick 2.0
import Ubuntu.Components 1.2

Action {
    iconName: "go-to"
    iconSource: picPath + "uMetronome-icon.svg"
    text: i18n.tr("Metronome")

    onTriggered: {
        tabs.selectedTabIndex = 0;
    }
}
