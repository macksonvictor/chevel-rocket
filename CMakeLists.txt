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
    qml/components/AppIcon.qml
    qml/components/CameraMapPanel.qml
    qml/components/CommandPanel.qml
    qml/components/ConfirmModal.qml
    qml/components/DiagnosticsModal.qml
    qml/components/Gauge.qml
    qml/components/CancelButton.qml
    qml/components/ConfirmButton.qml
    qml/components/DangerButton.qml
    qml/components/DisabledButton.qml
    qml/components/IndustrialButton.qml
    qml/components/LogConsole.qml
    qml/components/PrimaryButton.qml
    qml/components/ReadyButton.qml
    qml/components/RobotHealthPanel.qml
    qml/components/RocketButton.qml
    qml/components/RocketButtonGallery.qml
    qml/components/RocketDangerButton.qml
    qml/components/RocketDialogButton.qml
    qml/components/RocketFooter.qml
    qml/components/RocketIconButton.qml
    qml/components/RocketLogRow.qml
    qml/components/RocketMetricRow.qml
    qml/components/RocketPanel.qml
    qml/components/RocketProgressBar.qml
    qml/components/RocketSegmentedToggle.qml
    qml/components/RocketSidebarItem.qml
    qml/components/RocketStatusPill.qml
    qml/components/RocketTabButton.qml
    qml/components/RocketTopBar.qml
    qml/components/SecondaryButton.qml
    qml/components/SegmentedToggle.qml
    qml/components/StatusLight.qml
    qml/components/StatusPill.qml
    qml/components/TelemetryPanel.qml
    qml/components/ToolStatusCard.qml
    qml/components/TopRightMenu.qml
    qml/components/WarningButton.qml
)

set_source_files_properties(qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS Main.qml)
set_source_files_properties(qml/TestWindow.qml PROPERTIES QT_RESOURCE_ALIAS TestWindow.qml)
set_source_files_properties(qml/components/AppIcon.qml PROPERTIES QT_RESOURCE_ALIAS components/AppIcon.qml)
set_source_files_properties(qml/components/CameraMapPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/CameraMapPanel.qml)
set_source_files_properties(qml/components/CommandPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/CommandPanel.qml)
set_source_files_properties(qml/components/ConfirmModal.qml PROPERTIES QT_RESOURCE_ALIAS components/ConfirmModal.qml)
set_source_files_properties(qml/components/DiagnosticsModal.qml PROPERTIES QT_RESOURCE_ALIAS components/DiagnosticsModal.qml)
set_source_files_properties(qml/components/Gauge.qml PROPERTIES QT_RESOURCE_ALIAS components/Gauge.qml)
set_source_files_properties(qml/components/CancelButton.qml PROPERTIES QT_RESOURCE_ALIAS components/CancelButton.qml)
set_source_files_properties(qml/components/ConfirmButton.qml PROPERTIES QT_RESOURCE_ALIAS components/ConfirmButton.qml)
set_source_files_properties(qml/components/DangerButton.qml PROPERTIES QT_RESOURCE_ALIAS components/DangerButton.qml)
set_source_files_properties(qml/components/DisabledButton.qml PROPERTIES QT_RESOURCE_ALIAS components/DisabledButton.qml)
set_source_files_properties(qml/components/IndustrialButton.qml PROPERTIES QT_RESOURCE_ALIAS components/IndustrialButton.qml)
set_source_files_properties(qml/components/LogConsole.qml PROPERTIES QT_RESOURCE_ALIAS components/LogConsole.qml)
set_source_files_properties(qml/components/PrimaryButton.qml PROPERTIES QT_RESOURCE_ALIAS components/PrimaryButton.qml)
set_source_files_properties(qml/components/ReadyButton.qml PROPERTIES QT_RESOURCE_ALIAS components/ReadyButton.qml)
set_source_files_properties(qml/components/RobotHealthPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/RobotHealthPanel.qml)
set_source_files_properties(qml/components/RocketButton.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketButton.qml)
set_source_files_properties(qml/components/RocketButtonGallery.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketButtonGallery.qml)
set_source_files_properties(qml/components/RocketDangerButton.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketDangerButton.qml)
set_source_files_properties(qml/components/RocketDialogButton.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketDialogButton.qml)
set_source_files_properties(qml/components/RocketFooter.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketFooter.qml)
set_source_files_properties(qml/components/RocketIconButton.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketIconButton.qml)
set_source_files_properties(qml/components/RocketLogRow.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketLogRow.qml)
set_source_files_properties(qml/components/RocketMetricRow.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketMetricRow.qml)
set_source_files_properties(qml/components/RocketPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketPanel.qml)
set_source_files_properties(qml/components/RocketProgressBar.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketProgressBar.qml)
set_source_files_properties(qml/components/RocketSegmentedToggle.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketSegmentedToggle.qml)
set_source_files_properties(qml/components/RocketSidebarItem.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketSidebarItem.qml)
set_source_files_properties(qml/components/RocketStatusPill.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketStatusPill.qml)
set_source_files_properties(qml/components/RocketTabButton.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketTabButton.qml)
set_source_files_properties(qml/components/RocketTopBar.qml PROPERTIES QT_RESOURCE_ALIAS components/RocketTopBar.qml)
set_source_files_properties(qml/components/SecondaryButton.qml PROPERTIES QT_RESOURCE_ALIAS components/SecondaryButton.qml)
set_source_files_properties(qml/components/SegmentedToggle.qml PROPERTIES QT_RESOURCE_ALIAS components/SegmentedToggle.qml)
set_source_files_properties(qml/components/StatusLight.qml PROPERTIES QT_RESOURCE_ALIAS components/StatusLight.qml)
set_source_files_properties(qml/components/StatusPill.qml PROPERTIES QT_RESOURCE_ALIAS components/StatusPill.qml)
set_source_files_properties(qml/components/TelemetryPanel.qml PROPERTIES QT_RESOURCE_ALIAS components/TelemetryPanel.qml)
set_source_files_properties(qml/components/ToolStatusCard.qml PROPERTIES QT_RESOURCE_ALIAS components/ToolStatusCard.qml)
set_source_files_properties(qml/components/TopRightMenu.qml PROPERTIES QT_RESOURCE_ALIAS components/TopRightMenu.qml)
set_source_files_properties(qml/components/WarningButton.qml PROPERTIES QT_RESOURCE_ALIAS components/WarningButton.qml)

file(GLOB ROCKET_ICON_FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" CONFIGURE_DEPENDS
    "assets/ui/icons/single/*.png"
)

set(ASSET_FILES
    assets/ui/branding/chevel-rocket-emblem.png
    assets/ui/branding/chevel-rocket-full.png
    assets/ui/branding/chevel-rocket-header.png
    assets/ui/branding/chevel-rocket-logo.png
    assets/ui/branding/chevel-rocket-topbar.png
    assets/ui/branding/chevel-rocket-wordmark.png
    assets/ui/feeds/camera-feed.png
    assets/ui/icons/actions.png
    assets/ui/icons/mission.png
    assets/ui/icons/nav.png
    assets/ui/icons/status.png
    assets/ui/icons/telemetry.png
    ${ROCKET_ICON_FILES}
    assets/ui/reference/chevel-rocket-reference.png
    assets/ui/robots/dum-e-large.png
    assets/ui/robots/dum-e-preview.png
    assets/ui/safety/emergency-stop-large.png
)

set_source_files_properties(assets/ui/branding/chevel-rocket-emblem.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/branding/chevel-rocket-emblem.png)
set_source_files_properties(assets/ui/branding/chevel-rocket-full.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/branding/chevel-rocket-full.png)
set_source_files_properties(assets/ui/branding/chevel-rocket-header.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/branding/chevel-rocket-header.png)
set_source_files_properties(assets/ui/branding/chevel-rocket-logo.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/branding/chevel-rocket-logo.png)
set_source_files_properties(assets/ui/branding/chevel-rocket-topbar.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/branding/chevel-rocket-topbar.png)
set_source_files_properties(assets/ui/branding/chevel-rocket-wordmark.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/branding/chevel-rocket-wordmark.png)
set_source_files_properties(assets/ui/feeds/camera-feed.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/feeds/camera-feed.png)
set_source_files_properties(assets/ui/icons/actions.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/icons/actions.png)
set_source_files_properties(assets/ui/icons/mission.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/icons/mission.png)
set_source_files_properties(assets/ui/icons/nav.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/icons/nav.png)
set_source_files_properties(assets/ui/icons/status.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/icons/status.png)
set_source_files_properties(assets/ui/icons/telemetry.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/icons/telemetry.png)
set_source_files_properties(assets/ui/reference/chevel-rocket-reference.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/reference/chevel-rocket-reference.png)
set_source_files_properties(assets/ui/robots/dum-e-large.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/robots/dum-e-large.png)
set_source_files_properties(assets/ui/robots/dum-e-preview.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/robots/dum-e-preview.png)
set_source_files_properties(assets/ui/safety/emergency-stop-large.png PROPERTIES QT_RESOURCE_ALIAS assets/ui/safety/emergency-stop-large.png)

qt_add_executable(ChevelRobotControlCenter
    main.cpp
    src/RobotCommandInterface.h
    src/RobotCommandInterface.cpp
    src/RobotController.h
    src/RobotController.cpp
    src/TelemetryModel.h
    src/TelemetryModel.cpp
    src/VoiceSynthesisService.h
    src/VoiceSynthesisService.cpp
    src/VoiceTranscriptionService.h
    src/VoiceTranscriptionService.cpp
)

qt_add_qml_module(ChevelRobotControlCenter
    URI Chevel.Rocket
    VERSION 1.0
    RESOURCE_PREFIX /qt/qml
    QML_FILES ${QML_FILES}
    RESOURCES ${ASSET_FILES}
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
