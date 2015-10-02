import QtQuick 2.0
import Ubuntu.Components 1.1

Item {
    id: header;
    property string text: "";

    height: childrenRect.height; // make my height the heigh of my children

    // label
    Label {
       id: headerTxt;

       fontSize: "large"

       text: i18n.tr(header.text);
    }

    // divider
    Rectangle {
        id: divider;

        height: 1;
        width: parent.width;
        color: "black";

        anchors {
            top: headerTxt.bottom;
            topMargin: units.gu(1); // a little space between label and divider
        }
    }

}
