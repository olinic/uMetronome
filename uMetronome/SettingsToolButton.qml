import QtQuick 2.0
import Ubuntu.Components 1.2

Action {
    iconName: "settings"
    //iconSource: picPath + "settings.svg"
    text: i18n.tr("Settings")

    onTriggered: {
        tabs.selectedTabIndex = 1;
    }
}
