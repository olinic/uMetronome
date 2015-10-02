import QtQuick 2.0
import Ubuntu.Components 1.2

Action {
    iconName: "settings" //does not work right now
    //iconSource: "./graphics/icons/settings.svg"
    text: i18n.tr("Settings")

    onTriggered: {
        tabs.selectedTabIndex = 1;
    }
}
