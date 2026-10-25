import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_petName: nameField.text
    property alias cfg_catScale: sizeSlider.value
    property alias cfg_stretchToFill: stretchCheck.checked
    property alias cfg_extraPadding: paddingSpin.value
    property alias cfg_animationSpeed: speedSlider.value
    property alias cfg_idleInterval: idleSpin.value
    property alias cfg_tightCrop: cropCheck.checked
    property alias cfg_hungerDecay: hungerSpin.value
    property alias cfg_energyDecay: energySpin.value
    property alias cfg_happinessDecay: happySpin.value
    property alias cfg_feedAmount: feedSpin.value
    property alias cfg_playBoost: playSpin.value
    property alias cfg_playCost: costSpin.value
    property alias cfg_sleepRate: sleepSpin.value
    property alias cfg_wanderChance: wanderSpin.value
    property alias cfg_roamWidth: roamSlider.value
    property alias cfg_strollSpeed: strollSlider.value
    property alias cfg_spacerFactor: spacerSlider.value

    ColumnLayout {
        spacing: 10

        Label { text: "Pet name:"; font.weight: Font.Medium }
        TextField { id: nameField; Layout.fillWidth: true; placeholderText: "Tom" }

        Label { text: "Cat size: " + sizeSlider.value.toFixed(1) + "x panel height"; font.weight: Font.Medium }
        Slider {
            id: sizeSlider
            Layout.fillWidth: true
            from: 0.5; to: 1.0; stepSize: 0.1
            snapMode: Slider.SnapOnRelease
        }
        Label {
            text: "Bigger than the panel gets clipped by Plasma. For a truly huge cat, raise the panel height instead."
            font.pointSize: 9; opacity: 0.7; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }

        CheckBox { id: stretchCheck; text: "Act as panel spacer (fill free space)" }
        Label {
            text: "On = eats all free space like the built-in Spacer, pushing neighbors to the edges. Still shrinks when the task manager needs room. Needs a re-add to take full effect."
            font.pointSize: 9; opacity: 0.7; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }

        Label { text: "Extra horizontal padding:"; font.weight: Font.Medium }
        SpinBox { id: paddingSpin; from: 0; to: 200; stepSize: 2 }

        Label { text: "Animation speed: " + speedSlider.value.toFixed(1) + "x"; font.weight: Font.Medium }
        Slider {
            id: speedSlider
            Layout.fillWidth: true
            from: 0.2; to: 3.0; stepSize: 0.1
            snapMode: Slider.SnapOnRelease
        }

        Label { text: "Idle change interval:"; font.weight: Font.Medium }
        RowLayout {
            SpinBox { id: idleSpin; from: 1000; to: 15000; stepSize: 500 }
            Label { text: "ms"; opacity: 0.7 }
        }

        CheckBox { id: cropCheck; text: "Crop empty sprite space (bigger cat)" }

        Label { text: "Space claim: " + Math.round(spacerSlider.value * 100) + "% of a full spacer"; font.weight: Font.Medium; visible: stretchCheck.checked }
        Slider {
            id: spacerSlider
            Layout.fillWidth: true
            from: 0.2; to: 1.0; stepSize: 0.05
            snapMode: Slider.SnapOnRelease
            visible: stretchCheck.checked
        }
        Label {
            text: "Lower = slimmer strip, more room for your other spacer. Higher = wider playground for the cat."
            font.pointSize: 9; opacity: 0.7; Layout.fillWidth: true; wrapMode: Text.WordWrap; visible: stretchCheck.checked
        }

        Label { text: "Needs & moods (per idle tick):"; font.weight: Font.DemiBold }

        Label { text: "Food decay:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: hungerSpin; from: 0; to: 50; stepSize: 1 } Label { text: "% / tick  (default 2)"; opacity: 0.7 } }
        Label { text: "Energy decay:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: energySpin; from: 0; to: 50; stepSize: 1 } Label { text: "% / tick  (default 3)"; opacity: 0.7 } }
        Label { text: "Happiness decay:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: happySpin; from: 0; to: 50; stepSize: 1 } Label { text: "% / tick  (default 2)"; opacity: 0.7 } }
        Label {
            text: "Idle ticks happen every 'Idle change interval'. Set a decay to 0 and that need never drops."
            font.pointSize: 9; opacity: 0.7; Layout.fillWidth: true; wrapMode: Text.WordWrap
        }

        Label { text: "Feeding & playing:"; font.weight: Font.DemiBold }
        Label { text: "Food restored by feeding:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: feedSpin; from: 0; to: 100; stepSize: 5 } Label { text: "%  (default 35)"; opacity: 0.7 } }
        Label { text: "Happiness from play/pet:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: playSpin; from: 0; to: 100; stepSize: 5 } Label { text: "%  (default 20)"; opacity: 0.7 } }
        Label { text: "Energy + food cost of playing:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: costSpin; from: 0; to: 100; stepSize: 1 } Label { text: "%  (default 12)"; opacity: 0.7 } }
        Label { text: "Energy recovered per tick while sleeping:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: sleepSpin; from: 0; to: 100; stepSize: 1 } Label { text: "%  (default 6)"; opacity: 0.7 } }

        Label { text: "Wandering:"; font.weight: Font.DemiBold }
        Label { text: "Chance to start wandering each idle tick:"; font.weight: Font.Medium }
        RowLayout { SpinBox { id: wanderSpin; from: 0; to: 100; stepSize: 5 } Label { text: "%  (default 35)"; opacity: 0.7 } }
        Label { text: "Roam width: " + Math.round(roamSlider.value * 100) + "% of the strip"; font.weight: Font.Medium }
        Slider {
            id: roamSlider
            Layout.fillWidth: true
            from: 0.2; to: 0.9; stepSize: 0.05
            snapMode: Slider.SnapOnRelease
        }
        Label { text: "Stroll speed: " + strollSlider.value.toFixed(1) + "x"; font.weight: Font.Medium }
        Slider {
            id: strollSlider
            Layout.fillWidth: true
            from: 0.3; to: 3.0; stepSize: 0.1
            snapMode: Slider.SnapOnRelease
        }

        Item { Layout.fillHeight: true }
    }
}
