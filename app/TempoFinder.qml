import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0

// --------------------------------------------------- TEMPO FINDER ------------------------------------------------------
//Tempo Finder Dialog
Component {
    id: tempoFinder

    Dialog {
        id: tempoFinderDialog
        title: i18n.tr("Tempo Finder")
        width: pageLayout.width
        height: pageLayout.height

        signal closing()

        text: i18n.tr("The tempo finder determines a tempo based on the tempo of two clicks. Please use the button below to click twice for a tempo.")
        Column {
            spacing: units.gu(1)

            Row {
                spacing: units.gu(1)
                Button {

                    text: i18n.tr("Press")
                    color: primaryColor
                    property int altValue: 0    // used to alternate the Text of the "Press" button
                    property double timeOne: 0  // used to calculate the bpm by using the difference between timeOne and timeTwo
                    property double timeTwo: 0
                    onClicked: {
                        altValue += 1           // alternate value
                        if (altValue%2 == 0) {
                            text = i18n.tr("Press")

                            //this runs after the second click; therefore, get the second time
                            timeTwo = Number(new Date().getTime());

                            //calculate bpm
                            if (timeOne != -1 && timeTwo != -1) {
                                var milliSec = timeTwo-timeOne
                                tempoFinderTempo.text = Math.round(calculateBpm(milliSec))
                            }
                        }

                        else {
                            text = i18n.tr("Press Again")

                            //this runs after the first click; therefore, get the first timeOne
                            timeOne = Number(new Date().getTime());
                        }
                    }
                }
                Label {     // displays the tempo from the two clicks
                    id: tempoFinderTempo
                    text: i18n.tr("0")
                    fontSize: "large"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {     // displays "bpm" next to the tempo
                    text: i18n.tr("bpm")
                    fontSize: "large"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                spacing: units.gu(1)
                Button {
                    id: closeButton
                    text: i18n.tr("Close")
                    color: primaryColor
                    onClicked: PopupUtils.close(tempoFinderDialog)
                }
                Button {
                    id: acceptTempoButton
                    text: i18n.tr("Use This Tempo")
                    color: primaryColor


                    onClicked: {
                        //set the tempo
                        var tempo = tempoFinderTempo.text*1;
                        if (tempo >= 30 && tempo <= 240) {
                            timer.bpmCount = tempo;
                            tempoFinderDialog.closing();
                            PopupUtils.close(tempoFinderDialog)
                        }
                        else {
                            //display help to user
                            userHelp.text = i18n.tr("Please only submit a number that is between 30 and 240")
                        }
                    }
                }
            }

            TextArea {
                id: userHelp
                readOnly: true
                width: parent.width
            }

        }
    }
}
