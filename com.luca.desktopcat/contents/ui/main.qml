import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls
import QtQuick.Window
import QtCore
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property string petName: plasmoid.configuration.petName !== undefined ? plasmoid.configuration.petName : "Tom"
    property real animSpeed: plasmoid.configuration.animationSpeed !== undefined ? plasmoid.configuration.animationSpeed : 1.0
    property real catScale: plasmoid.configuration.catScale !== undefined ? plasmoid.configuration.catScale : 1.0
    property bool stretchToFill: plasmoid.configuration.stretchToFill !== undefined ? plasmoid.configuration.stretchToFill : false
    property int extraPadding: plasmoid.configuration.extraPadding !== undefined ? plasmoid.configuration.extraPadding : 12
    property int idleInterval: plasmoid.configuration.idleInterval !== undefined ? plasmoid.configuration.idleInterval : 4000
    property bool tightCrop: plasmoid.configuration.tightCrop !== undefined ? plasmoid.configuration.tightCrop : true
    property real hungerDecay: (plasmoid.configuration.hungerDecay !== undefined ? plasmoid.configuration.hungerDecay : 2) / 100
    property real energyDecay: (plasmoid.configuration.energyDecay !== undefined ? plasmoid.configuration.energyDecay : 3) / 100
    property real happinessDecay: (plasmoid.configuration.happinessDecay !== undefined ? plasmoid.configuration.happinessDecay : 2) / 100
    property real feedAmount: (plasmoid.configuration.feedAmount !== undefined ? plasmoid.configuration.feedAmount : 35) / 100
    property real playBoost: (plasmoid.configuration.playBoost !== undefined ? plasmoid.configuration.playBoost : 20) / 100
    property real playCost: (plasmoid.configuration.playCost !== undefined ? plasmoid.configuration.playCost : 12) / 100
    property real sleepRate: (plasmoid.configuration.sleepRate !== undefined ? plasmoid.configuration.sleepRate : 6) / 100
    property int wanderChance: plasmoid.configuration.wanderChance !== undefined ? plasmoid.configuration.wanderChance : 35
    property real roamWidth: plasmoid.configuration.roamWidth !== undefined ? plasmoid.configuration.roamWidth : 0.84
    property real strollSpeed: plasmoid.configuration.strollSpeed !== undefined ? plasmoid.configuration.strollSpeed : 1.0

    readonly property int cellW: 32
    readonly property int cellH: 32
    readonly property var animRow: ({
        "idle": 0, "idle_look_around": 1, "idle_licking_paw": 2,
        "idle_cleaning": 3, "walking": 4, "running": 5,
        "sleeping": 6, "walking_silly": 7, "jumping": 8, "mad_hissing": 9
    })
    readonly property var animFrames: ({
        "idle": 4, "idle_look_around": 4, "idle_licking_paw": 4,
        "idle_cleaning": 4, "walking": 8, "running": 8,
        "sleeping": 4, "walking_silly": 6, "jumping": 7, "mad_hissing": 8
    })
    readonly property var animDuration: ({
        "idle": 200, "idle_look_around": 250, "idle_licking_paw": 300,
        "idle_cleaning": 250, "walking": 120, "running": 80,
        "sleeping": 400, "walking_silly": 150, "jumping": 100, "mad_hissing": 120
    })
    readonly property var idleAnims: ["idle", "idle_look_around", "idle_licking_paw", "idle_cleaning"]

    readonly property var animCrop: ({
        "idle": [8, 19, 14, 13],
        "idle_look_around": [8, 19, 14, 13],
        "idle_licking_paw": [8, 19, 15, 13],
        "idle_cleaning": [8, 19, 15, 13],
        "walking": [6, 19, 19, 13],
        "running": [6, 18, 19, 14],
        "sleeping": [7, 23, 18, 9],
        "walking_silly": [9, 19, 17, 13],
        "jumping": [8, 13, 17, 19],
        "mad_hissing": [6, 20, 19, 12]
    })

    function clipRect() {
        var row = animRow[currentAnim] || 0;
        if (!tightCrop) return Qt.rect(frameIndex * cellW, row * cellH, cellW, cellH);
        var c = animCrop[currentAnim] || [0, 0, cellW, cellH];
        return Qt.rect(frameIndex * cellW + c[0], row * cellH + c[1], c[2], c[3]);
    }

    readonly property real refCropH: 13
    readonly property real panelThickness: Math.max(10, root.height > 0 ? root.height : (plasmoid.height > 0 ? plasmoid.height : 40))
    readonly property real spriteScale: (panelThickness * catScale) / refCropH

    property string currentAnim: "idle"
    property int frameIndex: 0
    property int idleIndex: 0
    property real happiness: 0.5
    property real energy: 0.9
    property real hunger: 0.5
    property bool sleepy: false
    property bool mad: false
    property real cleanliness: 0.7
    property bool careLock: false
    property string bubbleText: "meow!"
    property int hopPhase: 0

    readonly property string expression: {
        if (sleepy) return "sleepy";
        if (mad) return "mad";
        if (hunger < 0.2) return "hungry";
        if (happiness > 0.7) return "happy";
        if (happiness < 0.35) return "sad";
        if (energy > 0.8) return "alert";
        return "neutral";
    }

    toolTipMainText: petName
    toolTipSubText: "click to say hi"
    preferredRepresentation: compactRepresentation

    function durationFor(anim) {
        var d = animDuration[anim] || 200;
        return Math.max(40, d / Math.max(0.2, animSpeed));
    }
    function selectAnimation() {
        if (sleepy) return "sleeping";
        if (mad) return "mad_hissing";
        if (currentAnim === "jumping") return "jumping";
        if (happiness > 0.8 && energy > 0.6) return "running";
        if (happiness > 0.6 && energy > 0.5) return "walking_silly";
        return idleAnims[idleIndex % idleAnims.length];
    }
    function forceAnimation(name) {
        if (!(name in animRow)) return;
        currentAnim = name;
        frameIndex = 0;
    }
    function say(t) { bubbleText = t; }
    function sayOneOf(list) { bubbleText = list[Math.floor(Math.random() * list.length)]; }
    function clamp01(v) { return Math.max(0, Math.min(1, v)); }

    function expressionEmoji() {
        switch (root.expression) {
        case "happy": return "😺";
        case "sad": return "😿";
        case "sleepy": return "😴";
        case "mad": return "😾";
        case "hungry": return "🙀";
        case "alert": return "😸";
        default: return "🐱";
        }
    }

    function applyBackendMood(m) {
        if (!m) return;
        if (m.expression === "sleepy" && root.energy > 0.3)
            root.energy = Math.max(0.05, 0.3);
        if (typeof m.happiness === "number")
            root.happiness = Math.max(0.05, Math.min(1,
                root.happiness * 0.6 + m.happiness * 0.4));
        if (typeof m.energy === "number")
            root.energy = Math.max(0.05, Math.min(1,
                root.energy * 0.6 + m.energy * 0.4));
        root.currentAnim = root.selectAnimation();
    }

    function doPet() {
        happiness = clamp01(happiness + root.playBoost * 0.6);
        energy = clamp01(energy + 0.02);
        mad = false;
        var petAnims = ["idle_licking_paw", "idle_look_around"];
        var a = petAnims[Math.floor(Math.random() * petAnims.length)];
        beginCare(a, root.durationFor(a) * root.animFrames[a]);
        sayOneOf(["purr... purr...", "meow!", "hehe, that tickles!", "purrr :3"]);
    }
    function beginCare(name, ms) {
        careLock = true;
        forceAnimation(name);
        careTimer.interval = Math.max(100, ms);
        careTimer.restart();
    }
    function endCare() {
        careLock = false;
        currentAnim = selectAnimation();
    }
    function doGroom() {
        if (sleepy) { say("zzz... groom me later..."); return; }
        cleanliness = clamp01(cleanliness + 0.35);
        happiness = clamp01(happiness + root.playBoost * 0.6);
        mad = false;
        beginCare("idle_cleaning",
                  root.durationFor("idle_cleaning") * root.animFrames.idle_cleaning);
        sayOneOf(["*grooming*", "so clean now!", "purr... sparkly!"]);
    }
    function doLaser() {
        if (sleepy) { say("zzz... too sleepy to chase..."); return; }
        if (energy < 0.2) { say("too tired to chase..."); return; }
        energy = clamp01(energy - root.playCost);
        happiness = clamp01(happiness + root.playBoost);
        careLock = true;
        forceAnimation("running");
        sayOneOf(["*chases the laser*", "got it!", "pounce!"]);
        laserSeq.interval = root.durationFor("running") * root.animFrames.running;
        laserSeq.restart();
    }
    function doCatnip() {
        if (sleepy) { say("zzz... catnip later..."); return; }
        happiness = 1.0;
        careLock = true;
        forceAnimation("jumping");
        sayOneOf(["CATNIP!", "*zoomies*", "wheee!!"]);
        catnipSeq.interval = root.durationFor("jumping") * root.animFrames.jumping;
        catnipSeq.restart();
    }
    function doFeed() {
        hunger = clamp01(hunger + root.feedAmount);
        happiness = clamp01(happiness + root.playBoost * 0.4);
        forceAnimation("idle_licking_paw");
        sayOneOf(["nom nom nom!", "tasty! meow!", "*licks paw*", "more please?"]);
        moodTimer.restart();
    }
    function doPlay() {
        if (sleepy) { say("zzz... let me sleep..."); return; }
        if (energy < 0.25) { say("too tired..."); forceAnimation("sleeping"); return; }
        happiness = clamp01(happiness + root.playBoost * 0.5);
        energy = clamp01(energy - root.playCost);
        hunger = clamp01(hunger - root.playCost * 0.5);
        forceAnimation(happiness > 0.6 ? "walking_silly" : "walking");
        sayOneOf(["wheee!", "catch me!", "this is fun!", "again! again!"]);
        moodTimer.restart();    
    }
    function doSleepToggle() {
        careTimer.stop();
        careLock = false;
        if (sleepy) {
            sleepy = false;
            if (energy < 0.8) {
                mad = true;
                happiness = clamp01(happiness - 0.15);
                forceAnimation("mad_hissing");
                sayOneOf(["HISS!", "grrr... I wasn't done!", "rude!!"]);
            } else {
                forceAnimation("idle");
                say("I'm awake!");
            }
        } else {
            sleepy = true;
            forceAnimation("sleeping");
            say("zzz... goodnight...");
        }
        moodTimer.restart();
    }
    function doPoke() {
        mad = true;
        forceAnimation("mad_hissing");
        sayOneOf(["HISS!", "hey!!", "grrr..."]);
        moodTimer.restart();
    }

    function openLink(link) {
        if (!link) return;
        var scheme = (link.split(":")[0] || "").toLowerCase();
        if (scheme === "http" || scheme === "https" || scheme === "mailto")
            Qt.openUrlExternally(link);
    }

    function copyToClipboard(text) {
        var ta = Qt.createQmlObject(
            "import QtQuick; TextEdit { visible: false }", root);
        ta.text = text;
        ta.selectAll();
        ta.copy();
        ta.destroy();
    }

    Timer {
        id: frameTimer
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            interval = root.durationFor(root.currentAnim);
            var n = root.animFrames[root.currentAnim] || 4;
            root.frameIndex = (root.frameIndex + 1) % n;
            if (root.frameIndex === 0) {
                if (root.careLock) return;
                if (root.currentAnim === "mad_hissing") root.mad = false;
                if (root.currentAnim === "jumping" || root.currentAnim === "mad_hissing")
                    root.currentAnim = root.selectAnimation();
            }
        }
    }

    Timer {
        id: idleTimer
        interval: root.idleInterval
        running: true
        repeat: true
        onTriggered: {
            if (root.careLock) return;
            if (root.sleepy) {
                root.energy = root.clamp01(root.energy + root.sleepRate);
                if (root.energy > 0.95) root.sleepy = false;
                root.currentAnim = root.selectAnimation();
                return;
            }
            root.idleIndex = (root.idleIndex + 1) % root.idleAnims.length;
            if (root.happiness > 0.5) root.happiness = Math.max(0.5, root.happiness - root.happinessDecay);
            else root.happiness = Math.min(0.5, root.happiness + root.happinessDecay);
            root.energy = Math.max(0.15, root.energy - root.energyDecay);
            root.hunger = Math.max(0, root.hunger - root.hungerDecay);
            root.cleanliness = Math.max(0, root.cleanliness - 0.015);
            if (root.energy < 0.25) root.sleepy = true;
            
            if (!root.sleepy && !root.mad && Math.random() * 100 < root.wanderChance) {
                root.patrolPause = 0;
                root.patrolTarget = 0.08 + Math.random() * 0.84;
                if (root.currentAnim !== "jumping" && root.currentAnim !== "mad_hissing") {
                    var opts = ["walking", "walking", "walking_silly"];
                    if (root.energy > 0.6 && Math.random() < 0.25) opts.push("running");
                    root.currentAnim = opts[Math.floor(Math.random() * opts.length)];
                }
            } else if (root.isWalkingAnim && Math.random() < 0.25) {
                root.currentAnim = root.idleAnims[Math.floor(Math.random() * root.idleAnims.length)];
            }
            if (root.hunger < 0.2 && root.currentAnim !== "jumping")
                root.sayOneOf(["I'm hungry...", "got any snacks?", "meow... food?"]);
            else if (root.currentAnim !== "jumping" && root.currentAnim !== "mad_hissing")
                root.currentAnim = root.selectAnimation();
        }
    }

    Timer {
        id: moodTimer
        interval: 2500
        running: false
        repeat: false
        onTriggered: {
            if (root.careLock) return;
            if (root.currentAnim !== "sleeping" || !root.sleepy)
                root.currentAnim = root.selectAnimation();
        }
    }

    Timer {
        id: careTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: root.endCare()
    }
    Timer {
        id: laserSeq
        interval: 1000
        running: false
        repeat: false
        onTriggered: root.beginCare("jumping",
            root.durationFor("jumping") * root.animFrames.jumping)
    }
    Timer {
        id: catnipSeq
        interval: 1000
        running: false
        repeat: false
        onTriggered: root.beginCare("walking_silly", 10000)
    }

    property real patrolX: 0.5
    property real patrolTarget: 0.5
    property int patrolPause: 0
    property real spacerShare: 200
    property real spacerFactor: plasmoid.configuration.spacerFactor !== undefined ? plasmoid.configuration.spacerFactor : 0.55
    property real patrolDir: 1
    property bool facingRight: true
    readonly property bool isWalkingAnim: currentAnim === "walking" || currentAnim === "walking_silly" || currentAnim === "running"

    compactRepresentation: Item {
        id: compact
        Layout.fillWidth: root.stretchToFill
        Layout.fillHeight: true
        Layout.preferredWidth: root.stretchToFill ? root.spacerShare : Math.max(48, Math.ceil(19 * root.spriteScale) + root.extraPadding)
        Layout.preferredHeight: 40
        Layout.minimumWidth: 1
        Layout.minimumHeight: 1
        Layout.maximumWidth: 65535

        function isSelf(item) {
            if (item === compact) return true;
            var p = compact.parent;
            while (p) {
                if (p === item) return true;
                p = p.parent;
            }
            return false;
        }

        function fairSpacerShare() {
            var layout = compact.parent;
            while (layout && layout.rowSpacing === undefined) layout = layout.parent;
            if (!layout || !(layout.width > 0)) return root.spacerShare || 200;
            var expandingSpacers = 0;
            var fixedTotal = 0;
            var kids = layout.children;
            for (var i = 0; i < kids.length; i++) {
                var c = kids[i];
                if (!c.visible) continue;
                if (compact.isSelf(c)) continue;
                var isSpacer = c.applet && c.applet.plasmoid
                    && c.applet.plasmoid.pluginName === "org.kde.plasma.panelspacer"
                    && c.applet.plasmoid.configuration.expanding;
                if (isSpacer) { expandingSpacers++; continue; }
                var lo = c.Layout ? c.Layout.minimumWidth : 0;
                var hi = c.Layout ? c.Layout.maximumWidth : 0;
                var pref = c.Layout ? c.Layout.preferredWidth : 0;
                var w = Math.min(hi > 0 ? hi : pref, Math.max(lo, pref)) || 0;
                fixedTotal += w + (layout.rowSpacing || 0);
            }
            var avail = layout.width - fixedTotal;
            if (expandingSpacers > 0) avail = avail / (expandingSpacers + 1);
            return Math.max(48, avail * root.spacerFactor);
        }

        Timer {
            id: spacerTimer
            interval: 1500
            running: root.stretchToFill
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var w = compact.fairSpacerShare();
                if (Math.abs(w - root.spacerShare) < 2) return;
                root.spacerShare = w;
            }
        }

        Timer {
            id: patrolTimer
            interval: 50
            running: true
            repeat: true
            onTriggered: {
                var wideEnough = compact.width > 60;
                if (root.mad || root.sleepy) {
                    root.hopPhase = 0;
                    return;
                }
                if (!root.isWalkingAnim) {
                    root.hopPhase = 0;
                    return;
                }
                if (!wideEnough) return;

                if (root.patrolPause > 0) {
                    root.patrolPause--;
                    root.hopPhase = 0;
                    if (Math.random() < 0.1) root.facingRight = root.patrolTarget >= root.patrolX;
                    return;
                }

                var dist = root.patrolTarget - root.patrolX;
                var dir = dist >= 0 ? 1 : -1;
                root.patrolDir = dir;
                root.facingRight = dir > 0;
                var speed = root.currentAnim === "running" ? 0.035 : (root.currentAnim === "walking_silly" ? 0.025 : 0.015);
                speed *= root.strollSpeed;
                var step = Math.min(Math.abs(dist), speed);
                root.patrolX += dir * step;

                if (root.currentAnim === "walking_silly") {
                    root.hopPhase = (root.hopPhase + 1) % 4;
                } else {
                    root.hopPhase = 0;
                    if (Math.random() < 0.03) root.hopPhase = 2;
                }

                var span = Math.min(0.9, Math.max(0.2, root.roamWidth));
                if (Math.abs(root.patrolTarget - root.patrolX) < 0.03) {
                    var lo = Math.max(0.06, 0.5 - span / 2), hi = Math.min(0.94, 0.5 + span / 2);
                    root.patrolTarget = lo + Math.random() * (hi - lo);
                    if (Math.random() < 0.45) root.patrolPause = 2 + Math.floor(Math.random() * 10);
                }

                if (root.patrolX >= 0.94) { 
                    root.patrolX = 0.94; 
                    root.patrolTarget = 0.06 + Math.random() * 0.4; 
                    root.patrolPause = 5 + Math.floor(Math.random() * 6);
                    root.facingRight = false;
                }
                if (root.patrolX <= 0.06) { 
                    root.patrolX = 0.06; 
                    root.patrolTarget = 0.54 + Math.random() * 0.4; 
                    root.patrolPause = 5 + Math.floor(Math.random() * 6);
                    root.facingRight = true;
                }
            }
        }

        Image {
            id: panelCat
            readonly property var cc: root.animCrop[root.currentAnim] || [0, 0, root.cellW, root.cellH]
            readonly property real cw: Math.max(1, cc[2]) * Math.max(0.1, root.spriteScale)
            readonly property real ch: Math.max(1, cc[3]) * Math.max(0.1, root.spriteScale)
            width: Math.min(Math.max(8, cw), Math.max(16, compact.width))
            height: Math.min(Math.max(8, ch), Math.max(16, compact.height))
            x: {
                var maxX = Math.max(0, compact.width - width);
                if (compact.width > 60)
                    return Math.max(0, Math.min(maxX, root.patrolX * maxX));
                return 0;
            }
            y: Math.max(0, compact.height - height - (root.hopPhase * 2))
            source: Qt.resolvedUrl("../images/Cat.png")
            sourceClipRect: root.clipRect()
            smooth: false
            mipmap: false
            fillMode: Image.Stretch
            mirror: !root.facingRight
        }
        MouseArea {
            id: petMouse
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: function(mouse) {
                root.doPet();
                root.expanded = !root.expanded;
            }
            onPressAndHold: root.doPoke()
        }

    }

    fullRepresentation: ColumnLayout {
        id: popup
        Layout.preferredWidth: 340
        Layout.preferredHeight: 520
        Layout.minimumWidth: 280
        Layout.minimumHeight: 420
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Kirigami.Heading { text: root.petName; level: 3; Layout.fillWidth: true }
            PlasmaComponents.Label {
                text: {
                    switch (root.expression) {
                    case "happy": return "😺";
                    case "sad": return "😿";
                    case "sleepy": return "😴";
                    case "mad": return "😾";
                    case "hungry": return "🙀";
                    case "alert": return "😸";
                    default: return "🐱";
                    }
                }
                font.pixelSize: 22
            }
        }

        ColumnLayout {
                spacing: 8

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    Image {
                anchors.centerIn: parent
                width: 160; height: 160 * (root.tightCrop ? 13 / 19 : 1)
                source: Qt.resolvedUrl("../images/Cat.png")
                sourceClipRect: root.clipRect()
                smooth: false
                mipmap: false
                fillMode: Image.PreserveAspectFit
                mirror: !root.facingRight
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.doPet()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            PlasmaComponents.Label { text: root.expressionEmoji(); font.pixelSize: 14 }
            PlasmaComponents.Label { text: "❤"; font.pixelSize: 10; opacity: 0.8 }
            PlasmaComponents.ProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: root.happiness }
            PlasmaComponents.Label { text: "⚡"; font.pixelSize: 10; opacity: 0.8 }
            PlasmaComponents.ProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: root.energy }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Item { implicitWidth: 18 }
            PlasmaComponents.Label { text: "🍗"; font.pixelSize: 10; opacity: 0.8 }
            PlasmaComponents.ProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: root.hunger }
            PlasmaComponents.Label { text: "🧼"; font.pixelSize: 10; opacity: 0.8 }
            PlasmaComponents.ProgressBar { Layout.fillWidth: true; from: 0; to: 1; value: root.cleanliness }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 90
            Layout.preferredHeight: btnCol.implicitHeight

            Flickable {
                anchors.fill: parent
                contentHeight: btnCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: btnCol
                    width: parent.width
                    spacing: 6
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: "🍗 Feed"
                        onClicked: root.doFeed()
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: root.sleepy ? "☀ Wake" : "🌙 Sleep"
                        onClicked: root.doSleepToggle()
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: "✋ Pet"
                        onClicked: root.doPet()
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: "😾 Poke"
                        onClicked: root.doPoke()
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: "🧼 Groom"
                        onClicked: root.doGroom()
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: "🔴 Laser"
                        onClicked: root.doLaser()
                    }
                    PlasmaComponents.Button {
                        Layout.fillWidth: true
                        text: "🌿 Catnip"
                        onClicked: root.doCatnip()
                    }
                }
            }
        }
        }
    }
}