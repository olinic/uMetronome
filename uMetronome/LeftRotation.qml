import QtQuick 2.0

/*
  This is an animation used to rotate the metronome line to the left

*/


RotationAnimation {
    id: leftRotation
    target: metronomeLine
    duration: timer.interval*(timer.subdivisions)
    direction: RotationAnimation.Shortest
    property: "rotation"
    from: 60
    to: 300
}
