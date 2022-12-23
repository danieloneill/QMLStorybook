#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "wasm.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("Canapos");
    app.setOrganizationDomain("com.canapos");
    app.setApplicationName("Storybook");

    QQmlApplicationEngine engine;

    QUrl url("qrc:/main.qml");
    if( argc > 1 )
        url = QUrl::fromLocalFile( QString::fromLocal8Bit( argv[1] ) );

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    WASM *w = new WASM(&engine);
    engine.rootContext()->setContextProperty("WASM", w);

    engine.load(url);

    return app.exec();
}
