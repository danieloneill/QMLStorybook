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

    WASM *w = new WASM();

    QQmlApplicationEngine engine;
    const QUrl url("qrc:/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("WASM", w);

    engine.load(url);

    return app.exec();
}
