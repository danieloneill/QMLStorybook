#include "wasm.h"

#include <QDebug>

#include <QApplication>
#include <QBuffer>
#include <QByteArray>
#include <QCryptographicHash>
#include <QDataStream>
#include <QFileDialog>
#include <QIODevice>
#include <QJsonDocument>
#include <QJSEngine>
#include <QMimeData>
#include <QPair>
#include <QQmlEngine>
#ifndef QT_NO_SSL
# include <QSslError>
#endif
#include <QUrlQuery>
#include <QUuid>

#ifndef BUILD_VERSION
# define BUILD_VERSION "dev-0.1"
#endif

#ifdef __EMSCRIPTEN__
#include <emscripten.h>

EM_JS(char*, __js_location, (void), {
    const locstr = window.location.href;
    const len = lengthBytesUTF16(locstr) + 1;
    let strbuf = _malloc(len);
    stringToUTF16(locstr, strbuf, len+1);
    return strbuf;
});

EM_JS(char*, __js_eval, (const char *str, size_t len), {
    const jsstr = UTF16ToString(str, len);
          console.log("Eval: "+jsstr);
    const resstr = eval(jsstr);
    if( !resstr )
        return null;

    const olen = lengthBytesUTF16(resstr) + 1;
    let strbuf = _malloc(olen);
    stringToUTF16(resstr, strbuf, olen+1);
    return strbuf;
});

EM_JS(char *, __js_loadsettings, (void), {
    let name = "settings=";
    let decodedCookie = decodeURIComponent(document.cookie);
    let ca = decodedCookie.split(';');

    for( let i = 0; i < ca.length; i++ )
    {
        let c = ca[i];
        while( c.charAt(0) === ' ' )
        {
            c = c.substring(1);
        }

        if( c.indexOf(name) === 0 )
        {
            const contents = c.substring(name.length, c.length);
            const len = lengthBytesUTF16(contents) + 1;
            let strbuf = _malloc(len);
            stringToUTF16(contents, strbuf, len+1);
            return strbuf;
        }
    }
    return 0;
});

EM_JS(void, __js_savesettings, (const char *str, size_t len), {
    const string = UTF16ToString(str, len);
    const encoded = encodeURIComponent(string);
    let now = new Date();
    now.setFullYear( now.getFullYear() + 1 );
    const expires = now.toUTCString();

    document.cookie = "settings="+encoded+"; expires="+expires+"; SameSite=Strict";
});

EM_JS(void, __js_log, (const char *formatstr, size_t formatlen, const char *argsstr, size_t argslen), {
    const jsformat = UTF16ToString(formatstr, formatlen);
    const jsargstr = UTF16ToString(argsstr, argslen);
    try {
        const jsargs = JSON.parse(jsargstr);

        console.log( jsformat, ...jsargs );
    } catch(e) {
        console.log("Failed to log message: "+e);
    }
});
#else
# include <QDir>
#endif

static bool wasm_initialised = false;

WASM::WASM(QQmlEngine *parent)
    : QObject{parent},
      m_engine{parent},
      m_clipboard{QApplication::clipboard()}
{
    if( !wasm_initialised )
    {
        qmlRegisterUncreatableType<Watcher>("org.canapos.Watcher", 1, 0, "Watcher", "Watcher must be instantiated via WASM.watcher");
        wasm_initialised = true;
    }

#ifndef __EMSCRIPTEN__
    m_qsettings = new QSettings();
#endif

    loadCache();
}

WASM::~WASM()
{
#ifndef __EMSCRIPTEN__
    m_qsettings->deleteLater();
#endif
}

QVariantMap WASM::queryItems()
{
    QUrlQuery q = QUrlQuery( QUrl(location()) );

    QVariantMap result;
    for( QPair<QString,QString> pair : q.queryItems() )
    {
        result[ pair.first ] = pair.second;
    }
    return result;
}

QString WASM::location()
{
#ifdef __EMSCRIPTEN__
    char *jsloc = (char *)__js_location();
    QString result = QString::fromUtf16( (const char16_t *)jsloc );
    ::free((void*)jsloc);
    return result;
#else
    return QDir::currentPath();
#endif
}

QVariant WASM::value(const QString &key)
{
    return m_settings.value(key);
}

void WASM::setValue(const QString &key, const QVariant &value)
{
    m_settings[key] = value;

    saveCache();
}

bool WASM::setIfUndef(const QString &key, const QVariant &value)
{
    if( m_settings.contains(key) )
        return false;

    setValue(key, value);
    return true;
}

QString WASM::sha256( const QVariant &data )
{
    return QString( QCryptographicHash::hash( data.toByteArray(), QCryptographicHash::Sha256 ).toHex() );
}

QString WASM::uuid()
{
    return QUuid::createUuid().toString();
}

QString WASM::toBase64(const QByteArray &data)
{
    return QString::fromLatin1( data.toBase64() );
}
QByteArray WASM::fromBase64(const QString &data)
{
    return QByteArray::fromBase64( data.toLatin1() );
}

#ifdef __EMSCRIPTEN__
void WASM::log(const QString &format, const QVariantList &args)
{
    QJsonDocument jsonArgs = QJsonDocument::fromVariant(args);
    QString asJson = QString::fromUtf8(jsonArgs.toJson(QJsonDocument::Compact));
    __js_log( (const char *)format.utf16(), format.length()*2, (const char*)asJson.utf16(), asJson.length()*2 );
}
#endif

QString WASM::version()
{
    return QString::fromLatin1((const char *)BUILD_VERSION);
}

QString WASM::buildTime()
{
    return QString::fromLatin1((const char *)BUILD_TIME);
}

QByteArray WASM::clipboardImage()
{
    QImage image = m_clipboard->image();
    if( image.isNull() )
        return QByteArray();

    QByteArray ba;
    QBuffer buffer(&ba);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "PNG");
    buffer.close();

    return ba;
}

bool WASM::clipboardHasImage()
{
    const QMimeData *md = m_clipboard->mimeData();
    if( !md )
        return false;

    return md->hasImage();
}

#ifdef __EMSCRIPTEN__
bool WASM::loadCache()
{
    const char *encoded = __js_loadsettings();
    if( !encoded )
    {
        qWarning() << "WASM::loadCache(): No previous settings found.";
        return false;
    }

    size_t len = ::strlen(encoded);
    QByteArray ba = QByteArray::fromBase64( QByteArray::fromRawData(encoded, len) );
    ::free((void*)encoded);

    if( ba.length() == 0 )
    {
        qWarning() << "WASM::loadCache(): Failed to decode settings blob, corrupt Base64?";
        return false;
    }

    QDataStream ds(ba);
    ds >> m_settings;

    return true;
}

void WASM::saveCache()
{
    QByteArray ba;
    QDataStream bs(&ba, QIODevice::WriteOnly);
    bs << m_settings;

    QByteArray b64 = ba.toBase64();
    __js_savesettings( b64.constData(), b64.length() );
}

QString WASM::eval(const QString &code)
{
    const ushort *aslatin = code.utf16();
    size_t codelen;
    for( codelen=0; codelen < 8192; codelen++ )
    {
        if( aslatin[codelen] == '\0' )
            break;
    }

    const char *encoded = __js_eval( (const char *)aslatin, codelen*2 );
    if( !encoded )
        return QString();

    return QString::fromUtf16((const char16_t *)encoded);
}
#else
bool WASM::loadCache()
{
    m_settings = m_qsettings->value("wasm_settings", QVariant()).toMap();
    return true;
}

void WASM::saveCache()
{
    m_qsettings->setValue("wasm_settings", m_settings);
}
#endif

QVariant WASM::readFile(const QString &path)
{
    //qDebug() << "WASM::readFile: " << path;
    QFile f(path);
    if( !f.open(QIODevice::ReadOnly) )
    {
        qDebug() << "WASM::readFile: Failed to read file: " << f.errorString();
        return false;
    }

    QByteArray buf = f.readAll();
    f.close();
    return buf;
}

void WASM::clearComponentCache()
{
    if( !m_engine )
    {
        qCritical() << "Couldn't get a QQmlEngine handle.";
        return;
    }
    m_engine->clearComponentCache();
}

Watcher *WASM::watcher()
{
    Watcher *w = new Watcher(this);
    return w;
}

Watcher::Watcher(QObject *parent)
    : QFileSystemWatcher(parent)
{
}

