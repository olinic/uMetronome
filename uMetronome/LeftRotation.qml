import QtQuick 2.0

RotationAnimation {
    id: leftRotation
    target: metronomeLine
    duration: timer.interval*(timer.subdivisions)
    direction: RotationAnimation.Shortest
    property: "rotation"
    from: 60
    to: 300
}
