import QtQuick 2.0
import QtMultimedia 5.0

SoundEffect {
    source: parent.file
    volume: mainBeatSlider.value
}
