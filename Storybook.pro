QT += quick widgets

SOURCES += \
        main.cpp \
        wasm.cpp

HEADERS += wasm.h

DEFINES += BUILD_VERSION="\"\\\"dev-git-$$system("git rev-parse HEAD")\\\"\""
DEFINES += BUILD_TIME="\"\\\"$$system("date")\\\"\""

DISTFILES += main.qml \
	controls/ChatMessage.qml \
	controls/MButton.qml \
	controls/MCalendarDayDelegate.qml \
	controls/MCalendar.qml \
	controls/MCheckBox.qml \
	controls/MClippedLabel.qml \
	controls/MCurrencyField.qml \
	controls/MFrame.qml \
	controls/qmldir \
	controls/Storybook.qml \
	controls/Style.qml \
	fonts/Gogh-ExtraBold.otf \
	fonts/Mollen-Regular.otf \
	fonts/TechnaSans-Regular.otf

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
