import QtQuick 2.2
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0


// ------------------------------------------- BEAT SELECTOR ---------------------------------------------
Component {
     id: beatSelector
     Popover {                          // popover to select beat
         id: popover
         Column {
             height: pageLayout.height  // fill to the height of the page
             width: parent.width;

             // ------------------- HEADER ------------------------
             PopoverHeader {
                 id: bHeader;
                 text: "Choose from beat selection";
                 width: parent.width;
             }

             // ------------------- LIST -------------------------
             ListView {                 // List all the beats
                 height: pageLayout.height - bHeader.height;
                 width: parent.width

                 spacing: units.gu(1);

                 clip: true;

                 // Define how to display section headers in the beat list
                 section.property: "type"   // use this property of the beats

                 // ------------------------ SECTION HEADER --------------------
                 section.delegate: Rectangle {
                     width: parent.width
                     height: childrenRect.height;

                     Column {
                         width: parent.width;

                         Label {
                             id: innerTxt;
                             text: section      // get the section name

                             anchors.horizontalCenter: parent.horizontalCenter;
                             verticalAlignment: Text.AlignVCenter;

                             height: paintedHeight + units.gu(1);

                             fontSize: "large";
                             font.bold: true
                         }

                         Rectangle {
                             height: 2;
                             width: parent.width;

                             color: "grey";
                         }
                     }
                 }

                 model: beats               // fill the ListView with the beats

                 // ---------------------------- ITEMS --------------------------------

                 delegate: MouseArea {       // with each beat, use a Standard item
                     //text: name             // display the name of the beat
                     height: childrenRect.height;
                     width: parent.width;

                     Column {
                         spacing: units.gu(1);

                         width: parent.width;

                         Image {
                             id: image
                             source: "./graphics/icons/" + img;

                             anchors.horizontalCenter: parent.horizontalCenter;
                         }

                         Rectangle {    // divider
                             id: divider
                             height: 2;
                             width: parent.width;

                             color: "#DDDDDD"
                         }
                     }
                     onClicked: {           // Do this when the name is clicked
                         beatButton.text = i18n.tr(name)    // update the name of the button
                         timer.subdivisions = number        // update the properties of the timer
                         timer.num = 0
                         timer.pattern = pattern
                         timer.silentPattern = silentPattern
                         timer.tempoDivisions = tempoDiv
                         beatImage.source = "./graphics/icons/" + img  // update the image of the beat
                         hide()             // I am done with the beat selector, so hide it
                     }
                 }
             }
         }
     }
}
