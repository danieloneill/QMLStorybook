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
    WASM *w = new WASM(&engine);


    /*
     * If you build WASM and want to do something with the URL, do it here.
     *
#ifdef __EMSCRIPTEN__
    // Extract URL path from whatever the browser is pointing at for future resources:
    QUrl origUrl = QUrl(w->location()).adjusted(QUrl::RemoveFilename | QUrl::NormalizePathSegments);
    QUrl url = origUrl.adjusted(QUrl::RemoveQuery);

    // This will be something like http://localhost:8170/qml/main.qml:
    QString outUrl = QString("%1qml/main.qml").arg(url.toString());

    // Load something different?
    if( origUrl.hasQuery() )
    {
        outUrl = QString( "%1/qml/%2" ).arg(url.toString()).arg(origUrl.query());
        qDebug() << "Loading:" << outUrl;
    }

    url = QUrl( outUrl ).adjusted(QUrl::NormalizePathSegments);
#endif
     */

    QUrl url = QUrl("qrc:/main.qml");
    if( argc > 1 )
        url = QUrl( QString::fromLocal8Bit(argv[1]) );

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("WASM", w);

    engine.load(url);

    return app.exec();
}
