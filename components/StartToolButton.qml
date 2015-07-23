import QtQuick 2.0
import Ubuntu.Components 1.1

Action {
    iconName: "media-playback-start"
    text: i18n.tr("Start")

    property bool playing: timer.running

    onPlayingChanged: {
        if (playing) {
            iconName = "media-playback-stop"
            text = i18n.tr("Stop")
        }
        else {
            iconName = "media-playback-start"
            text = i18n.tr("Start")
        }
    }

    onTriggered: {
        if (playing) {
            timer.stop();
        }
        else {
            timer.start();
        }
    }
}
