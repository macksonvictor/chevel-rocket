#include <QGuiApplication>
#include <QDebug>
#include <QLibraryInfo>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlError>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QUrl>

#include "RobotController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QGuiApplication::setOrganizationName("Chevel");
    QGuiApplication::setApplicationName("CHEVEL ROCKET");
    QQuickStyle::setStyle("Basic");

    qDebug() << "CHEVEL ROCKET boot";
    qDebug() << "Application dir:" << QCoreApplication::applicationDirPath();
    qDebug() << "Qt QML imports:" << QLibraryInfo::path(QLibraryInfo::QmlImportsPath);

    RobotController robotController;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("robotController", &robotController);
    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(QCoreApplication::applicationDirPath());
    engine.addImportPath(QLibraryInfo::path(QLibraryInfo::QmlImportsPath));

    QObject::connect(&engine, &QQmlApplicationEngine::warnings, [](const QList<QQmlError> &warnings) {
        for (const QQmlError &warning : warnings) {
            qWarning().noquote() << "QML:" << warning.toString();
        }
    });

    const bool testWindow = QCoreApplication::arguments().contains("--test-window");
    const QString typeName = testWindow ? QStringLiteral("TestWindow") : QStringLiteral("Main");

    qDebug() << "Loading QML module:" << "Chevel.Rocket" << typeName;
    engine.loadFromModule("Chevel.Rocket", typeName);

    if (engine.rootObjects().isEmpty()) {
        const QString localQmlPath = QDir(QStringLiteral(CHEVEL_SOURCE_DIR))
            .absoluteFilePath(testWindow ? "qml/TestWindow.qml" : "qml/Main.qml");
        const QUrl localQmlUrl = QUrl::fromLocalFile(localQmlPath);

        qWarning() << "Module load returned no root objects. Trying local file:" << localQmlUrl;
        if (QFileInfo::exists(localQmlPath)) {
            engine.load(localQmlUrl);
        } else {
            qCritical() << "Local QML file was not found:" << localQmlPath;
        }
    }

    qDebug() << "QML root object count:" << engine.rootObjects().size();
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "CHEVEL ROCKET failed to create the main QML window.";
        return EXIT_FAILURE;
    }

    QObject *rootObject = engine.rootObjects().first();
    qDebug() << "QML root object:" << rootObject->metaObject()->className();

    if (auto *window = qobject_cast<QQuickWindow *>(rootObject)) {
        qDebug() << "Showing QQuickWindow";
        window->show();
        window->raise();
        window->requestActivate();
    } else {
        qWarning() << "Root object is not a QQuickWindow. UI may not be visible.";
    }

    return app.exec();
}
