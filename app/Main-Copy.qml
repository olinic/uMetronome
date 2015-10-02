import QtQuick 2.0
import Ubuntu.Components 1.2
import UMetronome 1.0

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "umetronome.oliver-nic012"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(100)
    height: units.gu(76)

    Page {
        title: i18n.tr("uMetronome")

        MyType {
            id: myType

            Component.onCompleted: {
                myType.helloWorld = i18n.tr("Hello world..")
            }
        }

        UTimer {
            id: timer;
            interval: 100;

            singleShot: false;

            onTimeout: {
                display.update(100);
            }

        }

        Beats{}


        Column {
            spacing: units.gu(1)
            anchors {
                margins: units.gu(2)
                fill: parent
            }

            Label {
                id: label
                objectName: "label"

                text: myType.helloWorld
            }

            Button {

                objectName: "button"
                width: parent.width

                text: i18n.tr("Tap me!")

                onClicked: {
                    myType.helloWorld = i18n.tr("..from Cpp Backend")
                    timer.start();
                }
            }

            Text {
                id: display;

                font.pointSize: 22;



                text: "0";
                property int milliSeconds: 0;

                function update(ms) {
                    milliSeconds = milliSeconds + ms;
                    text = milliSeconds/100;

                }
            }
        }
    }
}

