cmake_minimum_required(VERSION 3.21)

project(ChevelRobotControlCenter VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

qt_policy(SET QTP0004 NEW)

set(QML_FILES
    qml/Main.qml
    qml/TestWindow.qml
    qml/components/CameraMapPanel.qml
    qml/components/CommandPanel.qml
    qml/components/ConfirmModal.qml
    qml/components/Gauge.qml
    qml/components/IndustrialButton.qml
    qml/components/LogConsole.qml
    qml/components/RobotHealthPanel.qml
    qml/components/StatusLight.qml
    qml/components/TelemetryPanel.qml
)

set_source_files_properties(qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS Main.qml)
set_source_files_properties(qml/TestWindow.qml PROPERTIES QT_RESOURCE_ALIAS TestWindow.qml)
set_source_files_properties(qml/components/CameraMapPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/CameraMapPanel.qml)
set_source_files_properties(qml/components/CommandPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/CommandPanel.qml)
set_source_files_properties(qml/components/ConfirmModal.qml PROPERTIES QT_RESOURCE_ALIAS components/ConfirmModal.qml)
set_source_files_properties(qml/components/Gauge.qml PROPERTIES QT_RESOURCE_ALIAS components/Gauge.qml)
set_source_files_properties(qml/components/IndustrialButton.qml PROPERTIES QT_RESOURCE_ALIAS components/IndustrialButton.qml)
set_source_files_properties(qml/components/LogConsole.qml PROPERTIES QT_RESOURCE_ALIAS components/LogConsole.qml)
set_source_files_properties(qml/components/RobotHealthPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/RobotHealthPanel.qml)
set_source_files_properties(qml/components/StatusLight.qml PROPERTIES QT_RESOURCE_ALIAS components/StatusLight.qml)
set_source_files_properties(qml/components/TelemetryPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/TelemetryPanel.qml)

qt_add_executable(ChevelRobotControlCenter
    main.cpp
    src/RobotCommandInterface.h
    src/RobotCommandInterface.cpp
    src/RobotController.h
    src/RobotController.cpp
    src/TelemetryModel.h
    src/TelemetryModel.cpp
)

qt_add_qml_module(ChevelRobotControlCenter
    URI Chevel.Rocket
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    QML_FILES ${QML_FILES}
)

target_include_directories(ChevelRobotControlCenter PRIVATE src)

target_compile_definitions(ChevelRobotControlCenter
    PRIVATE
        CHEVEL_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(ChevelRobotControlCenter
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)
