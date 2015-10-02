import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0


// ------------------------------------------- BEAT SELECTOR ---------------------------------------------
Component {
     id: beatSelector
     Popover {                          // popover to select beat
         id: popover
         Column {
             height: pageLayout.height  // fill to the height of the page

             anchors {
                 top: parent.top
                 left: parent.left
                 right: parent.right
             }


            /* Label {
                id: headerTxt;

                fontSize: "large"

                text: i18n.tr("Choose from beat selection")
             }*/

             PopoverHeader {
                 id: bHeader;
                 text: "Choose from beat selection";
                 width: parent.width;
             }



             ListView {                 // List all the beats
                 height: pageLayout.height - bHeader.height;
                 width: parent.width

                 clip: true;

                 // Define how to display section headers in the beat list
                 section.property: "type"   // use this property of the beats
                 section.delegate: Rectangle {
                     width: parent.width
                     height: units.gu(1)

                     Text {
                         text: section      // get the section name
                         font.bold: true
                     }
                 }

                 model: beats               // fill the ListView with the beats
                 delegate: Standard {       // with each beat, use a Standard item
                     text: name             // display the name of the beat

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
