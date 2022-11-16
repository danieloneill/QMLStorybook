QT += quick widgets

SOURCES += \
        main.cpp \
        wasm.cpp

HEADERS += wasm.h

DEFINES += BUILD_VERSION="\"\\\"dev-git-$$system("git rev-parse HEAD")\\\"\""
DEFINES += BUILD_TIME="\"\\\"$$system("date")\\\"\""

resources.prefix = /
resources.files = main.qml
resources.files += controls/
resources.files += fonts/

RESOURCES += resources

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
