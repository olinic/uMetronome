import QtQuick 2.0
import Ubuntu.Components 1.1

Action {
    iconName: "settings" //does not work right now
    //iconSource: "../icons/settings.svg"
    text: i18n.tr("Settings")

    onTriggered: {
        tabs.selectedTabIndex = 1;
    }
}
