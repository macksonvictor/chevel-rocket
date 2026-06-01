import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: root

    width: 1680
    height: 945
    minimumWidth: 1280
    minimumHeight: 720
    visible: true
    color: "#070B0F"
    title: "Chevel Rocket"

    property int currentTab: 0
    property string currentTimeText: Qt.formatTime(new Date(), "HH:mm:ss")
    property string currentDateText: Qt.formatDate(new Date(), "dd/MM/yyyy")
    property string pendingMethod: ""
    property string terminalCommand: ""
    property string voiceCommand: "start mission"
    property string detailTitle: ""
    property string detailBody: ""
    readonly property string cyan: "#22D3EE"
    readonly property string green: "#7CFF72"
    readonly property string amber: "#FFB020"
    readonly property string red: "#EF4444"
    readonly property string panelBorder: "#1F2A35"
    readonly property string muted: "#9AA3AF"
    readonly property string primaryText: "#E6EDF3"
    readonly property var navItems: [
        { title: "Mission Control", icon: "\u25ce", iconSource: "assets/ui/icons/single/mission.png", page: "HOME / OVERVIEW" },
        { title: "Robot Control", icon: "\u2699", iconSource: "assets/ui/icons/single/robot-control.png", page: "ROBOT CONTROL" },
        { title: "Computer Control", icon: "\u25ad", iconSource: "assets/ui/icons/single/computer.png", page: "COMPUTER CONTROL" },
        { title: "Safety", icon: "\u25c7", iconSource: "assets/ui/icons/single/safety.png", page: "SAFETY" },
        { title: "Voice", icon: "\u03bc", iconSource: "assets/ui/icons/single/voice.png", page: "VOICE" },
        { title: "Logs", icon: "\u2637", iconSource: "assets/ui/icons/single/logs.png", page: "LOGS" },
        { title: "UI Kit", icon: "\u25c8", iconSource: "assets/ui/icons/single/ui-kit.png", page: "UI KIT" }
    ]

    Component.onCompleted: {
        root.currentTab = 0
        root.raise()
        root.requestActivate()
        console.log("Chevel Rocket reference cockpit loaded")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            root.currentTimeText = Qt.formatTime(now, "HH:mm:ss")
            root.currentDateText = Qt.formatDate(now, "dd/MM/yyyy")
        }
    }

    function openCritical(name, message, methodName) {
        pendingMethod = methodName
        confirmModal.openFor(name, message, true)
    }

    function executePending() {
        if (pendingMethod === "armRobot")
            robotController.armRobot()
        else if (pendingMethod === "startMission")
            robotController.startMission()
        else if (pendingMethod === "rebootSystem")
            robotController.rebootSystem()
        else if (pendingMethod === "emergencyStop")
            robotController.emergencyStop()
        else if (pendingMethod === "returnHome")
            robotController.returnHome()
        else if (pendingMethod === "enableLive")
            robotController.setSimulationMode(false)
        else if (pendingMethod === "confirmAction")
            robotController.confirmAction()

        pendingMethod = ""
    }

    function requestSimulationMode(simulation) {
        if (simulation) {
            robotController.setSimulationMode(true)
            return
        }
        root.openCritical("LIVE MODE", "LIVE is prepared for a future hardware adapter. This build still keeps commands safe/simulated. Type CONFIRMAR to switch the cockpit indicator.", "enableLive")
    }

    function showDetails(title, body) {
        detailTitle = title
        detailBody = body
        detailPopup.open()
        robotController.addLog("INFO", "Details opened: " + title)
    }

    function recentLogsText(count) {
        var start = Math.max(0, robotController.logs.length - count)
        var text = ""
        for (var i = start; i < robotController.logs.length; ++i)
            text += robotController.logs[i] + (i < robotController.logs.length - 1 ? "\n" : "")
        return text.length > 0 ? text : "Sem logs recentes."
    }

    function openVoiceDiagnostics() {
        robotController.runVoiceDiagnostics()
        diagnosticsLoader.active = true
        diagnosticsLoader.item.open()
    }

    function openTopRightMenu() {
        topRightMenuLoader.active = true
        topRightMenuLoader.item.open()
    }

    function toggleFullscreen() {
        root.visibility = root.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen
    }

    function parseLogTime(line) {
        var match = String(line).match(/^\\[(.*?)\\]/)
        return match ? match[1] : root.currentTimeText
    }

    function parseLogLevel(line) {
        var match = String(line).match(/\\]\\s*([^:]+):/)
        return match ? match[1].trim() : "INFO"
    }

    function parseLogMessage(line) {
        return String(line).replace(/^\\[[^\\]]+\\]\\s*[^:]+:\\s*/, "")
    }

    function runTerminalInput() {
        var command = terminalCommand.trim()
        if (command.length === 0)
            return
        robotController.runTerminalCommand(command)
        terminalCommand = ""
    }

    function pageIndex() {
        return (currentTab + 1) + " / 8"
    }

    function pageName() {
        return navItems[currentTab].page
    }

    function fmt(value, digits, unit) {
        return Number(value).toLocaleString(Qt.locale(), "f", digits) + unit
    }

    function levelColor(level) {
        if (level === "ERROR")
            return red
        if (level === "WARNING" || level === "WARN")
            return amber
        return green
    }

    function voiceColor() {
        if (robotController.voiceStatus === "ONLINE")
            return green
        if (robotController.voiceStatus === "TESTING" || robotController.voiceStatus === "PARTIAL")
            return amber
        return red
    }

    background: Rectangle {
        anchors.fill: parent
        color: root.color

        Canvas {
            anchors.fill: parent
            opacity: 0.15

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#15202A"
                ctx.lineWidth = 1
                for (var x = 0; x < width; x += 32) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                for (var y = 0; y < height; y += 32) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RocketTopBar {
            timeText: root.currentTimeText
            dateText: root.currentDateText
            simulationMode: robotController.simulationMode
            safeMode: robotController.safeMode
            connectionState: robotController.connectionState
            emergencyActive: robotController.emergencyActive
            onSimulationModeRequested: root.requestSimulationMode(simulation)
            onSafeModeToggleRequested: robotController.toggleSafeMode()
            onMenuRequested: root.openTopRightMenu()
            Layout.fillWidth: true
            Layout.preferredHeight: 104
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 258
                Layout.fillHeight: true
                radius: 8
                color: "#091016"
                border.width: 1
                border.color: root.panelBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 0

                    Repeater {
                        model: root.navItems

                        RocketSidebarItem {
                            required property int index
                            required property var modelData

                            text: modelData.title
                            iconText: modelData.icon
                            iconSource: modelData.iconSource
                            current: root.currentTab === index
                            Layout.fillWidth: true
                            onClicked: root.currentTab = index
                        }
                    }

                    Item { Layout.fillHeight: true }

                    RocketButton {
                        text: "EMERGENCY STOP"
                        iconText: "!"
                        iconSource: "assets/ui/icons/single/emergency-stop.png"
                        variant: "emergency"
                        cornerRadius: 7
                        labelPixelSize: 18
                        locked: robotController.emergencyActive
                        Layout.fillWidth: true
                        Layout.preferredHeight: 84
                        onClicked: root.openCritical("EMERGENCY STOP",
                                                     "This engages the simulated emergency stop and blocks all mock commands. Type CONFIRMAR to continue.",
                                                     "emergencyStop")
                    }
                }
            }

            StackLayout {
                currentIndex: root.currentTab
                clip: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0

                MissionPage {}
                RobotPage {}
                ComputerPage {}
                SafetyPage {}
                VoicePage {}
                LogsPage {}
                UiKitPage {}
            }
        }

        RocketFooter {
            pageIndex: root.pageIndex()
            pageName: root.pageName()
            batteryLevel: robotController.batteryLevel
            communication: robotController.signalStrength > 55 ? "ESTAVEL" : "WARNING"
            voice: robotController.voiceStatus
            Layout.fillWidth: true
            Layout.preferredHeight: 70
        }
    }

    ConfirmModal {
        id: confirmModal
        onConfirmed: root.executePending()
    }

    Loader {
        id: topRightMenuLoader
        active: false
        sourceComponent: Component {
            TopRightMenu {
                x: root.width - width - 24
                y: 86
                onOverviewRequested: root.currentTab = 0
                onVoiceDiagnosticsRequested: root.openVoiceDiagnostics()
                onSettingsRequested: root.showDetails("Chevel Rocket Settings",
                                                      "Modo: " + (robotController.simulationMode ? "SIMULATION" : "LIVE") +
                                                      "\nSafe mode: " + (robotController.safeMode ? "ATIVO" : "DESLIGADO") +
                                                      "\nWhisper: " + robotController.whisperPath +
                                                      "\nPiper: " + robotController.piperPath +
                                                      "\nModelo Piper: " + robotController.piperModelPath +
                                                      "\nSaida de voz: " + robotController.voiceOutputDir +
                                                      "\n\nPara trocar caminhos, use variaveis de ambiente: CHEVEL_WHISPER_EXE, CHEVEL_FFMPEG_EXE, CHEVEL_PIPER_EXE, CHEVEL_PIPER_MODEL, CHEVEL_VOICE_OUTPUT_DIR e CHEVEL_AI_MODELS_DIR.")
                onLogsRequested: root.currentTab = 5
                onAboutRequested: root.showDetails("About Chevel Rocket",
                                                   "CHEVEL ROCKET\nMission & Robot Control\n\nPainel nativo Qt/QML em modo simulacao, com controle visual do DUM-E, logs, terminal, seguranca e diagnostico de voz/IA local.\n\nIA local: " + robotController.aiModelName + "\nPipeline: " + robotController.voicePipeline)
                onFullscreenRequested: root.toggleFullscreen()
                onReloadDiagnosticsRequested: root.openVoiceDiagnostics()
                onExitRequested: Qt.quit()
            }
        }
    }

    Loader {
        id: diagnosticsLoader
        active: false
        sourceComponent: Component {
            DiagnosticsModal {
                controller: robotController
            }
        }
    }

    Popup {
        id: detailPopup
        width: Math.min(620, root.width * 0.46)
        height: Math.min(420, root.height * 0.52)
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        modal: true
        dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 8
            color: "#091017"
            border.width: 1
            border.color: root.cyan
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.detailTitle
                    color: root.primaryText
                    font.pixelSize: 24
                    font.bold: true
                    Layout.fillWidth: true
                }
                RocketIconButton {
                    iconText: "X"
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 34
                    onClicked: detailPopup.close()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#22313D"
            }

            Text {
                text: root.detailBody
                color: "#D0D7DE"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            RocketButton {
                text: "CLOSE DETAILS"
                iconText: "\u2713"
                variant: "outlined"
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 170
                Layout.preferredHeight: 40
                onClicked: detailPopup.close()
            }
        }
    }

    component PageTitle: ColumnLayout {
        property string title: ""
        property string subtitle: ""

        spacing: 4
        Layout.fillWidth: true

        Text {
            text: title
            color: root.primaryText
            font.pixelSize: 26
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: subtitle
            color: root.muted
            font.pixelSize: 12
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    component StatusChip: Rectangle {
        property string label: "ONLINE"
        property string tone: "green"
        property string iconText: ""

        implicitHeight: 30
        implicitWidth: 112
        radius: 5
        color: tone === "red" ? "#261114" : tone === "amber" ? "#21190A" : tone === "cyan" ? "#0B1E26" : "#111D14"
        border.width: 1
        border.color: tone === "red" ? root.red : tone === "amber" ? root.amber : tone === "cyan" ? root.cyan : root.green

        RowLayout {
            anchors.centerIn: parent
            spacing: 7

            Text {
                visible: iconText.length > 0
                text: iconText
                color: parent.parent.border.color
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: label
                color: parent.parent.border.color
                font.pixelSize: 12
                font.bold: true
            }
        }
    }

    component MiniLine: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: "#25313C"
        opacity: 0.58
    }

    component PageShell: Rectangle {
        default property alias contentData: body.data

        implicitWidth: 0
        implicitHeight: 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: 0
        Layout.minimumHeight: 0
        radius: 8
        color: "#081016"
        border.width: 1
        border.color: root.panelBorder
        clip: true

        ColumnLayout {
            id: body
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
        }
    }

    component Waveform: Rectangle {
        property int bars: 58
        property color accent: root.cyan

        radius: 5
        color: "#091017"
        border.width: 1
        border.color: "#16222B"

        Row {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 3

            Repeater {
                model: bars

                Rectangle {
                    width: Math.max(2, (parent.width - (bars - 1) * 3) / bars)
                    height: 8 + Math.abs(Math.sin(index * 0.72)) * (parent.height - 24)
                    anchors.verticalCenter: parent.verticalCenter
                    radius: width / 2
                    color: accent
                    opacity: index % 7 === 0 ? 1 : 0.7
                }
            }
        }
    }

    component MissionPage: PageShell {
        PageTitle {
            title: "Visão Geral do Sistema"
            subtitle: "Resumo rápido do status de todos os módulos do Chevel Rocket."
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.fillHeight: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 342
                    spacing: 12

                    RocketPanel {
                        title: "MISSÃO ATUAL"
                        iconText: "\u25ce"
                        iconSource: "assets/ui/icons/single/mission.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text { text: "Exploração de Área Alfa"; color: root.primaryText; font.pixelSize: 20; Layout.fillWidth: true }
                        Text { text: "ID: MISSION-2025-05-28-001"; color: root.muted; font.pixelSize: 12 }
                        RocketMetricRow { label: "Tempo Decorrido"; value: robotController.missionElapsedText; iconText: "\u25f4"; iconSource: "assets/ui/icons/single/time.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Distância Percorrida"; value: fmt(robotController.missionDistance, 2, " km"); iconText: "\u25ce"; iconSource: "assets/ui/icons/single/location.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Objetivos Concluídos"; value: robotController.completedObjectives + " / " + robotController.totalObjectives; iconText: "\u2611"; iconSource: "assets/ui/icons/single/confirm.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Progresso Geral"; value: Math.round(robotController.missionProgress) + "%"; iconText: "\u2637"; iconSource: "assets/ui/icons/single/logs.png"; Layout.fillWidth: true }
                        RocketProgressBar { value: robotController.missionProgress; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 8 }
                        RowLayout {
                            Layout.fillWidth: true
                            StatusChip { label: robotController.missionStatus; tone: robotController.emergencyActive ? "red" : robotController.missionStatus === "PAUSADA" ? "amber" : "cyan"; Layout.preferredWidth: 142 }
                            RocketButton { text: "VER DETALHES"; iconSource: "assets/ui/icons/single/details.png"; variant: "outlined"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 34; onClicked: root.showDetails("Missao Atual", "ID: MISSION-2025-05-28-001\nStatus: " + robotController.missionStatus + "\nTempo decorrido: " + robotController.missionElapsedText + "\nDistancia: " + fmt(robotController.missionDistance, 2, " km") + "\nObjetivos: " + robotController.completedObjectives + " / " + robotController.totalObjectives + "\nProgresso: " + Math.round(robotController.missionProgress) + "%\nEstado do robo: " + robotController.robotState + "\n\nLogs relacionados:\n" + root.recentLogsText(7)) }
                        }
                    }

                    RocketPanel {
                        title: "ROBOT STATUS"
                        iconText: "\u2699"
                        iconSource: "assets/ui/icons/single/robot-control.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Image {
                                source: "assets/ui/robots/dum-e-preview.png"
                                Layout.preferredWidth: 136
                                Layout.preferredHeight: 108
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                Text { text: "DUM-E"; color: root.primaryText; font.pixelSize: 16; font.bold: true }
                                Text { text: "Modelo IA"; color: root.muted; font.pixelSize: 12 }
                                Text { text: robotController.aiModelName; color: root.cyan; font.pixelSize: 14 }
                                StatusChip { label: "ONLINE"; tone: "green"; Layout.preferredWidth: 90 }
                            }
                        }

                        RocketMetricRow { label: "Bateria"; value: Math.round(robotController.batteryLevel) + "%"; iconText: "\u25af"; iconSource: "assets/ui/icons/single/battery.png"; valueColor: root.primaryText; Layout.fillWidth: true }
                        RocketMetricRow { label: "Sensores"; value: "OK"; iconText: "\u273a"; iconSource: "assets/ui/icons/single/sensors.png"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Comunicação"; value: "ESTÁVEL"; iconText: "\u224b"; iconSource: "assets/ui/icons/single/communication.png"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Localização"; value: "Exploração de Área Alfa"; iconText: "\u25c9"; iconSource: "assets/ui/icons/single/location.png"; Layout.fillWidth: true }
                        RocketButton { text: "VER DETALHES"; iconSource: "assets/ui/icons/single/details.png"; variant: "outlined"; labelPixelSize: 12; Layout.preferredWidth: 148; Layout.preferredHeight: 34; onClicked: root.showDetails("DUM-E Robot Status", "Estado: " + robotController.robotState + "\nConexao: " + robotController.connectionState + "\nBateria: " + Math.round(robotController.batteryLevel) + "%\nSinal: " + Math.round(robotController.signalStrength) + "%\nTemperatura: " + fmt(robotController.motorTemperature, 1, " °C") + "\nVelocidade: " + fmt(robotController.speed, 2, " m/s") + "\nModo seguro: " + (robotController.safeMode ? "ATIVO" : "DESLIGADO") + "\n\nLogs recentes:\n" + root.recentLogsText(5)) }
                    }

                    RocketPanel {
                        title: "COMPUTER CONTROL"
                        iconText: "\u25ad"
                        iconSource: "assets/ui/icons/single/computer.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RocketMetricRow { label: "Modelo IA"; value: robotController.aiModelName; iconText: "\u273a"; iconSource: "assets/ui/icons/single/brain.png"; valueColor: root.cyan; Layout.fillWidth: true }
                        RocketMetricRow { label: "Processamento"; value: "NORMAL"; iconText: "\u273a"; iconSource: "assets/ui/icons/single/cpu.png"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Voz IA"; value: robotController.sttEngineName + " + " + robotController.ttsEngineName; iconText: "\u03bc"; iconSource: "assets/ui/icons/single/voice.png"; valueColor: root.cyan; Layout.fillWidth: true }
                        RocketMetricRow { label: "Temperatura"; value: fmt(robotController.motorTemperature, 0, " °C"); iconText: "\u2668"; iconSource: "assets/ui/icons/single/temperature.png"; valueColor: robotController.motorTemperature > 70 ? root.amber : root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Memória"; value: Math.round(robotController.memoryUsage) + "%"; iconText: "\u25c9"; iconSource: "assets/ui/icons/single/memory.png"; Layout.fillWidth: true }
                        RocketProgressBar { value: robotController.memoryUsage; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 7 }
                        RocketMetricRow { label: "Armazenamento"; value: Math.round(robotController.storageUsage) + "%"; iconText: "\u25ce"; iconSource: "assets/ui/icons/single/database.png"; Layout.fillWidth: true }
                        RocketProgressBar { value: robotController.storageUsage; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 7 }
                        RowLayout {
                            Layout.fillWidth: true
                            StatusChip { label: "ONLINE"; tone: "green"; Layout.preferredWidth: 100 }
                            RocketButton { text: "VER TERMINAL"; iconText: ">_"; iconSource: "assets/ui/icons/single/terminal.png"; variant: "outlined"; labelPixelSize: 12; Layout.fillWidth: true; Layout.preferredHeight: 36; onClicked: { robotController.runTerminalCommand("status"); root.currentTab = 2 } }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    RocketPanel {
                        title: "SAFETY STATUS"
                        iconText: "\u25c7"
                        iconSource: "assets/ui/icons/single/shield.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Modo Seguro"; value: robotController.safeMode ? "ATIVO" : "DESLIGADO"; valueColor: robotController.safeMode ? root.green : root.amber; iconText: "\u2699"; iconSource: "assets/ui/icons/single/safety.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "E-Stop"; value: robotController.emergencyActive ? "ATIVO" : "NORMAL"; valueColor: robotController.emergencyActive ? root.red : root.green; iconText: "\u26a0"; iconSource: "assets/ui/icons/single/emergency-stop.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Cercas Virtuais"; value: robotController.virtualFencesActive ? "ATIVAS" : "DESLIGADAS"; valueColor: robotController.virtualFencesActive ? root.green : root.amber; iconText: "\u25a3"; iconSource: "assets/ui/icons/single/ui-kit.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Integridade do Sistema"; value: "OK"; valueColor: root.green; iconText: "\u273a"; iconSource: "assets/ui/icons/single/confirm.png"; Layout.fillWidth: true }
                        RowLayout {
                            Layout.fillWidth: true
                            StatusChip { label: "READY"; tone: "green"; Layout.preferredWidth: 96 }
                            RocketButton { text: "VER DETALHES"; iconSource: "assets/ui/icons/single/details.png"; variant: "outlined"; labelPixelSize: 12; Layout.fillWidth: true; Layout.preferredHeight: 34; onClicked: root.showDetails("Safety Status", "Modo seguro: " + (robotController.safeMode ? "ATIVO" : "DESLIGADO") + "\nE-Stop: " + (robotController.emergencyActive ? "ATIVO" : "NORMAL") + "\nCercas virtuais: " + (robotController.virtualFencesActive ? "ATIVAS" : "DESLIGADAS") + "\nIntegridade: OK\nRisco da missao: " + Math.round(robotController.missionRisk) + "%\n\nUltimos eventos de seguranca:\n" + root.recentLogsText(6)) }
                        }
                    }

                    RocketPanel {
                        title: "VOICE STATUS"
                        iconText: "\u03bc"
                        iconSource: "assets/ui/icons/single/voice.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Microfone"; value: robotController.voiceStatus; valueColor: root.voiceColor(); iconText: "\u03bc"; iconSource: "assets/ui/icons/single/voice.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Reconhecimento"; value: robotController.whisperStatus; valueColor: robotController.whisperStatus === "READY" ? root.green : root.red; iconText: "\u273a"; iconSource: "assets/ui/icons/single/wave.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "IA de Voz"; value: "ONLINE"; valueColor: root.green; iconText: "\u25a3"; iconSource: "assets/ui/icons/single/brain.png"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Último Comando"; value: robotController.lastVoiceCommand; iconText: "\u25ce"; iconSource: "assets/ui/icons/single/time.png"; Layout.fillWidth: true }
                        RowLayout {
                            Layout.fillWidth: true
                            StatusChip { label: "READY"; tone: "green"; Layout.preferredWidth: 96 }
                            RocketButton { text: "TESTAR VOZ"; iconText: "\u266b"; iconSource: "assets/ui/icons/single/active-voice.png"; variant: "outlined"; labelPixelSize: 12; Layout.fillWidth: true; Layout.preferredHeight: 34; onClicked: { robotController.testVoice(); root.openVoiceDiagnostics() } }
                        }
                    }

                    RocketPanel {
                        title: "ACESSO RÁPIDO"
                        iconText: "\u26a1"
                        iconSource: "assets/ui/icons/single/live.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 10

                            RocketButton { text: "START MISSION"; iconText: "\u25b6"; iconSource: "assets/ui/icons/single/start.png"; variant: "secondary"; labelPixelSize: 11; locked: robotController.emergencyActive; Layout.fillWidth: true; Layout.preferredHeight: 50; onClicked: root.openCritical("START MISSION", "This starts a simulated mission profile only. Type CONFIRMAR to continue.", "startMission") }
                            RocketButton { text: "PAUSE MISSION"; iconText: "||"; iconSource: "assets/ui/icons/single/pause.png"; variant: "secondary"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 50; onClicked: robotController.pauseMission() }
                            RocketButton { text: "RETURN HOME"; iconText: "\u2302"; iconSource: "assets/ui/icons/single/home.png"; variant: "secondary"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 50; onClicked: root.openCritical("RETURN HOME", "Return Home move o DUM-E para a base em modo simulado e registra o comando. Type CONFIRMAR to continue.", "returnHome") }
                            RocketButton { text: "CONFIRM"; iconText: "\u2713"; iconSource: "assets/ui/icons/single/confirm.png"; variant: "confirm"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 50; onClicked: root.openCritical("MISSION CONFIRM", "Confirm the queued simulated mission step. Type CONFIRMAR to continue.", "confirmAction") }
                        }

                        RocketButton { text: "CANCEL"; iconText: "\u00d7"; iconSource: "assets/ui/icons/single/cancel.png"; variant: "cancel"; Layout.fillWidth: true; Layout.preferredHeight: 42; onClicked: robotController.cancelAction() }
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 330
                Layout.minimumWidth: 330
                Layout.maximumWidth: 330
                Layout.fillHeight: true
                spacing: 12

                RocketPanel {
                    title: "PREVIEW DO ROBOT"
                    iconSource: "assets/ui/icons/single/robot-control.png"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 304
                    Image { source: "assets/ui/robots/dum-e-preview.png"; Layout.fillWidth: true; Layout.preferredHeight: 145; fillMode: Image.PreserveAspectCrop; smooth: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "DUM-E"; color: root.primaryText; font.pixelSize: 16; font.bold: true; Layout.fillWidth: true }
                        StatusChip { label: "ONLINE"; tone: "green"; Layout.preferredWidth: 90 }
                    }
                    RocketButton { text: "ABRIR CONTROLE"; iconText: "\u2699"; iconSource: "assets/ui/icons/single/robot-control.png"; variant: "primary"; Layout.fillWidth: true; Layout.preferredHeight: 48; onClicked: root.currentTab = 1 }
                }

                RocketPanel {
                    title: "LOGS RECENTES"
                    iconSource: "assets/ui/icons/single/logs.png"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Repeater {
                        model: robotController.logs.length > 7 ? robotController.logs.slice(robotController.logs.length - 7) : robotController.logs

                        RowLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 8

                            Text { text: root.parseLogTime(modelData); color: root.muted; font.pixelSize: 11; Layout.preferredWidth: 58 }
                            StatusChip { label: root.parseLogLevel(modelData); tone: root.parseLogLevel(modelData) === "CRITICAL" || root.parseLogLevel(modelData) === "ERROR" ? "red" : root.parseLogLevel(modelData) === "WARNING" ? "amber" : "green"; Layout.preferredWidth: 70; implicitHeight: 22 }
                            Text { text: root.parseLogMessage(modelData); color: "#BFC7D0"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                    }

                    RocketButton { text: "VER TODOS OS LOGS"; iconText: "\u2637"; iconSource: "assets/ui/icons/single/logs.png"; variant: "outlined"; labelPixelSize: 12; Layout.fillWidth: true; Layout.preferredHeight: 38; onClicked: root.currentTab = 5 }
                }
            }
        }
    }

    component RobotPage: PageShell {
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 560
                Layout.fillHeight: true
                spacing: 10

                RocketPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 470

                    PageTitle {
                        title: "Robot Control"
                        subtitle: "Monitor and operate the DUM-E robotic manipulator and mobile base."
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        StatusChip { label: robotController.emergencyActive ? "EMERGENCY" : "ONLINE"; tone: robotController.emergencyActive ? "red" : "green"; iconText: "\u2022"; Layout.preferredWidth: 118 }
                        StatusChip { label: robotController.robotState; tone: robotController.robotState === "MOVING" ? "cyan" : robotController.robotState === "EMERGENCY" ? "red" : "amber"; iconText: "\u26a0"; Layout.preferredWidth: 118 }
                        StatusChip { label: robotController.armed ? "ARMED" : "READY"; tone: robotController.armed ? "green" : "amber"; iconText: "\u2713"; Layout.preferredWidth: 94 }
                        Item { Layout.fillWidth: true }
                    }

                    Image {
                        source: "assets/ui/robots/dum-e-large.png"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 162
                    spacing: 10

                    RocketPanel {
                        title: "BASE MOBILITY"
                        iconText: "\u2699"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Drive Mode"; value: "OMNI"; valueColor: root.cyan; Layout.fillWidth: true }
                        RocketMetricRow { label: "Speed"; value: fmt(robotController.speed, 2, " m/s"); Layout.fillWidth: true }
                        RocketMetricRow { label: "Orientation"; value: fmt(robotController.telemetry.yaw, 1, " °"); Layout.fillWidth: true }
                        RocketMetricRow { label: "Wheel Status"; value: "OK"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Stability"; value: "OK"; valueColor: root.green; Layout.fillWidth: true }
                    }

                    RocketPanel {
                        title: "CALIBRATION"
                        iconText: "\u25ce"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Last Calibration"; value: root.currentDateText + " " + root.currentTimeText; Layout.fillWidth: true }
                        RocketMetricRow { label: "Calibration Status"; value: "OK"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "IMU Calibration"; value: "OK"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Kinematics"; value: "0.12 °"; Layout.fillWidth: true }
                        RocketButton { text: "CALIBRATION WIZARD"; iconText: "\u25a3"; variant: "outlined"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 34; onClicked: robotController.calibrateSensors() }
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: Math.min(620, root.width * 0.36)
                Layout.minimumWidth: 540
                Layout.maximumWidth: 620
                Layout.fillHeight: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 205
                    spacing: 10

                    RocketPanel {
                        title: "ARM STATUS"
                        iconText: "\u2699"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Manipulator"; value: robotController.armed ? "ARMED" : "IDLE"; valueColor: robotController.armed ? root.green : root.amber; Layout.fillWidth: true }
                        RocketMetricRow { label: "Power Rail"; value: fmt(robotController.telemetry.voltage, 1, " V"); Layout.fillWidth: true }
                        RocketProgressBar { value: 42; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 7 }
                        RocketMetricRow { label: "Current Draw"; value: fmt(robotController.telemetry.current, 2, " A"); Layout.fillWidth: true }
                        RocketMetricRow { label: "Temperature"; value: fmt(robotController.motorTemperature, 1, " °C"); Layout.fillWidth: true }
                        RocketProgressBar { value: robotController.motorTemperature; maximum: 100; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 7 }
                        RocketMetricRow { label: "Control Loop"; value: "ACTIVE"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Status"; value: "\u2713 READY"; valueColor: root.green; Layout.fillWidth: true }
                    }

                    RocketPanel {
                        title: "JOINT POSITIONS"
                        iconText: "\u273a"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Repeater {
                            model: [
                                ["J1 Base", 56, "-24.6 °"],
                                ["J2 Shoulder", 62, "31.2 °"],
                                ["J3 Elbow", 46, "18.7 °"],
                                ["J4 Wrist Pitch", 38, "-12.3 °"],
                                ["J5 Wrist Roll", 60, "45.9 °"],
                                ["J6 Gripper", 72, "72 %"]
                            ]
                            RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Text { text: modelData[0]; color: "#B8C0CA"; font.pixelSize: 12; Layout.preferredWidth: 106 }
                                RocketProgressBar { value: modelData[1]; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 5 }
                                Text { text: modelData[2]; color: "#B8C0CA"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 62 }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 194
                    spacing: 10

                    RocketPanel {
                        title: "SENSOR HEALTH"
                        iconText: "\u25c7"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Repeater {
                            model: [["IMU", "OK"], ["Joint Encoders", "OK"], ["Motor Drivers", "OK"], ["Current Sensors", "OK"], ["Limit Switches", "WARNING"], ["Temperature Sensors", "OK"], ["Voltage Monitor", "OK"]]
                            RocketMetricRow {
                                required property var modelData
                                label: modelData[0]
                                value: modelData[1]
                                valueColor: modelData[1] === "WARNING" ? root.amber : root.green
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RocketPanel {
                        title: "BATTERY"
                        iconText: "\u25af"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Battery Level"; value: Math.round(robotController.batteryLevel) + "%"; Layout.fillWidth: true }
                        RocketProgressBar { value: robotController.batteryLevel; accent: root.green; Layout.fillWidth: true; Layout.preferredHeight: 7 }
                        RocketMetricRow { label: "Voltage"; value: fmt(robotController.telemetry.voltage, 2, " V"); Layout.fillWidth: true }
                        RocketMetricRow { label: "Current"; value: fmt(robotController.telemetry.current, 2, " A"); Layout.fillWidth: true }
                        RocketMetricRow { label: "Remaining"; value: "01:36:20"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Health"; value: "GOOD"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Status"; value: "CHARGING"; valueColor: root.green; Layout.fillWidth: true }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    spacing: 10

                    RocketPanel {
                        title: "COMMUNICATION"
                        iconText: "\u224b"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Link Status"; value: "ONLINE"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Protocol"; value: "UART"; valueColor: root.cyan; Layout.fillWidth: true }
                        RocketMetricRow { label: "Signal Quality"; value: Math.round(robotController.signalStrength) + "%"; Layout.fillWidth: true }
                        RocketProgressBar { value: robotController.signalStrength; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 6 }
                        RocketMetricRow { label: "Latency"; value: fmt(robotController.telemetry.latency, 0, " ms"); Layout.fillWidth: true }
                    }

                    RocketPanel {
                        title: "CAMERA FEED"
                        iconText: "\u25ce"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Image { source: "assets/ui/feeds/camera-feed.png"; Layout.fillWidth: true; Layout.preferredHeight: 96; fillMode: Image.PreserveAspectCrop; smooth: true }
                        RocketButton { text: "OPEN CAMERA VIEW"; iconText: "\u25ad"; variant: "outlined"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 34 }
                    }

                    RocketPanel {
                        title: "MANIPULATOR STATUS"
                        iconText: "\u26a1"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        RocketMetricRow { label: "Gripper"; value: "READY"; valueColor: root.cyan; Layout.fillWidth: true }
                        RocketMetricRow { label: "Grip Force"; value: "72%"; Layout.fillWidth: true }
                        RocketProgressBar { value: 72; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 6 }
                        RocketMetricRow { label: "Payload Est."; value: "0.25 kg"; Layout.fillWidth: true }
                        RocketMetricRow { label: "Motion Profile"; value: "NORMAL"; valueColor: root.green; Layout.fillWidth: true }
                        RocketMetricRow { label: "Safety Limits"; value: "OK"; valueColor: root.green; Layout.fillWidth: true }
                    }
                }

                RocketPanel {
                    title: "SYSTEM ACTIONS"
                    iconText: "\u26ed"
                    compact: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10
                        RocketButton { text: "ARM ROBOT"; iconText: "\u2699"; variant: "primary"; Layout.fillWidth: true; Layout.preferredHeight: 46; locked: robotController.emergencyActive || robotController.armed; onClicked: root.openCritical("ARM ROBOT", "Arm Dum-E inside simulation only. Type CONFIRMAR to continue.", "armRobot") }
                        RocketButton { text: "DISARM ROBOT"; iconText: "\u2699"; variant: "disabled"; Layout.fillWidth: true; Layout.preferredHeight: 46; locked: !robotController.armed; onClicked: robotController.disarmRobot() }
                        RocketButton { text: "CALIBRATE SENSORS"; iconText: "\u25ce"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 46; onClicked: robotController.calibrateSensors() }
                        RocketButton { text: "REBOOT SYSTEM"; iconText: "\u21bb"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 46; onClicked: root.openCritical("REBOOT SYSTEM", "This performs a simulated controller reboot. Type CONFIRMAR to continue.", "rebootSystem") }
                        RocketButton { text: "MOVER FRENTE"; iconText: "\u2191"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.moveRobot("forward") }
                        RocketButton { text: "MOVER TRAS"; iconText: "\u2193"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.moveRobot("backward") }
                        RocketButton { text: "ESQUERDA"; iconText: "\u2190"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.moveRobot("left") }
                        RocketButton { text: "DIREITA"; iconText: "\u2192"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.moveRobot("right") }
                        RocketButton { text: "PARAR"; iconText: "\u25a0"; variant: "warning"; Layout.fillWidth: true; Layout.preferredHeight: 42; onClicked: robotController.moveRobot("stop") }
                        RocketButton { text: "ABRIR GARRA"; iconText: "\u25c7"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.openGripper() }
                        RocketButton { text: "FECHAR GARRA"; iconText: "\u25c6"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.closeGripper() }
                        RocketButton { text: "SUBIR BRACO"; iconText: "\u21e7"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.moveRobot("arm up") }
                        RocketButton { text: "DESCER BRACO"; iconText: "\u21e9"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.moveRobot("arm down") }
                        RocketButton { text: "RESET POSICAO"; iconText: "\u2302"; variant: "ready"; Layout.fillWidth: true; Layout.preferredHeight: 42; locked: robotController.emergencyActive; onClicked: robotController.returnHome() }
                    }
                }
            }
        }
    }

    component ComputerPage: PageShell {
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            PageTitle {
                title: "Computer Control"
                subtitle: "Controle local do computador e automações seguras."
                Layout.fillWidth: true
            }

            RocketPanel {
                compact: true
                Layout.preferredWidth: 420
                Layout.preferredHeight: 64
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 22
                    RocketMetricRow { label: "Modelo de IA Local"; value: robotController.aiModelName; valueColor: root.cyan; Layout.fillWidth: true }
                    RocketMetricRow { label: "Segurança"; value: "ATIVA"; valueColor: root.green; Layout.fillWidth: true }
                    RocketButton { text: "REINICIAR IA"; iconText: "\u21bb"; variant: "outlined"; labelPixelSize: 11; Layout.preferredWidth: 132; Layout.preferredHeight: 34; onClicked: root.openCritical("REBOOT SYSTEM", "Restart the simulated local AI service. Type CONFIRMAR to continue.", "rebootSystem") }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 290
            spacing: 12

            RocketPanel {
                title: "TERMINAL SEGURO (LOCAL)"
                iconText: "\u25a3"
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 5
                    color: "#050A0E"
                    border.width: 1
                    border.color: "#1F2A35"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                text: robotController.terminalTranscript + "\n\u2588"
                                readOnly: true
                                wrapMode: TextArea.WrapAnywhere
                                color: "#53E86D"
                                selectedTextColor: "#050A0E"
                                selectionColor: root.cyan
                                font.pixelSize: 13
                                font.family: "Consolas"
                                background: Rectangle { color: "transparent" }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            TextField {
                                text: root.terminalCommand
                                onTextChanged: root.terminalCommand = text
                                placeholderText: "status, battery, sensors, start, pause, stop, home, clear"
                                placeholderTextColor: "#5E6B76"
                                color: root.primaryText
                                font.family: "Consolas"
                                Layout.fillWidth: true
                                background: Rectangle { radius: 4; color: "#0B1117"; border.width: 1; border.color: "#263441" }
                                onAccepted: root.runTerminalInput()
                            }
                            RocketButton {
                                text: "SEND"
                                iconText: ">_"
                                variant: "primary"
                                Layout.preferredWidth: 108
                                Layout.preferredHeight: 40
                                onClicked: root.runTerminalInput()
                            }
                        }
                    }
                }
            }

            RocketPanel {
                title: "INTERPRETAÇÃO DE COMANDO (IA LOCAL)"
                iconText: "\u273a"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text { text: "Comando recebido:\n" + (root.terminalCommand.length > 0 ? root.terminalCommand : "status"); color: "#D0D7DE"; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                MiniLine {}
                Text { text: "Interpretação (" + robotController.aiModelName + "):\nComando simulado seguro dentro do cockpit Rocket. Nenhum comando real do sistema operacional será enviado."; color: "#D0D7DE"; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: 4
                    color: "#0B1117"
                    border.width: 1
                    border.color: "#1F2A35"
                    Text { anchors.centerIn: parent; text: root.terminalCommand.length > 0 ? root.terminalCommand : "status"; color: root.primaryText; font.pixelSize: 13; font.family: "Consolas" }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Confiança:"; color: root.muted; font.pixelSize: 12 }
                    Text { text: "98%"; color: root.cyan; font.pixelSize: 12; font.bold: true }
                    RocketProgressBar { value: 98; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 6 }
                }
            }

            RocketPanel {
                title: "PERMISSÕES & RISCO"
                iconText: "\u25ce"
                Layout.preferredWidth: 240
                Layout.fillHeight: true
                RocketMetricRow { label: "Tipo de ação"; value: "Leitura"; Layout.fillWidth: true }
                RocketMetricRow { label: "Nivel de risco"; value: "BAIXO"; valueColor: root.green; Layout.fillWidth: true }
                RocketMetricRow { label: "Escopo"; value: "~/Documentos"; Layout.fillWidth: true }
                RocketMetricRow { label: "Requer permissão"; value: "NÃO"; valueColor: root.green; Layout.fillWidth: true }
                StatusChip { label: "PRONTO PARA EXECUÇÃO"; tone: "green"; Layout.fillWidth: true }
            }

            RocketPanel {
                title: "FILA DE EXECUÇÃO"
                Layout.preferredWidth: 308
                Layout.fillHeight: true
                Repeater {
                    model: [["1", "ls -lh ~/Documentos", "PRONTO"], ["2", "df -h", "AGUARDANDO"], ["3", "cat ~/Documents/relatorio.txt", "AGUARDANDO"], ["4", "whoami", "AGUARDANDO"], ["5", "uptime", "AGUARDANDO"]]
                    RocketMetricRow {
                        required property var modelData
                        label: modelData[0] + "   " + modelData[1]
                        value: modelData[2]
                        valueColor: modelData[2] === "PRONTO" ? root.green : root.muted
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    RocketIconButton { iconText: "\u2303"; Layout.preferredWidth: 48; Layout.preferredHeight: 28 }
                    RocketIconButton { iconText: "\u2304"; Layout.preferredWidth: 48; Layout.preferredHeight: 28 }
                    Item { Layout.fillWidth: true }
                }
                RocketButton { text: "EXECUTE COMMAND"; iconText: "\u25b7"; variant: "primary"; Layout.fillWidth: true; Layout.preferredHeight: 42; onClicked: root.runTerminalInput() }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            RocketPanel {
                title: "AUTOMAÇÕES LOCAIS (ARQUIVOS & PROGRAMAS)"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Repeater {
                    model: [["\u25a1", "Backup de Projetos", "Script: backup_projetos.sh\nFrequência: Diário - 02:00"], ["\u25b7", "Limpeza de Logs", "Script: clean_logs.sh\nFrequência: Semanal - Dom 03:00"], ["\u25a4", "Gerar Relatório", "Script: gerar_relatorio.py\nFrequência: Manual"]]
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 12
                        Text { text: modelData[0]; color: root.cyan; font.pixelSize: 34; Layout.preferredWidth: 48 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Text { text: modelData[1]; color: root.primaryText; font.pixelSize: 14; font.bold: true }
                            Text { text: modelData[2]; color: root.muted; font.pixelSize: 12; wrapMode: Text.WordWrap }
                        }
                        StatusChip { label: "READY"; tone: "green"; Layout.preferredWidth: 72 }
                        RocketIconButton { iconText: "\u22ef"; Layout.preferredWidth: 40; Layout.preferredHeight: 28 }
                    }
                }
                RocketButton { text: "+ NOVA AUTOMAÇÃO"; variant: "outlined"; labelPixelSize: 12; Layout.preferredWidth: 154; Layout.preferredHeight: 32 }
            }

            RocketPanel {
                title: "PRÉ-VISUALIZAÇÃO DE COMANDOS SEGUROS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Repeater {
                    model: [["ls -lh ~/Documentos", "Listar arquivos com tamanho legivel"], ["df -h", "Mostrar espaço em disco"], ["cat ~/Documents/relatorio.txt", "Exibir conteudo de um arquivo de texto"], ["whoami", "Mostrar usuario atual"], ["uptime", "Mostrar tempo de atividade do sistema"]]
                    RocketMetricRow {
                        required property var modelData
                        label: modelData[0] + "\n" + modelData[1]
                        value: "Risco: BAIXO"
                        valueColor: root.green
                        Layout.fillWidth: true
                        implicitHeight: 40
                    }
                }
                Text { text: "\u25c7 Apenas comandos seguros são sugeridos e executados."; color: root.muted; font.pixelSize: 12; Layout.fillWidth: true }
            }

            RocketPanel {
                title: "HISTÓRICO DE COMANDOS & LOGS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Repeater {
                    model: [["14:27:15", "INFO", "ls -lh ~/Documentos", "Sucesso"], ["14:25:08", "INFO", "df -h", "Sucesso"], ["14:23:42", "INFO", "cat ~/Documents/relatorio.txt", "Sucesso"], ["14:22:10", "INFO", "whoami", "Sucesso"], ["14:20:05", "INFO", "uptime", "Sucesso"], ["14:15:22", "WARN", "rm -rf /", "Bloqueado"]]
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8
                        Text { text: modelData[0]; color: root.muted; font.pixelSize: 11; Layout.preferredWidth: 58 }
                        StatusChip { label: modelData[1]; tone: modelData[1] === "WARN" ? "amber" : "green"; Layout.preferredWidth: 52; implicitHeight: 22 }
                        Text { text: modelData[2]; color: "#D0D7DE"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: modelData[3]; color: modelData[3] === "Bloqueado" ? root.amber : root.green; font.pixelSize: 11; Layout.preferredWidth: 70 }
                    }
                }
                RocketButton { text: "VER TODOS OS LOGS"; iconText: "\u2637"; variant: "outlined"; labelPixelSize: 12; Layout.preferredWidth: 260; Layout.preferredHeight: 36; onClicked: root.currentTab = 5 }
            }
        }

        RocketPanel {
            compact: true
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 24
                Item { Layout.fillWidth: true }
                RocketButton { text: "CONFIRM"; iconText: "\u2713"; variant: "confirm"; Layout.preferredWidth: 235; Layout.preferredHeight: 42; onClicked: root.openCritical("COMMAND CONFIRM", "Confirm mock command routing only. Type CONFIRMAR to continue.", "") }
                RocketButton { text: "CANCEL"; iconText: "\u00d7"; variant: "cancel"; Layout.preferredWidth: 220; Layout.preferredHeight: 42 }
                RocketButton { text: "WARNING"; iconText: "!"; variant: "warning"; Layout.preferredWidth: 220; Layout.preferredHeight: 42 }
                Item { Layout.fillWidth: true }
            }
        }
    }

    component SafetyPage: PageShell {
        PageTitle {
            title: "Safety Console"
            subtitle: "Protect people, equipment and mission. Review status, follow checklist and confirm before critical actions."
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ColumnLayout {
                Layout.preferredWidth: 590
                Layout.fillHeight: true
                spacing: 12

                RocketPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text { text: "EMERGENCY STOP"; color: root.red; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    Image { source: "assets/ui/safety/emergency-stop-large.png"; Layout.fillWidth: true; Layout.fillHeight: true; fillMode: Image.PreserveAspectFit; smooth: true }
                    Text { text: "PRESS TO STOP ALL SYSTEMS"; color: root.red; font.pixelSize: 17; font.bold: true; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    Text { text: "Immediately halts all robot motion, actuators, and mission processes."; color: root.muted; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    RocketButton { text: "CRITICAL ACTION"; iconText: "!"; variant: "emergency"; Layout.fillWidth: true; Layout.preferredHeight: 58; onClicked: root.openCritical("EMERGENCY STOP", "This engages the simulated emergency stop and blocks all mock commands. Type CONFIRMAR to continue.", "emergencyStop") }
                    RocketButton { text: "RESET EMERGENCY"; iconText: "\u21bb"; variant: "warning"; Layout.fillWidth: true; Layout.preferredHeight: 44; locked: !robotController.emergencyActive; onClicked: robotController.clearEmergency() }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 172
                    spacing: 12
                    RocketPanel {
                        title: "WARNING ZONES"
                        iconText: "\u26a0"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Repeater {
                            model: [["Zone 1 - Robot Work Envelope", "ACTIVE", root.red], ["Zone 2 - Peripheral Area", "CAUTION", root.amber], ["Zone 3 - Operator Area", "SAFE", root.green], ["Zone 4 - Maintenance Area", "SAFE", root.green]]
                            RocketMetricRow { required property var modelData; label: modelData[0]; value: modelData[1]; valueColor: modelData[2]; Layout.fillWidth: true }
                        }
                        RocketButton { text: robotController.virtualFencesActive ? "DESATIVAR CERCAS" : "ATIVAR CERCAS"; iconText: "\u25a3"; variant: robotController.virtualFencesActive ? "warning" : "ready"; Layout.fillWidth: true; Layout.preferredHeight: 32; onClicked: robotController.toggleVirtualFences() }
                    }
                    RocketPanel {
                        title: "INTEGRITY STATUS"
                        iconText: "\u25c7"
                        compact: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Repeater {
                            model: ["Safety PLC", "Safety I/O Modules", "E-Stop Buttons", "Light Curtains", "Safety Relays", "System Redundancy"]
                            RocketMetricRow { required property string modelData; label: modelData; value: "OK"; valueColor: root.green; Layout.fillWidth: true }
                        }
                        RocketButton { text: "VIEW INTEGRITY REPORT"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 32 }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 258
                    spacing: 12
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12
                        RocketPanel {
                            title: "SAFETY MODE"
                            iconText: "\u25c7"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Systems are limited to safe operation parameters."; color: root.muted; font.pixelSize: 12; Layout.fillWidth: true }
                                StatusChip { label: robotController.safeMode ? "SAFE MODE" : "MANUAL"; tone: robotController.safeMode ? "green" : "amber"; Layout.preferredWidth: 150 }
                            }
                            RocketButton { text: robotController.safeMode ? "DESATIVAR SAFE MODE" : "ATIVAR SAFE MODE"; iconText: "\u25c7"; variant: robotController.safeMode ? "warning" : "ready"; Layout.fillWidth: true; Layout.preferredHeight: 36; onClicked: robotController.toggleSafeMode() }
                        }
                        RocketPanel {
                            title: "HUMAN CONFIRMATION"
                            iconText: "\u263a"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Text { text: "Type CONFIRM to authorize safety-critical actions."; color: root.muted; font.pixelSize: 12; Layout.fillWidth: true }
                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "Type CONFIRM here"
                                color: root.primaryText
                                placeholderTextColor: "#68727E"
                                background: Rectangle { radius: 4; color: "#0B1117"; border.width: 1; border.color: "#273441" }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; radius: 3; color: "#0B1117"; border.width: 1; border.color: "#61707D" }
                                Text { text: "I understand the consequences of this action."; color: root.muted; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 12
                        RocketPanel {
                            title: "SAFETY STATUS"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Repeater {
                                model: ["Overall Safety", "E-Stop Circuit", "Guarding & Enclosures", "Power Isolation", "Brakes & Actuators", "Communication Links", "Watchdog Timers"]
                                RocketMetricRow { required property string modelData; label: modelData; value: modelData === "Overall Safety" ? "READY" : "OK"; valueColor: root.green; Layout.fillWidth: true }
                            }
                            RocketButton { text: "VIEW DETAILS"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 34 }
                        }
                        RocketPanel {
                            title: "SAFETY CONNECTIVITY"
                            iconText: "\u224b"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Repeater {
                                model: [["Safety Controller", "ONLINE"], ["E-Stop Network", "ONLINE"], ["IO Safety Network", "ONLINE"], ["Robot Controller", "OFFLINE"], ["Drive Safety", "ONLINE"]]
                                RocketMetricRow { required property var modelData; label: modelData[0]; value: modelData[1]; valueColor: modelData[1] === "OFFLINE" ? root.red : root.green; Layout.fillWidth: true }
                            }
                            RocketButton { text: "GO OFFLINE (MAINTENANCE)"; iconText: "\u25cc"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 34; onClicked: root.showDetails("Maintenance Mode", "Offline maintenance is a simulated placeholder. Real hardware isolation will be connected later.") }
                        }
                    }
                }

                RocketPanel {
                    title: "CRITICAL ACTION CHECKLIST"
                    iconText: "\u25a3"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: ["Area is clear of people and obstacles", "Robot is in a safe and stable state", "All tools and payloads are secured", "Power and pneumatic systems verified", "I have reviewed the mission and risks", "I accept full responsibility for this action"]
                        RowLayout {
                            required property string modelData
                            Layout.fillWidth: true
                            Rectangle { Layout.preferredWidth: 16; Layout.preferredHeight: 16; radius: 3; color: "#0B1117"; border.width: 1; border.color: "#6D7A86" }
                            Text { text: modelData; color: "#B8C0CA"; font.pixelSize: 12; Layout.fillWidth: true }
                        }
                    }
                }

                RocketPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 154
                    border.color: root.red
                    Text { text: "CONFIRM SAFETY ACTION"; color: root.red; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    Text { text: "Review all status indicators and checklist. Confirm to proceed."; color: root.muted; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    RowLayout {
                        Layout.fillWidth: true
                        RocketButton { text: "CANCEL"; iconText: "\u00d7"; variant: "cancel"; Layout.fillWidth: true; Layout.preferredHeight: 58; onClicked: robotController.cancelAction() }
                        RocketButton { text: "CONFIRM"; iconText: "\u2713"; variant: "emergency"; Layout.fillWidth: true; Layout.preferredHeight: 58; onClicked: root.openCritical("SAFETY CONFIRM", "Confirm safe-mode simulation only. Type CONFIRMAR to continue.", "") }
                    }
                }
            }
        }
    }

    component VoicePage: PageShell {
        PageTitle {
            title: "Voice"
            subtitle: "Controle por voz e sistema de IA local."
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                RocketPanel {
                    title: "ESCUTA ATIVA"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 190
                        Layout.preferredHeight: 190
                        radius: 95
                        color: "#0B2028"
                        border.width: 2
                        border.color: root.cyan
                        Text { anchors.centerIn: parent; text: "\u03bc"; color: root.cyan; font.pixelSize: 72 }
                    }
                    Text { text: robotController.voiceStatus === "TESTING" ? "Testando..." : "Ouvindo..."; color: root.primaryText; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    Text { text: "Diga a palavra de ativação para começar."; color: root.muted; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                    RocketPanel {
                        compact: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        RowLayout {
                            Layout.fillWidth: true
                            ColumnLayout {
                                Layout.fillWidth: true
                                Text { text: "PALAVRA DE ATIVAÇÃO"; color: root.muted; font.pixelSize: 12 }
                                StatusChip { label: "Chevel"; tone: "cyan"; Layout.preferredWidth: 110 }
                            }
                            StatusChip { label: "ATIVO"; tone: "green"; Layout.preferredWidth: 80 }
                        }
                    }
                }

                RocketPanel {
                    title: "STATUS DE VOZ"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 158
                    RocketMetricRow { label: "STT (Fala -> Texto)"; value: robotController.sttEngineName; iconSource: "assets/ui/icons/single/voice.png"; valueColor: root.green; Layout.fillWidth: true }
                    RocketMetricRow { label: "TTS (Texto -> Fala)"; value: robotController.ttsEngineName; iconSource: "assets/ui/icons/single/wave.png"; valueColor: root.green; Layout.fillWidth: true }
                    RocketMetricRow { label: "IA Local"; value: robotController.aiModelName; iconSource: "assets/ui/icons/single/brain.png"; valueColor: root.green; Layout.fillWidth: true }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                RocketPanel {
                    title: "FORMA DE ONDA"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 174
                    Waveform { Layout.fillWidth: true; Layout.fillHeight: true }
                }
                RocketPanel {
                    title: "COMANDOS RECENTES"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: [[robotController.lastVoiceCommand, root.currentTimeText], ["pause mission", "sim"], ["return home", "sim"], ["emergency stop", "sim"], ["battery status", "sim"]]
                        RocketMetricRow { required property var modelData; label: "\u03bc  " + modelData[0]; value: modelData[1]; Layout.fillWidth: true; implicitHeight: 38 }
                    }
                    RocketButton { text: "VER TODOS OS COMANDOS"; iconText: "\u2637"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 40 }
                }
                RocketPanel {
                    title: "CONTROLES DE VOZ"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    RowLayout {
                        Layout.fillWidth: true
                        RocketButton { text: "TESTAR MICROFONE"; iconText: "\u03bc"; iconSource: "assets/ui/icons/single/voice.png"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42; onClicked: { robotController.testWhisper(); root.openVoiceDiagnostics() } }
                        RocketButton { text: "TESTAR TTS"; iconText: "\u266b"; iconSource: "assets/ui/icons/single/active-voice.png"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42; onClicked: { robotController.testPiper(); root.openVoiceDiagnostics() } }
                        RocketButton { text: "DIAGNOSTICO"; iconText: "\u258c"; iconSource: "assets/ui/icons/single/terminal.png"; variant: "primary"; Layout.fillWidth: true; Layout.preferredHeight: 42; onClicked: root.openVoiceDiagnostics() }
                    }
                }
                RocketPanel {
                    title: "SIMULAR COMANDO DE VOZ"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 92
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            text: root.voiceCommand
                            onTextChanged: root.voiceCommand = text
                            placeholderText: "start mission / pause mission / return home / emergency stop"
                            placeholderTextColor: "#68727E"
                            color: root.primaryText
                            Layout.fillWidth: true
                            background: Rectangle { radius: 4; color: "#0B1117"; border.width: 1; border.color: "#273441" }
                            onAccepted: robotController.simulateVoiceCommand(root.voiceCommand)
                        }
                        RocketButton { text: "SIMULAR"; iconText: "\u03bc"; iconSource: "assets/ui/icons/single/voice.png"; variant: "primary"; Layout.preferredWidth: 128; Layout.preferredHeight: 42; onClicked: robotController.simulateVoiceCommand(root.voiceCommand) }
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 360
                Layout.minimumWidth: 340
                Layout.maximumWidth: 380
                Layout.fillHeight: true
                spacing: 12
                RocketPanel {
                    title: "DISPOSITIVOS DE ÁUDIO"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text { text: "ENTRADA (MICROFONE)"; color: root.muted; font.pixelSize: 12 }
                    RowLayout {
                        Layout.fillWidth: true
                        RocketButton { text: "USB Microphone (Realtek)"; iconText: "\u03bc"; iconSource: "assets/ui/icons/single/voice.png"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42 }
                        StatusChip { label: "ONLINE"; tone: "green"; Layout.preferredWidth: 78 }
                    }
                    Waveform { bars: 42; Layout.fillWidth: true; Layout.preferredHeight: 48 }
                    Text { text: "SAÍDA (ALTO-FALANTE)"; color: root.muted; font.pixelSize: 12 }
                    RowLayout {
                        Layout.fillWidth: true
                        RocketButton { text: "Fones de Ouvido (Realtek)"; iconText: "\u266b"; iconSource: "assets/ui/icons/single/wave.png"; variant: "secondary"; Layout.fillWidth: true; Layout.preferredHeight: 42 }
                        StatusChip { label: "ONLINE"; tone: "green"; Layout.preferredWidth: 78 }
                    }
                    Waveform { bars: 42; Layout.fillWidth: true; Layout.preferredHeight: 48 }
                }
                RocketPanel {
                    title: "MODELO DE IA LOCAL"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 260
                    RocketMetricRow { label: "Modelo"; value: robotController.aiModelName; iconSource: "assets/ui/icons/single/brain.png"; valueColor: root.cyan; Layout.fillWidth: true }
                    RocketMetricRow { label: "Status"; value: "ONLINE  \u25cf"; valueColor: root.green; Layout.fillWidth: true }
                    RocketMetricRow { label: "Pipeline"; value: robotController.voicePipeline; iconSource: "assets/ui/icons/single/terminal.png"; Layout.fillWidth: true }
                    RocketMetricRow { label: "Contexto"; value: "4K tokens"; Layout.fillWidth: true }
                    RocketMetricRow { label: "Temperatura"; value: "0.30"; Layout.fillWidth: true }
                    RocketMetricRow { label: "Uso de Memória"; value: "62%"; Layout.fillWidth: true }
                    RocketProgressBar { value: 62; accent: root.cyan; Layout.fillWidth: true; Layout.preferredHeight: 7 }
                    RocketButton { text: "VER DETALHES DO MODELO"; iconSource: "assets/ui/icons/single/details.png"; variant: "outlined"; Layout.fillWidth: true; Layout.preferredHeight: 40; onClicked: root.openVoiceDiagnostics() }
                }
            }
        }
    }

    component LogsPage: PageShell {
        PageTitle {
            title: "Logs"
            subtitle: "System event log and activity console."
        }

        RocketPanel {
            compact: true
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [["ALL", "1247", "cyan"], ["INFO", "892", "green"], ["WARNING", "213", "amber"], ["ERROR", "42", "red"], ["MISSION", "356", "cyan"], ["ROBOT", "512", "cyan"], ["COMPUTER", "198", "cyan"], ["VOICE", "181", "cyan"]]
                    StatusChip {
                        required property var modelData
                        label: modelData[0] + "     " + modelData[1]
                        tone: modelData[2]
                        Layout.preferredWidth: 118
                    }
                }
                Item { Layout.fillWidth: true }
                RocketButton { text: "CLEAR FILTERS"; iconText: "\u25bd"; variant: "outlined"; labelPixelSize: 12; Layout.preferredWidth: 150; Layout.preferredHeight: 36 }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                RocketPanel {
                    compact: true
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "TIME  \u2195"; color: "#AEB7C2"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 150 }
                        Text { text: "LEVEL"; color: "#AEB7C2"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 112 }
                        Text { text: "MODULE"; color: "#AEB7C2"; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 150 }
                        Text { text: "DESCRIPTION"; color: "#AEB7C2"; font.pixelSize: 12; font.bold: true; Layout.fillWidth: true }
                    }
                    Repeater {
                        model: robotController.logs
                        RocketLogRow {
                            required property int index
                            required property var modelData
                            timeText: root.parseLogTime(modelData)
                            level: root.parseLogLevel(modelData)
                            moduleName: root.parseLogLevel(modelData) === "CRITICAL" ? "SAFETY" : root.parseLogLevel(modelData) === "WARNING" ? "MISSION CONTROL" : "ROCKET"
                            description: root.parseLogMessage(modelData)
                            selected: index === robotController.logs.length - 1
                            Layout.fillWidth: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    RocketButton { text: "AUTO SCROLL"; iconText: "\u25cf"; variant: "outlined"; labelPixelSize: 11; Layout.preferredWidth: 146; Layout.preferredHeight: 34 }
                    Item { Layout.fillWidth: true }
                    Text { text: "Showing " + robotController.logs.length + " simulated cockpit logs"; color: root.muted; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Repeater {
                        model: ["\u226a", "\u2039", "1", "2", "3", "...", "125", "\u203a", "\u226b"]
                        RocketIconButton {
                            required property string modelData
                            iconText: modelData
                            selected: modelData === "1"
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 32
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 320
                Layout.minimumWidth: 300
                Layout.maximumWidth: 340
                Layout.fillHeight: true
                spacing: 12
                RocketPanel {
                    title: "LOG DETAILS"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RocketMetricRow { label: "Timestamp"; value: "28/05/2025 14:28:47.123"; Layout.fillWidth: true }
                    RocketMetricRow { label: "Level"; value: "INFO"; valueColor: root.green; Layout.fillWidth: true }
                    RocketMetricRow { label: "Module"; value: "MISSION CONTROL"; valueColor: root.cyan; Layout.fillWidth: true }
                    RocketMetricRow { label: "Event ID"; value: "MC-2025-05-28-00123"; Layout.fillWidth: true }
                    RocketMetricRow { label: "Source"; value: "Operator Console"; Layout.fillWidth: true }
                    Text { text: "Description"; color: root.muted; font.pixelSize: 12 }
                    Text { text: "Mission \"Exploração de Área Alfa\" started by operator."; color: "#D0D7DE"; font.pixelSize: 12; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    RocketMetricRow { label: "User"; value: "Operator"; Layout.fillWidth: true }
                    RocketMetricRow { label: "Session"; value: "SIM-2025-05-28-14-01"; Layout.fillWidth: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Tags"; color: root.muted; font.pixelSize: 12; Layout.preferredWidth: 48 }
                        StatusChip { label: "mission"; tone: "cyan"; Layout.preferredWidth: 76 }
                        StatusChip { label: "start"; tone: "cyan"; Layout.preferredWidth: 64 }
                        Item { Layout.fillWidth: true }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        RocketButton { text: "COPY DETAILS"; iconText: "\u25a3"; variant: "outlined"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 36 }
                        RocketButton { text: "EXPORT LOG"; iconText: "\u21e9"; variant: "outlined"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 36 }
                    }
                }
                RocketPanel {
                    title: "SYSTEM SUMMARY"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 205
                    Repeater {
                        model: [["Total Logs", "1,247"], ["Info", "892 \u25cf"], ["Warning", "213 \u25cf"], ["Error", "42 \u25cf"], ["First Log", "28/05/2025 13:02:11"], ["Last Log", "28/05/2025 14:28:47"]]
                        RocketMetricRow { required property var modelData; label: modelData[0]; value: modelData[1]; valueColor: modelData[0] === "Warning" ? root.amber : modelData[0] === "Error" ? root.red : modelData[0] === "Info" ? root.green : root.primaryText; Layout.fillWidth: true }
                    }
                    RocketButton { text: "VIEW STATISTICS"; iconText: "\u258c"; variant: "outlined"; labelPixelSize: 11; Layout.fillWidth: true; Layout.preferredHeight: 34 }
                }
            }
        }
    }

    component UiKitPage: PageShell {
        PageTitle {
            title: "UI Kit"
            subtitle: "Biblioteca visual de botões, estados e componentes do Chevel Rocket."
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: 12
            columnSpacing: 12

            RocketPanel {
                title: "1. PRIMARY BUTTONS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["NORMAL", "HOVER", "PRESSED", "DISABLED", "SELECTED"]
                        ColumnLayout {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            Text { text: modelData; color: root.muted; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                            RocketButton { text: "ARM ROBOT"; iconText: "\u2699"; variant: "primary"; previewState: index === 1 ? "hover" : index === 2 ? "pressed" : index === 3 ? "disabled" : index === 4 ? "selected" : ""; Layout.fillWidth: true; Layout.preferredHeight: 58; labelPixelSize: 10 }
                        }
                    }
                }
            }

            RocketPanel {
                title: "2. SECONDARY BUTTONS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["NORMAL", "HOVER", "PRESSED", "DISABLED", "SELECTED"]
                        ColumnLayout {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            Text { text: modelData; color: root.muted; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                            RocketButton { text: "START MISSION"; iconText: "\u25b6"; variant: "secondary"; previewState: index === 1 ? "hover" : index === 2 ? "pressed" : index === 3 ? "disabled" : index === 4 ? "selected" : ""; Layout.fillWidth: true; Layout.preferredHeight: 58; labelPixelSize: 10 }
                        }
                    }
                }
            }

            RocketPanel {
                title: "3. OUTLINED BUTTONS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["NORMAL", "HOVER", "PRESSED", "DISABLED", "SELECTED"]
                        ColumnLayout {
                            required property int index
                            required property string modelData
                            Layout.fillWidth: true
                            Text { text: modelData; color: root.muted; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                            RocketButton { text: "CALIBRATE"; iconText: "\u25ce"; variant: "outlined"; previewState: index === 1 ? "hover" : index === 2 ? "pressed" : index === 3 ? "disabled" : index === 4 ? "selected" : ""; Layout.fillWidth: true; Layout.preferredHeight: 58; labelPixelSize: 10 }
                        }
                    }
                }
            }

            RocketPanel {
                title: "4. COMPACT ICON BUTTONS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: ["\u2699", "\u25ce", "\u25b6", "||", "\u2302", "\u2713", "\u00d7", "\u24d8", "\u2699"]
                        RocketIconButton { required property string modelData; iconText: modelData; Layout.preferredWidth: 40; Layout.preferredHeight: 40 }
                    }
                }
            }

            RocketPanel {
                title: "5. SLIM TOOLBAR BUTTONS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10
                    Repeater {
                        model: ["", "hover", "pressed", "selected"]
                        RocketButton { required property string modelData; text: "CALIBRATE SENSORS"; iconText: "\u2637"; variant: "slim"; previewState: modelData; Layout.fillWidth: true; Layout.preferredHeight: 34; labelPixelSize: 11 }
                    }
                }
            }

            RocketPanel {
                title: "6. SPECIAL BUTTONS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10
                    RocketButton { text: "EMERGENCY STOP"; iconText: "!"; variant: "emergency"; Layout.fillWidth: true; Layout.preferredHeight: 52 }
                    RocketButton { text: "CONFIRM"; iconText: "\u2713"; variant: "confirm"; Layout.fillWidth: true; Layout.preferredHeight: 52 }
                    RocketButton { text: "WARNING"; iconText: "!"; variant: "warning"; Layout.fillWidth: true; Layout.preferredHeight: 52 }
                    RocketButton { text: "READY"; iconText: "\u2713"; variant: "ready"; Layout.fillWidth: true; Layout.preferredHeight: 52 }
                }
            }

            RocketPanel {
                title: "7. MODE TOGGLE (SEGMENTED)"
                Layout.fillWidth: true
                Layout.fillHeight: true
                RocketSegmentedToggle { segments: ["SIMULATION", "LIVE"]; selectedIndex: 0; interactive: false; Layout.preferredWidth: 280; Layout.preferredHeight: 46 }
            }

            RocketPanel {
                title: "8. STATUS PILLS"
                Layout.fillWidth: true
                Layout.fillHeight: true
                GridLayout {
                    Layout.fillWidth: true
                    columns: 3
                    rowSpacing: 10
                    columnSpacing: 10
                    RocketStatusPill { valueText: "SAFE MODE"; status: "SAFE MODE"; iconText: "\u25c7"; Layout.fillWidth: true }
                    RocketStatusPill { valueText: "WARNING"; status: "WARNING"; iconText: "!"; Layout.fillWidth: true }
                    RocketStatusPill { valueText: "OFFLINE"; status: "OFFLINE"; iconText: "\u25cc"; Layout.fillWidth: true }
                    RocketStatusPill { valueText: "ONLINE"; status: "ONLINE"; iconText: "\u224b"; Layout.fillWidth: true }
                    RocketStatusPill { valueText: "READY"; status: "READY"; iconText: "\u2713"; Layout.fillWidth: true }
                    RocketStatusPill { valueText: "SIMULATED"; status: "SIMULATED"; iconText: "\u25ad"; Layout.fillWidth: true }
                }
            }

            RocketPanel {
                title: "9. BRANDING"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Image { source: "assets/ui/branding/chevel-rocket-logo.png"; Layout.fillWidth: true; Layout.fillHeight: true; fillMode: Image.PreserveAspectFit; smooth: true }
            }
        }

        RocketPanel {
            title: "10. NOTES / TOKENS"
            compact: true
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            RowLayout {
                Layout.fillWidth: true
                spacing: 24
                Text { text: "COLOR PALETTE"; color: root.muted; font.pixelSize: 11; font.bold: true }
                StatusChip { label: "CYAN #00D1FF"; tone: "cyan"; Layout.preferredWidth: 140 }
                StatusChip { label: "GREEN #7CFF72"; tone: "green"; Layout.preferredWidth: 150 }
                StatusChip { label: "WARNING #FFB020"; tone: "amber"; Layout.preferredWidth: 164 }
                StatusChip { label: "DANGER #EF4444"; tone: "red"; Layout.preferredWidth: 154 }
                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 54; color: "#25313C" }
                Text { text: "TYPOGRAPHY (EXAMPLE)\nHeading 1  /  26px\nBody text example"; color: root.primaryText; font.pixelSize: 14; Layout.fillWidth: true }
            }
        }
    }
}
