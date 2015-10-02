#include <QtQml>
#include <QtQml/QQmlContext>
#include "backend.h"
#include "mytype.h"
#include "uTimer.h"


void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("UMetronome"));
    qmlRegisterType<MyType>(uri, 1, 0, "MyType");
    qmlRegisterType<UTimer>(uri, 1, 0, "UTimer");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
}

