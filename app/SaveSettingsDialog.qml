import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
// ------------------------------------------------ SAVE SETTINGS DIALOG ---------------------------------------------------
// popup that display when the "save settings" button is clicked
Component {
    id: dialog
    Dialog {
        id: dialogue
        title: i18n.tr("Confirmation")
        text: i18n.tr("Your settings have been saved!")
        Button {
            text: i18n.tr("Ok")
            color: positiveColor
            onClicked: PopupUtils.close(dialogue)   // close the dialog when the user clicks Ok
        }
    }
}
