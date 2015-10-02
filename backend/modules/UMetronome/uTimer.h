#ifndef UTIMER_H
#define UTIMER_H

#include <QTimer>
#include <QObject>

class UTimer : public QTimer {

    Q_OBJECT

public:
    explicit UTimer(QObject *parent = 0);
    ~UTimer();

};


#endif // UTIMER_H
