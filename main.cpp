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
    QGuiApplication::setApplicationName("Chevel Rocket");
    QQuickStyle::setStyle("Basic");

    qDebug() << "Chevel Rocket boot";
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

    const QString localQmlPath = QDir(QStringLiteral(CHEVEL_SOURCE_DIR))
        .absoluteFilePath(testWindow ? "qml/TestWindow.qml" : "qml/Main.qml");
    const QUrl localQmlUrl = QUrl::fromLocalFile(localQmlPath);

    qDebug() << "Loading local QML first:" << localQmlUrl;
    if (QFileInfo::exists(localQmlPath)) {
        engine.load(localQmlUrl);
    } else {
        qWarning() << "Local QML file was not found. Loading module:" << "Chevel.Rocket" << typeName;
        engine.loadFromModule("Chevel.Rocket", typeName);
    }

    if (engine.rootObjects().isEmpty()) {
        qWarning() << "Local load returned no root objects. Trying module:" << "Chevel.Rocket" << typeName;
        engine.loadFromModule("Chevel.Rocket", typeName);
    }

    qDebug() << "QML root object count:" << engine.rootObjects().size();
    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Chevel Rocket failed to create the main QML window.";
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
