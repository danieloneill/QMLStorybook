#ifndef WASM_H
#define WASM_H

#include <QClipboard>
#include <QFileSystemWatcher>
#include <QJSValue>
#include <QObject>
#include <QQuickItem>
#include <QVariantMap>
#ifndef __EMSCRIPTEN__
# include <QSettings>
#endif

class Watcher : public QFileSystemWatcher {
    Q_OBJECT
    QML_ELEMENT

public:
    Watcher(QObject *parent=nullptr);

    Q_INVOKABLE bool addPath(const QString &file) { return QFileSystemWatcher::addPath(file); }
    Q_INVOKABLE QStringList addPaths(const QStringList &files) { return QFileSystemWatcher::addPaths(files); }
    Q_INVOKABLE QStringList directories() { return QFileSystemWatcher::directories(); }
    Q_INVOKABLE QStringList files() { return QFileSystemWatcher::files(); }
    Q_INVOKABLE bool removePath(const QString &file) { return QFileSystemWatcher::removePath(file); }
    Q_INVOKABLE QStringList removePaths(const QStringList &files) { return QFileSystemWatcher::removePaths(files); }
};

class QQmlEngine;
class WASM : public QObject
{
    Q_OBJECT

    QQmlEngine              *m_engine;
    QClipboard              *m_clipboard;
    QVariantMap             m_settings;

#ifndef __EMSCRIPTEN__
    QSettings               *m_qsettings;
#endif

    Q_PROPERTY(QString buildTime READ buildTime CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)

public:
    explicit WASM(QQmlEngine *parent);
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

    Q_INVOKABLE Watcher *watcher();
    Q_INVOKABLE void clearComponentCache();

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

    QString buildTime();
    QString version();
};

Q_DECLARE_METATYPE(Watcher*)

#endif // WASM_H
