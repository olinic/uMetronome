import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.Pickers 1.0



Item {
    id: tempoSection
    //Layouts.item: "tempoItem"

    height: childrenRect.height;
    //width: childrenRect.width;

    function getUpdate() { // do not use for regular updates (only finder updates)
        // update remains false so that a change is registered and can propagate
        bpm = timer.bpmCount;

        tempoPicker.selectedIndex = bpm - tempoPicker.start;
    }

    function update(newBpm) {
        // update the picker
        updating = true;
        bpm = newBpm;

        tempoPicker.selectedIndex = bpm - tempoPicker.start;
    }

    property int bpm: timer.bpmCount;
    property bool updating: false // prevents a loop in bpm changes
    signal changed() // used to indicate if the picker is changing (not the same as updating)

    Button {
        id: tempoFinderButton
        iconName: "search"
        iconSource: picPath + "search.svg"
        color: "#1ab6ef"

        anchors {
            right: tempoPicker.left
            verticalCenter: tempoPicker.verticalCenter
            margins: units.gu(1)
        }
        height: units.gu(6)
        width: units.gu(6)



        onClicked: {
            var finder = PopupUtils.open(tempoFinder)
            finder.closing.connect(getUpdate)
        }
    }



    Picker {
        id: tempoPicker
        circular: true
        live: false

        height: tempoPickerHeight

        property int start: 30
        property int end: 240

        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        delegate: PickerDelegate {
            Label {
                text: modelData
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter


            }
        }

        onSelectedIndexChanged: {
            if (tempoSection.updating) { // don't mess with the bpm if it is already up to date
                tempoSection.updating = false;
            }
            else { // update bpm when picker changes

                tempoSection.bpm = tempoPicker.selectedIndex + tempoPicker.start// minus two because this is the text 2 below the selected index
                //console.log("BPM = " + timer.bpmCount)
                tempoSection.changed();
            }
        }

        //add all the values to the picker, set the picker to the timer's bpmCount
        Component.onCompleted: {
            var stack = [];
            var myTime = timer.bpmCount
            for (var i=start; i<end+1; i++) {
                stack.push(i)
            }
            model = stack

            selectedIndex = myTime - start
            //console.log("Selected Index = " + selectedIndex)

        }
    }

    Label {
        text: " bpm"
        fontSize: "large"
        anchors {
            left: tempoPicker.right
            verticalCenter: tempoPicker.verticalCenter
        }
    }
 }
