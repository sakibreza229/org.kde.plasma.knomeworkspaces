import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kcmutils as KCM
import org.kde.taskmanager as TaskManager
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    Kirigami.Theme.inherit: true

    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation
    
    readonly property QtObject virtualDesktopInfo: TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }
    
    property int currentDesktop: {
        let desktop = virtualDesktopInfo.currentDesktop
        if (typeof desktop === 'string') {
            return Math.max(0, virtualDesktopInfo.desktopIds.indexOf(desktop))
        }
        return Math.max(0, (desktop || 1) - 1)
    }
    
    property int desktopCount: (plasmoid.configuration.fixedDotCountEnabled === true) ? (plasmoid.configuration.fixedDotCount || 5) : (virtualDesktopInfo.numberOfDesktops || 1)
    
    property int dotSize: Math.max(8, plasmoid.configuration.dotSizeCustom || 8)
    property real spacingFactor: Math.max(0.1, Math.min(0.9, (plasmoid.configuration.spacingFactor !== undefined && !isNaN(plasmoid.configuration.spacingFactor)) ? plasmoid.configuration.spacingFactor : 0.1))
    property int activeWidth: Math.max(dotSize, plasmoid.configuration.activeSizeW || 24)
    property int activeHeight: Math.max(dotSize, plasmoid.configuration.activeSizeH || 8)
    property bool wrapOn: plasmoid.configuration.desktopWrapOn !== false

    property bool customColors: plasmoid.configuration.customColorsEnabled || false

    property color activeColor: {
        if (!customColors) {
            let c = Kirigami.Theme.highlightColor
            return (c && c !== "#000000") ? c : "#3daee9"
        }
        return plasmoid.configuration.activeColor || "#3daee9"
    }

    property color inactiveColor: {
        if (!customColors) {
            let c = Kirigami.Theme.textColor
            return (c && c !== "#000000") ? c : "#ffffff"
        }
        return plasmoid.configuration.inactiveColor || "#808080"
    }

    property int animDuration: Math.max(0, plasmoid.configuration.animationDuration || 300)
    property bool canAddDesktops: plasmoid.configuration.canAddDesktops !== false
    property int dotShape: plasmoid.configuration.dotShape || 0

    property real spacing: spacingFactor * dotSize
    property int horizontalMargin: Math.max(0, Math.min(10, (plasmoid.configuration.horizontalMargin !== undefined && !isNaN(plasmoid.configuration.horizontalMargin)) ? plasmoid.configuration.horizontalMargin : 0))
    property bool isHorizontal: plasmoid.formFactor !== PlasmaCore.Types.Vertical
    property int wheelDelta: 0
    
    function updateLayout() {
        root.implicitWidth = Qt.binding(function() { return Layout.minimumWidth })
        root.implicitHeight = Qt.binding(function() { return Layout.minimumHeight })
    }
    
    onDotSizeChanged: updateLayout()
    onSpacingFactorChanged: updateLayout()
    onHorizontalMarginChanged: updateLayout()
    onActiveWidthChanged: updateLayout()
    onActiveHeightChanged: updateLayout()
    onDesktopCountChanged: updateLayout()
    onDotShapeChanged: updateLayout()

    Layout.minimumWidth: (isHorizontal
        ? (dotShape === 2 ? nameRow.implicitWidth
           : dotShape === 3 ? iconRow.implicitWidth
           : dotShape === 4 ? numRow.implicitWidth
           : (desktopCount * dotSize) + ((desktopCount - 1) * spacing) + (activeWidth - dotSize))
        : (dotShape === 2 ? nameColumn.implicitWidth
           : dotShape === 3 ? iconColumn.implicitWidth
           : dotShape === 4 ? numColumn.implicitWidth
           : activeWidth)) + (2 * horizontalMargin)

    Layout.minimumHeight: !isHorizontal
        ? (dotShape === 2 ? nameColumn.implicitHeight
           : dotShape === 3 ? iconColumn.implicitHeight
           : dotShape === 4 ? numColumn.implicitHeight
           : (desktopCount * dotSize) + ((desktopCount - 1) * spacing) + (activeHeight - dotSize))
        : (dotShape === 2 ? nameRow.implicitHeight
           : dotShape === 3 ? iconRow.implicitHeight
           : dotShape === 4 ? numRow.implicitHeight
           : activeHeight)
        
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    function switchToDesktop(index) {
        let desktopNumber = index + 1
        let service = "org.kde.KWin"
        let path = "/KWin"
        let kwinIface = "org.kde.KWin" 
        
        let call = 'qdbus6 ' + service + ' ' + path + ' ' + kwinIface + '.setCurrentDesktop ' + desktopNumber + ' 2>/dev/null || ' +
                   'qdbus ' + service + ' ' + path + ' ' + kwinIface + '.setCurrentDesktop ' + desktopNumber + ' 2>/dev/null || ' +
                   'kdotool set_desktop ' + desktopNumber + ' 2>/dev/null'
        
        executable.connectSource(call)
    }
    
    function addDesktop() {
        if (!canAddDesktops) return
        // Plasma 6: use /VirtualDesktopManager; append at end
        let pos = virtualDesktopInfo.numberOfDesktops
        let call = 'qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.createDesktop ' + pos + ' ""'
        executable.connectSource(call)
    }

    function removeDesktop() {
        if (!canAddDesktops || desktopCount <= 1) return
        // Plasma 6: removeDesktop takes a UUID string, remove the last desktop
        let ids = virtualDesktopInfo.desktopIds
        if (!ids || ids.length === 0) return
        let lastId = ids[ids.length - 1]
        let call = 'qdbus6 org.kde.KWin /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.removeDesktop ' + lastId
        executable.connectSource(call)
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
        }
    }

    // --- KGlobalAccel: Global keyboard shortcuts ---
    PlasmaCore.Action {
        id: nextDesktopAction
        text: i18n("Switch to Next Desktop")
        icon.name: "go-next"
        shortcut: plasmoid.configuration.nextDesktopShortcut
        onTriggered: {
            let target = wrapOn
                ? ((currentDesktop + 1) % desktopCount)
                : Math.min(currentDesktop + 1, desktopCount - 1)
            if (target !== currentDesktop) switchToDesktop(target)
        }
    }

    PlasmaCore.Action {
        id: prevDesktopAction
        text: i18n("Switch to Previous Desktop")
        icon.name: "go-previous"
        shortcut: plasmoid.configuration.prevDesktopShortcut
        onTriggered: {
            let target = wrapOn
                ? ((currentDesktop - 1 + desktopCount) % desktopCount)
                : Math.max(currentDesktop - 1, 0)
            if (target !== currentDesktop) switchToDesktop(target)
        }
    }

    Component.onCompleted: {
        updateLayout()
        plasmoid.setInternalAction("nextDesktop", nextDesktopAction)
        plasmoid.setInternalAction("prevDesktop", prevDesktopAction)
    }

    Item {
        id: mainContainer
        anchors.fill: parent
        anchors.leftMargin: root.horizontalMargin
        anchors.rightMargin: root.horizontalMargin
        
        // --- Circle / Square mode ---
        Repeater {
            id: desktopRepeater
            model: dotShape < 2 ? desktopCount : 0  // only circle / square

            delegate: Item {
                id: delegateItem
                readonly property bool isHovered: mouseHandler.containsMouse

                x: isHorizontal ? (index < currentDesktop ? index * (dotSize + spacing) : (index > currentDesktop ? (index * (dotSize + spacing)) + (activeWidth - dotSize) : index * (dotSize + spacing))) : (parent.width - width) / 2
                y: !isHorizontal ? (index < currentDesktop ? index * (dotSize + spacing) : (index > currentDesktop ? (index * (dotSize + spacing)) + (activeHeight - dotSize) : index * (dotSize + spacing))) : (parent.height - height) / 2

                width: isHorizontal ? (index === currentDesktop ? activeWidth : dotSize) : dotSize
                height: !isHorizontal ? (index === currentDesktop ? activeHeight : dotSize) : dotSize

                Rectangle {
                    id: desktopDot
                    anchors.fill: parent
                    color: index === currentDesktop ? activeColor : inactiveColor
                    opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                    radius: dotShape === 0 ? height * 0.5 : 2

                    Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    MouseArea {
                        id: mouseHandler
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }

                Behavior on x { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on y { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on width { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
                Behavior on height { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuad } }
            }
        }

        // --- Desktop Name mode (horizontal) ---
        Row {
            id: nameRow
            visible: isHorizontal && dotShape === 2
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 2 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: nameMouseArea.containsMouse
                    implicitWidth: nameText.implicitWidth
                    implicitHeight: nameText.implicitHeight
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: nameText
                        text: (virtualDesktopInfo.desktopNames && virtualDesktopInfo.desktopNames[index])
                              ? virtualDesktopInfo.desktopNames[index]
                              : (index + 1).toString()
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: dotSize + 2
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: nameMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Desktop Name mode (vertical) ---
        Column {
            id: nameColumn
            visible: !isHorizontal && dotShape === 2
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 2 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: nameMouseAreaV.containsMouse
                    implicitWidth: nameTextV.implicitWidth
                    implicitHeight: nameTextV.implicitHeight
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: nameTextV
                        text: (virtualDesktopInfo.desktopNames && virtualDesktopInfo.desktopNames[index])
                              ? virtualDesktopInfo.desktopNames[index]
                              : (index + 1).toString()
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: dotSize + 2
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: nameMouseAreaV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Icon mode (horizontal) ---
        Row {
            id: iconRow
            visible: isHorizontal && dotShape === 3
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 3 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: iconMouseH.containsMouse
                    implicitWidth: Math.max(16, dotSize + 8)
                    implicitHeight: Math.max(16, dotSize + 8)
                    width: implicitWidth
                    height: implicitHeight

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Math.max(14, dotSize + 4)
                        height: width
                        source: "virtual-desktops"
                        fallback: "preferences-desktop-virtual"
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        isMask: true

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: iconMouseH
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Icon mode (vertical) ---
        Column {
            id: iconColumn
            visible: !isHorizontal && dotShape === 3
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 3 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: iconMouseV.containsMouse
                    implicitWidth: Math.max(16, dotSize + 8)
                    implicitHeight: Math.max(16, dotSize + 8)
                    width: implicitWidth
                    height: implicitHeight

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Math.max(14, dotSize + 4)
                        height: width
                        source: "virtual-desktops"
                        fallback: "preferences-desktop-virtual"
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        isMask: true

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: iconMouseV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Desktop Number mode (horizontal) ---
        Row {
            id: numRow
            visible: isHorizontal && dotShape === 4
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 4 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: numMouseH.containsMouse
                    implicitWidth: Math.max(numTextH.implicitWidth + 8, dotSize + 8)
                    implicitHeight: Math.max(numTextH.implicitHeight + 4, dotSize + 4)
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: numTextH
                        anchors.centerIn: parent
                        text: "D" + (index + 1)
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: Math.max(11, dotSize + 2)
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: numMouseH
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        // --- Desktop Number mode (vertical) ---
        Column {
            id: numColumn
            visible: !isHorizontal && dotShape === 4
            anchors.centerIn: parent
            spacing: root.spacing

            Repeater {
                model: dotShape === 4 ? desktopCount : 0

                delegate: Item {
                    readonly property bool isHovered: numMouseV.containsMouse
                    implicitWidth: Math.max(numTextV.implicitWidth + 8, dotSize + 8)
                    implicitHeight: Math.max(numTextV.implicitHeight + 4, dotSize + 4)
                    width: implicitWidth
                    height: implicitHeight

                    Text {
                        id: numTextV
                        anchors.centerIn: parent
                        text: "D" + (index + 1)
                        color: index === currentDesktop ? activeColor : inactiveColor
                        opacity: index === currentDesktop ? 1.0 : (isHovered ? 0.9 : 0.4)
                        font.pixelSize: Math.max(11, dotSize + 2)
                        font.bold: index === currentDesktop

                        Behavior on color { ColorAnimation { duration: animDuration; easing.type: Easing.InOutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                    }

                    MouseArea {
                        id: numMouseV
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: switchToDesktop(index)
                    }
                }
            }
        }

        MouseArea {
            id: wheelArea
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                let delta = wheel.angleDelta.y || wheel.angleDelta.x
                wheelDelta += delta
                let steps = 0
                while (wheelDelta >= 120) { wheelDelta -= 120; steps-- }
                while (wheelDelta <= -120) { wheelDelta += 120; steps++ }

                if (steps !== 0) {
                    let targetDesktop = currentDesktop + steps
                    if (wrapOn) {
                        targetDesktop = ((targetDesktop % desktopCount) + desktopCount) % desktopCount
                    } else {
                        targetDesktop = Math.max(0, Math.min(desktopCount - 1, targetDesktop))
                    }
                    if (targetDesktop !== currentDesktop) switchToDesktop(targetDesktop)
                }
                wheel.accepted = true
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Add Virtual Desktop")
            icon.name: "list-add"
            enabled: canAddDesktops
            onTriggered: addDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Remove Virtual Desktop")
            icon.name: "list-remove"
            enabled: canAddDesktops && desktopCount > 1
            onTriggered: removeDesktop()
        },
        PlasmaCore.Action {
            text: i18n("Configure Virtual Desktops…")
            icon.name: "configure"
            onTriggered: KCM.KCMLauncher.openSystemSettings("kcm_kwin_virtualdesktops")
        }
    ]
}