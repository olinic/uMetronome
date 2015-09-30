import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
// ------------------------------------------------- TEMPO SELECTION FOR WIDE VIEW -------------------------------------------
Component {
    id: extraTempoSection
    Dialog {
        id: tempoSheet
        title: i18n.tr("Select a tempo")


        ATempoPicker {
            id: insideComponent

            onChanged: {
                //update the other picker
                //console.log(bpm);
                mainTempoPicker.update(bpm);
                timer.bpmCount = bpm;
            }
        }

        Button {
            id: okButton;
            text: i18n.tr("Ok")
            color: positiveColor

            onClicked: {
                PopupUtils.close(tempoSheet)
            }
        }


    }
}
