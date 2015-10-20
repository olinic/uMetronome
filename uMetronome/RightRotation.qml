import QtQuick 2.0

/*
  This is an animation used to rotate the metronome line to the right

*/

RotationAnimation {
    id: rightRotation
    target: metronomeLine
    duration: timer.interval*(timer.subdivisions)
    direction: RotationAnimation.Shortest
    property: "rotation"
    from: 300
    to: 60
}
