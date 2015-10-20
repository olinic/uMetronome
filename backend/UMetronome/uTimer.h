#ifndef UTIMER_H
#define UTIMER_H

#include <QTimer>
#include <QObject>

class UTimer : public QTimer {

    Q_OBJECT
    Q_PROPERTY( int interval READ interval WRITE setInterval NOTIFY intervalChanged )   // add notify
    Q_PROPERTY( bool active READ isActive NOTIFY activeChanged )   // add notify

public:
    explicit UTimer(QObject *parent = 0);
    ~UTimer();

Q_SIGNALS:
    void intervalChanged();
    void activeChanged();
};


#endif // UTIMER_H
