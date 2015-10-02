#include "uTimer.h"

/*
 * Make sure to add this file name in backend/CMakeLists.txt
 */


UTimer::UTimer(QObject *parent) :
    QTimer(parent)
{
    this->setTimerType(Qt::PreciseTimer);
}

UTimer::~UTimer() {

}

