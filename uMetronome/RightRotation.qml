import QtQuick 2.0

RotationAnimation {
    id: rightRotation
    target: metronomeLine
    duration: timer.interval*(timer.subdivisions)
    direction: RotationAnimation.Shortest
    property: "rotation"
    from: 300
    to: 60
}
