#ifndef WASM_H
#define WASM_H

#include <QClipboard>
#include <QFileSystemWatcher>
#include <QJSValue>
#include <QObject>
#include <QLocale>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QTranslator>
#include <QVariantMap>
#ifndef __EMSCRIPTEN__
# include <QSettings>
#endif

class Watcher : public QObject {
    Q_OBJECT

    QFileSystemWatcher  m_watcher;

public:
    Watcher(QObject *parent=nullptr);

    Q_INVOKABLE bool watch(const QString &path);

signals:
    void fileChanged(const QString &path);

};

class WASM : public QObject
{
    Q_OBJECT

    QNetworkAccessManager   m_qnam;
    QClipboard              *m_clipboard;
    QTranslator             *m_translator;
    QVariantMap             m_settings;

#ifndef __EMSCRIPTEN__
    QSettings               *m_qsettings;
#endif

    Q_PROPERTY(QString buildTime READ buildTime CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)

public:
    explicit WASM(QObject *parent=nullptr);
    ~WASM();

    Q_INVOKABLE QVariantMap queryItems();
    Q_INVOKABLE QString location();

    Q_INVOKABLE QVariant value(const QString &key);
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
    Q_INVOKABLE bool setIfUndef(const QString &key, const QVariant &value);

    Q_INVOKABLE static QString sha256(const QVariant &data );
    Q_INVOKABLE static QString uuid();
    Q_INVOKABLE static QString toBase64(const QByteArray &data);
    Q_INVOKABLE static QByteArray fromBase64(const QString &data);

#ifdef __EMSCRIPTEN__
    Q_INVOKABLE static void log(const QString &format, const QVariantList &args);
#endif

    Q_INVOKABLE bool setLanguage(const QString &langcode);
    Q_INVOKABLE void remoteTranslation(const QString &langcode);

    Q_INVOKABLE Watcher *watcher();

    Q_INVOKABLE void handleUpload(QJSValue callback);
    Q_INVOKABLE bool get(const QString &url, QJSValue callback);

    Q_INVOKABLE QVariant readFile(const QString &path);

#ifdef __EMSCRIPTEN__
    Q_INVOKABLE QString eval(const QString &code);
#endif

    // Clipboard related:
    Q_INVOKABLE QByteArray clipboardImage();
    Q_INVOKABLE bool clipboardHasImage();

private:
    bool loadCache();
    void saveCache();

    void replaceTranslator(QTranslator *translator);

    QString buildTime();
    QString version();

signals:
    void translated();
};

#endif // WASM_H
