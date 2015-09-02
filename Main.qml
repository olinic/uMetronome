import QtQuick 2.2
import QtQuick.LocalStorage 2.0 as Sql
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.Pickers 1.0
import QtMultimedia 5.0
import Ubuntu.Layouts 1.0
import "components"
import "components/dbFunctions.js" as DbFunctions
import "components/effectFunctions.js" as EffectFunctions

/*
   *Copyright 2014 by Oliver Nichols
   *Released under the GNU General Public License version 3
*/


/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "umetronome.otter"

    useDeprecatedToolbar: false
    automaticOrientation: true

    anchorToKeyboard: true


    width: units.gu(50) // change to fill screen
    height: units.gu(75)

    property int tempoPickerHeight: units.gu(20)


    function calcInterval(bpm, subdivisions) {
        var interval = 60000/bpm
        interval = interval/subdivisions
        return interval
    }

    function playSound(index, measureCount, pattern, silentPattern) {
        if(index%measureCount == 0) {

            if(! timer.beat) {
                rotateAnimation.start()
            }
            timer.beat = ~ timer.beat

            var effect = EffectFunctions.getMainEffect();
            if (EffectFunctions.effectsAreSame()) {
                var vol = EffectFunctions.getVolume();
                effect.volume = vol;
            }
            effect.play();
        }
        else {
            playSubBeat(index, pattern, silentPattern)
        }
        timer.num = index%measureCount + 1
    }

    function playSubBeat(beat, pattern, silentPattern) {
        var soundPlayed = false;
        var makeSound = true;
        for (var i=0; i < silentPattern.length; i++) {
            if (beat == silentPattern[i]) {
                makeSound = false;
            }
        }

        if (makeSound) {
            if(pattern.length != 0) {
                for(var i=0; i < pattern.length; i++) {

                    if (beat == pattern[i]) {
                        var effect = EffectFunctions.getMainEffect();
                        if (EffectFunctions.effectsAreSame()) {
                            var vol = EffectFunctions.getVolume();
                            effect.volume = vol;
                        }
                        effect.play();
                        soundPlayed = true
                    }
                }
            }
            if(!soundPlayed) {

                var subEffect = EffectFunctions.getMainSubEffect();
                if (EffectFunctions.effectsAreSame()) {
                    var vol = EffectFunctions.getSubVolume();
                    subEffect.volume = vol;
                }

                subEffect.play()
            }
        }
    }

    function calculateBpm(ms) {
        var bpm = 60000/ms
        return bpm
    }

    ListModel {
        id: soundFiles

        Component.onCompleted: {

            EffectFunctions.setupSoundModel();
            EffectFunctions.setupSoundEffects();

            EffectFunctions.adjustVolume(mainBeatSlider.value)
            EffectFunctions.adjustSubVolume(subBeatSlider.value)


            EffectFunctions.getMainEffect().volume = EffectFunctions.getVolume();
            EffectFunctions.getMainSubEffect().volume = EffectFunctions.getSubVolume();
        }
    }



    Timer {
        id: timer
        interval: 500
        repeat: true
        running: false
        triggeredOnStart: false
        property int num: 0
        property int beat: 0
        property int subdivisions: 2
        property int tempoDivisions: 2 //divisions for calculating the tempo
        property int bpmCount: 120
        property string pattern: ""
        property string silentPattern: ""

        // store the pattern into an array to save on computational costs
        property var mainBeats: []
        property int mainBeatIndex: 0 // store the index to prevent from looping all the time

        property var silentBeats: []
        property int silentBeatIndex: 0



        onTriggered: {playSound(num, subdivisions, mainBeats, silentBeats)}

        onPatternChanged: {
            mainBeats = str2NumArray(pattern);
        }
        onSilentPatternChanged: {
            silentBeats = str2NumArray(silentPattern);
        }

        function str2NumArray(str) {
            var array = [];
            for (var i=0; i < str.length; i++) {
                array[i] = parseInt(str.charAt(i));
                //console.log(array[i])
            }
            return array;
        }

        Component.onCompleted: {
            tempoUpdate();
        }
        onSubdivisionsChanged: {
            tempoUpdate();
        }
        onTempoDivisionsChanged: {
            tempoUpdate();
        }
        onBpmCountChanged: {
            tempoUpdate();
        }

        function tempoUpdate() {
            interval = calcInterval(bpmCount, tempoDivisions)
            leftRotation.duration = interval*subdivisions
            rightRotation.duration = interval*subdivisions
        }
    }

    Component {

         id: beatSelector
         Popover {
             id: popover
             Column {
                 height: pageLayout.height
                 width: 200
                 anchors {
                     top: parent.top
                     left: parent.left
                     right: parent.right
                 }

                 Header {
                     id: header

                     text: i18n.tr("Choose from beat selection")
                 }

                 ListView {
                     height: pageLayout.height - header.height
                     width: parent.width

                     section.property: "type"
                     section.delegate: Rectangle {
                         width: parent.width

                         height: units.gu(1)

                         Text {
                             text: section
                             font.bold: true
                         }
                     }

                     model: Beats {}
                     delegate: Standard {
                         text: name
                         onClicked: {
                             beatButton.text = i18n.tr(name)
                             timer.subdivisions = number
                             timer.num = 0
                             timer.pattern = pattern
                             timer.silentPattern = silentPattern
                             timer.tempoDivisions = tempoDiv
                             beatImage.source = "icons/" + img
                             hide()
                         }
                     }
                 }
             }
         }
    }

    Component {

         id: soundSelector
         Popover {
             id: soundPopover
             Column {
                 height: pageLayout.height
                 width: 200
                 anchors {
                     top: parent.top
                     left: parent.left
                     right: parent.right
                 }

                 Header {
                     id: header
                     text: i18n.tr("Choose from sound selection")
                 }

                 ListView {
                     height: pageLayout.height - header.height - okButton.height
                     width: parent.width

                     model: soundFiles
                     delegate: Standard {
                         text: i18n.tr(name)
                         onClicked: {
                             caller.input = file
                             if(!timer.running) {

                                 var theEffect = EffectFunctions.getEffect(file)
                                 theEffect.play()

                             }
                         }
                     }
                 }
                 Button {
                     id: okButton
                     text: i18n.tr("Ok")
                     color: UbuntuColors.green
                     onClicked: {
                         hide()
                     }
                 }
             }
         }
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Confirmation")
            text: i18n.tr("Your settings have been saved!")
            Button {
                text: i18n.tr("Ok")
                color: UbuntuColors.green
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    Component {
        id: extraTempoSection
        DefaultSheet {
            id: tempoSheet
            title: i18n.tr("Select a tempo")


            contentsHeight: insideComponent.height
            doneButton: true

            ATempoPicker {
                id: insideComponent
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }



                onChanged: {
                    //update the other picker
                    //console.log(bpm);
                    mainTempoPicker.update(bpm);
                    timer.bpmCount = bpm;
                }
            }

            onDoneClicked: {
                //timer.doneClicked = timer.doneClicked*-1
                PopupUtils.close(tempoSheet)
            }
        }
    }

    //Tempo Finder Dialog
    Component {
        id: tempoFinder

        Dialog {
            id: tempoFinderDialog
            title: i18n.tr("Tempo Finder")
            width: pageLayout.width
            height: pageLayout.height

            signal closing()

            text: i18n.tr("The tempo finder determines a tempo based on the tempo of two clicks. Please use the button below to click twice for a tempo.")
            Column {
                spacing: units.gu(1)

                Row {
                    spacing: units.gu(1)
                    Button {

                        text: i18n.tr("Press")
                        color: UbuntuColors.orange
                        property int altValue: 0
                        property double timeOne: 0
                        property double timeTwo: 0
                        onClicked: {
                            altValue += 1
                            if (altValue%2 == 0) {
                                text = i18n.tr("Press")

                                //this runs after the second click; therefore, get the second time

                                timeTwo = Number(new Date().getTime());

                                //calculate bpm
                                if (timeOne != -1 && timeTwo != -1) {
                                    var milliSec = timeTwo-timeOne
                                    tempoFinderTempo.text = Math.round(calculateBpm(milliSec))
                                }
                            }

                            else {
                                text = i18n.tr("Press Again")

                                //this runs after the first click; therefore, get the first timeOne
                                timeOne = Number(new Date().getTime());


                            }
                        }
                    }
                    Label {
                        id: tempoFinderTempo
                        text: i18n.tr("0")
                        fontSize: "large"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: i18n.tr("bpm")
                        fontSize: "large"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: units.gu(1)
                    Button {
                        id: closeButton
                        text: i18n.tr("Close")
                        color: UbuntuColors.orange
                        onClicked: PopupUtils.close(tempoFinderDialog)
                    }
                    Button {
                        id: acceptTempoButton
                        text: i18n.tr("Use This Tempo")
                        color: UbuntuColors.orange


                        onClicked: {
                            //set the tempo
                            var tempo = tempoFinderTempo.text*1;
                            if (tempo >= 30 && tempo <= 240) {
                                //timer.finderCount = tempoFinderTempo.text*1 //when the finderCount is set, the picker will use it to update the bpm
                                //console.log("Set and update Pickers")
                                //mainTempoPicker.update(tempo);
                                timer.bpmCount = tempo;
                                tempoFinderDialog.closing();
                                PopupUtils.close(tempoFinderDialog)
                            }
                            else {
                                //display help to user
                                userHelp.text = i18n.tr("Please only submit a number that is between 30 and 240")

                            }


                        }
                    }
                }

                TextArea {
                    id: userHelp
                    readOnly: true
                    width: parent.width
                }

            }
        }
    }


    //These are the tabs to be displayed
    Tabs {
        id: tabs

        //Metronome Tab
        Tab {
            title: i18n.tr("uMetronome")

            page: Page {
               id: metronomePage

               head.actions: [

                    StartToolButton {},
                    SettingsToolButton {}
               ]



               Layouts {
                   id: pageLayout
                   anchors {
                       fill: parent
                   }

                   Component.onCompleted: {
                       var items = DbFunctions.getDbItems()
                       mainBeatSlider.value = items['mainVolume']
                       mainBeatLabel.text = i18n.tr(items['mainSound'])
                       subBeatSlider.value = items['subVolume']
                       subBeatLabel.text = i18n.tr(items['subSound'])

                       EffectFunctions.setMainEffect(items['mainSound']);
                       EffectFunctions.setMainSubEffect(items['subSound']);

                   }

                   onWidthChanged: {

                   }

                   layouts: [
                        ConditionalLayout {
                            name: "wide"
                            when: pageLayout.width > pageLayout.height

                            Item {
                                anchors.fill: parent

                                //make item id's different from the default (add w- for wide)
                                ItemLayout {
                                    item: "metronomeItem"

                                    height: parent.height - units.gu(1)
                                    width: parent.width - wStartItem.width
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                    }


                                }


                                ItemLayout {
                                    id: wExtraTempoItem
                                    item: "extraTempoItem"
                                    width: units.gu(10)
                                    height: units.gu(5)

                                    anchors {
                                        right: parent.right
                                        bottom: wStartItem.top
                                    }
                                }

                                ItemLayout {
                                    item: "tempoItem"
                                    opacity: 0
                                }


                                ItemLayout {
                                    id: wStartItem
                                    item: "startItem"
                                    width: units.gu(10)
                                    height: units.gu(5)

                                    anchors {
                                        right: parent.right
                                        bottom: centerHolder.top
                                    }
                                }


                                Rectangle {
                                    id: centerHolder
                                    anchors {
                                        bottom: wStopItem.top
                                        //verticalCenter: parent.verticalCenter //enable this to center again
                                        right: parent.right
                                    }
                                }

                                ItemLayout {
                                    id: wStopItem
                                    item: "stopItem"
                                    width: units.gu(10)
                                    height: units.gu(5)

                                    anchors {
                                        right: parent.right
                                        //top: centerHolder.bottom
                                        bottom: wBeatItem.top
                                    }
                                }

                                ItemLayout {
                                    id: wBeatItem
                                    item: "beatItem"
                                    width: units.gu(10)
                                    height: units.gu(5)

                                    anchors {
                                        right: parent.right
                                        //top: wStopItem.bottom
                                        bottom: wBeatImgItem.top
                                    }
                                }
                                ItemLayout {
                                    id: wBeatImgItem
                                    item: "beatImgItem"

                                    height: beatImage.height
                                    width: beatImage.width
                                    anchors {
                                        right: parent.right
                                        //top: wBeatItem.bottom
                                        bottom: parent.bottom
                                    }
                                }

                            }
                       },

                       ConditionalLayout {
                           name: "default"
                           when: pageLayout.width <= pageLayout.height && pageLayout.width >= units.gu(31)
                           Item {
                               anchors.fill: parent

                               ItemLayout {
                                   item: "extraTempoItem"
                               }

                               ItemLayout {
                                   id: tempoItem
                                   item: "tempoItem"

                                   height: tempoPickerHeight + units.gu(2)
                                   width: pageLayout.width
                               }

                               ItemLayout {
                                   id: beatImgItem
                                   item: "beatImgItem"

                                   height: tempoPickerHeight + beatImage.height
                                   width: beatImage.width
                                   anchors {
                                       horizontalCenter: parent.horizontalCenter
                                   }
                               }

                               ItemLayout {
                                   id: metronomeItem
                                   item: "metronomeItem"

                                   width: parent.width
                                   height: parent.height - tempoPickerHeight - startItem.height - beatImage.height - units.gu(2)


                                   anchors {
                                       bottom: beatItem.top
                                       margins: units.gu(1)
                                   }
                               }
                               ItemLayout {
                                   id: startItem
                                   item: "startItem"
                                   width: units.gu(10)
                                   height: units.gu(5)
                                   anchors {
                                       //top: metronomeItem.bottom
                                       bottom: parent.bottom
                                       right: beatItem.left
                                       margins: units.gu(1)
                                   }
                               }
                               ItemLayout {
                                   id: beatItem
                                   item: "beatItem"
                                   width: units.gu(10)
                                   height: units.gu(5)
                                   anchors {
                                       horizontalCenter: parent.horizontalCenter
                                       //top: metronomeItem.bottom
                                       bottom: parent.bottom
                                       margins: units.gu(1)
                                   }
                               }
                               ItemLayout {
                                   id: stopItem
                                   item: "stopItem"
                                   width: units.gu(10)
                                   height: units.gu(5)
                                   anchors {
                                       left: beatItem.right
                                       //top: metronomeItem.bottom
                                       bottom: parent.bottom
                                       margins: units.gu(1)
                                   }
                               }
                           }
                       },

                       ConditionalLayout {
                           name: "narrow"
                           when: pageLayout.width < units.gu(31)
                           Item {
                               anchors.fill: parent

                               ItemLayout {
                                   item: "extraTempoItem"
                               }

                               //make item id's different from the default (add n- for narrow)
                               ItemLayout {
                                   id: nTempoItem
                                   item: "tempoItem"

                                   width: pageLayout.width
                                   height: pageLayout.height/2
                                   //height: tempoPicker.height + units.gu(2)
                                   anchors {
                                       top: parent.top
                                   }

                               }
                               ItemLayout {
                                   id: nbeatImgItem
                                   item: "beatImgItem"

                                   height: tempoPickerHeight + beatImage.height
                                   width: beatImage.width
                                   anchors {
                                       horizontalCenter: parent.horizontalCenter
                                   }
                               }
                               ItemLayout {
                                   id: nMetronomeItem
                                   item: "metronomeItem"
                                   height: parent.height - tempoPickerHeight - nStartItem.height - beatImage.height
                                   width: parent.width

                                   anchors {
                                       bottom: nBeatItem.top
                                       //top: nTempoItem.bottom
                                   }
                               }
                               ItemLayout {
                                   id: nStartItem
                                   item: "startItem"
                                   width: parent.width/3
                                   height: units.gu(5)
                                   anchors {
                                       //top: nMetronomeItem.bottom
                                       bottom: parent.bottom
                                       right: nBeatItem.left
                                       //margins: units.gu(1)
                                   }
                               }
                               ItemLayout {
                                   id: nBeatItem
                                   item: "beatItem"
                                   width: parent.width/3
                                   height: units.gu(5)
                                   anchors {
                                       horizontalCenter: parent.horizontalCenter
                                       bottom: parent.bottom
                                       //top: nMetronomeItem.bottom
                                       //margins: units.gu(1)
                                   }
                               }
                               ItemLayout {
                                   id: nStopItem
                                   item: "stopItem"
                                   width: parent.width/3
                                   height: units.gu(5)
                                   anchors {
                                       left: nBeatItem.right
                                       bottom: parent.bottom
                                       //top: nMetronomeItem.bottom
                                       //margins: units.gu(1)
                                   }
                               }
                           }
                       }

                   ]


                   ATempoPicker {
                       id: mainTempoPicker
                       Layouts.item: "tempoItem"

                       onChanged: {
                           timer.bpmCount = bpm; //set timer's bpm to my(ATempoPicker) bpm
                           //console.log(timer.bpmCount)
                       }
                   }




                    Item {
                        id: metronomeSection
                        Layouts.item: "metronomeItem"


                       onWidthChanged: {
                           if (width <= 2*height) {
                               metronomeLine.height = width/2 - units.gu(1)
                           }
                       }
                       onHeightChanged: {
                           if (height <= width/2) {
                               metronomeLine.height = height
                           }
                       }

                       Rectangle {
                           anchors {

                               horizontalCenter: parent.horizontalCenter
                               bottom: parent.bottom
                           }


                           id: metronomeLine
                           color: "black"

                           width: units.gu(1)

                           Component.onCompleted: {
                               if (parent.height <= parent.width/2) {
                                   metronomeLine.height = parent.height
                               }
                               else {
                                   metronomeLine.height = parent.width/2 - units.gu(1)
                               }
                           }

                           transformOrigin: Item.Bottom
                           rotation: 300
                           smooth: true

                           SequentialAnimation {
                               id: rotateAnimation
                               RotationAnimation {
                                   id: rightRotation
                                   target: metronomeLine
                                   duration: timer.interval*timer.subdivisions
                                   direction: RotationAnimation.Shortest
                                   property: "rotation"
                                   from: 300
                                   to: 60
                               }

                               RotationAnimation {
                                   id: leftRotation
                                   target: metronomeLine
                                   duration: timer.interval*timer.subdivisions
                                   direction: RotationAnimation.Shortest
                                   property: "rotation"
                                   from: 60
                                   to: 300
                               }
                           }
                       }

                    }

                   Item {
                       id: beatImageItem
                       Layouts.item: "beatImgItem"
                       height: units.gu(20)
                       //color: "red"

                       MouseArea {
                           height: childrenRect.height
                           width: childrenRect.width

                           anchors {
                               bottom: parent.bottom
                           }

                           Image {
                                id: beatImage
                                anchors {
                                    bottom: parent.bottom
                                }
                                source: "icons/eighth.svg"
                           }

                           onClicked: PopupUtils.open(beatSelector, beatButton)
                       }

                   }

                   //Start
                   Button {
                       id: startButton
                       Layouts.item: "startItem"
                       text: i18n.tr("Start")
                       color: UbuntuColors.orange



                       property int subbeats: 2
                       onClicked: {
                           timer.start()
                       }
                   }


                   // Beat Selection goes here
                   Button {
                       id: beatButton
                       Layouts.item: "beatItem"



                       text: "Eighth"
                       color: UbuntuColors.orange
                       onClicked: PopupUtils.open(beatSelector, beatButton)
                   }


                   //Stop
                   Button {
                       id: stopButton
                       Layouts.item: "stopItem"
                       text: i18n.tr("Stop")
                       color: UbuntuColors.orange



                       onClicked: {
                           timer.stop()
                           timer.num = 0
                           timer.beat = 0
                       }
                   }

                   //extra tempo button for different layouts
                   Button {
                       id: extraTempoButton

                       Layouts.item: "extraTempoItem"
                       text: i18n.tr("Tempo")
                       color: UbuntuColors.orange

                       onClicked: PopupUtils.open(extraTempoSection)
                   }
               }
           }


        }

        Tab {
            title: i18n.tr("Settings")
            page: Page {

                head.actions: [

                    StartToolButton {},
                    MetronomeToolButton {}
                ]


                Layouts {
                    id: settingLayout
                    anchors.fill: parent

                    layouts: [
                         ConditionalLayout {
                             name: "wide"
                             when: settingLayout.width > settingLayout.height

                             Item {
                                 anchors.fill: parent

                                 ItemLayout {
                                     id: wMainSettingItem
                                     item: "mainSettingItem"
                                     height: mainSetting.childrenRect.height
                                     width: settingLayout.width/2

                                     anchors {
                                         right: wSeparator.left
                                     }

                                 }

                                 //separator
                                 Rectangle {
                                     id: wSeparator
                                     anchors{
                                         horizontalCenter: parent.horizontalCenter
                                         margins: units.gu(2)
                                     }

                                     height: parent.height - saveDefaultButton.height
                                     width: 1
                                     color: "grey"

                                 }

                                 ItemLayout {
                                     id: wSubSettingItem
                                     item: "subSettingItem"
                                     height: subSetting.childrenRect.height
                                     width: settingLayout.width/2

                                     anchors {
                                         left: wSeparator.right
                                     }
                                 }

                                 ItemLayout {
                                     item: "defaultButtonItem"
                                     height: saveDefaultButton.height
                                     width: saveDefaultButton.width

                                     anchors {
                                         bottom: parent.bottom
                                         horizontalCenter: parent.horizontalCenter
                                     }
                                 }
                             }
                         },
                         ConditionalLayout {
                            name: "default"
                            when: pageLayout.width <= pageLayout.height

                            Item {
                                anchors.fill: parent


                                ItemLayout {
                                    id: mainSettingItem
                                    item: "mainSettingItem"
                                    height: mainSetting.height
                                    width: parent.width

                                }

                                //separator
                                Rectangle {
                                    id: separator
                                    anchors{
                                        top: mainSettingItem.bottom
                                        margins: units.gu(2)
                                    }

                                    height: 1
                                    width: pageLayout.width
                                    color: "grey"

                                }

                                ItemLayout {
                                    id: subSettingItem
                                    item: "subSettingItem"
                                    height: subSetting.childrenRect.height
                                    width: parent.width

                                    anchors {
                                        top: separator.bottom
                                    }
                                }

                                ItemLayout {
                                    item: "defaultButtonItem"
                                    height: saveDefaultButton.height
                                    width: saveDefaultButton.width

                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                         }
                   ]





                    Item {
                        id: mainSetting
                        Layouts.item: "mainSettingItem"

                        height: childrenRect.height
                        anchors {
                            left: parent.left
                            right: parent.right
                        }


                        //title label
                        Label {
                            id: mainTitleLabel
                            text: i18n.tr("Main beat")
                            fontSize: "large"
                        }

                        //info
                        Label {
                            id: mainInfo
                            anchors {
                                top: mainTitleLabel.bottom
                                horizontalCenter: mainBeatSlider.horizontalCenter
                            }
                            text: i18n.tr("Volume")
                            fontSize: "medium"
                        }


                        //slider stuff
                        Label {
                            id: minusLabel
                            anchors {
                                left: parent.left
                                top: mainBeatSlider.top
                            }
                            text: " - "
                            fontSize: "large"
                        }
                        Slider {
                            id: mainBeatSlider

                            anchors {
                                left: minusLabel.right
                                right: plusLabel.left
                                top: mainInfo.bottom
                            }

                            minimumValue: 0.25
                            maximumValue: 1.0
                            value: 0.75
                            live: true

                            function formatValue(v) {
                                v *= 100
                                v = Math.round(v)
                                v /= 100
                                return v;
                            }

                            onValueChanged: {
                                EffectFunctions.adjustVolume(value)
                                var vol = EffectFunctions.getVolume();
                                EffectFunctions.getMainEffect().volume = vol;



                            }
                        }
                        Label {
                            id: plusLabel
                            anchors {
                                right: parent.right
                                top: mainBeatSlider.top
                            }
                            text: " + "
                            fontSize: "large"
                        }




                        //beat button
                        Button {
                            id: mainBeatButton
                            iconSource: "icons/noteIcon.svg"
                            color: UbuntuColors.orange
                            width: units.gu(5)

                            anchors {
                                top: mainBeatSlider.bottom
                            }

                            property string input: ""
                            onClicked: PopupUtils.open(soundSelector, mainBeatButton)
                            onInputChanged: {
                                mainBeatLabel.text = i18n.tr(input);
                                EffectFunctions.setMainEffect(input);

                                var vol = EffectFunctions.getVolume();
                                EffectFunctions.getMainEffect().volume = vol;
                            }
                        }
                        //beat info
                        Label {
                            id: mainBeatLabel
                            anchors {
                                left: mainBeatButton.right
                                leftMargin: units.gu(1)
                                verticalCenter: mainBeatButton.verticalCenter
                            }

                            text: ""
                            fontSize: "medium"
                        }
                    }

                    //separator
                    Rectangle {
                        id: separator

                        Layouts.item: "separatorItem"
                        anchors{
                            top: mainSetting.bottom
                            left: parent.left
                            right: parent.right
                        }

                        height: 1

                        color: "grey"

                    }


                    Item {
                        id: subSetting
                        Layouts.item: "subSettingItem"

                        height: childrenRect.height
                        anchors {
                            top: separator.bottom
                            left: parent.left
                            right: parent.right
                            topMargin: units.gu(1)
                        }


                        //title label
                        Label {
                            id: subTitleLabel

                            text: i18n.tr("Sub beat")
                            fontSize: "large"
                        }


                        //slider info
                        Label {
                            id: subInfo
                            anchors {
                                top: subTitleLabel.bottom
                                horizontalCenter: subBeatSlider.horizontalCenter
                            }
                            text: i18n.tr("Volume")
                            fontSize: "medium"
                        }

                        //slider stuff
                        Label {
                            id: subMinusLabel
                            anchors {
                                left: parent.left
                                top: subBeatSlider.top
                            }
                            text: " - "
                            fontSize: "large"
                        }
                        Slider {
                            id: subBeatSlider

                            anchors {
                                top: subInfo.bottom
                                left: subMinusLabel.right
                                right: subPlusLabel.left
                                //horizontalCenter: parent.horizontalCenter
                            }

                            minimumValue: 0.25
                            maximumValue: 1.0
                            value: 0.75
                            live: true
                            function formatValue(v) {
                                v *= 100
                                v = Math.round(v)
                                v /= 100
                                return v;
                            }

                            onValueChanged: {
                                EffectFunctions.adjustSubVolume(value);
                                var vol = EffectFunctions.getSubVolume();
                                EffectFunctions.getMainSubEffect().volume = vol;
                            }
                        }
                        Label {
                            id: subPlusLabel
                            anchors {

                                right: parent.right
                                top: subBeatSlider.top
                            }
                            text: " + "
                            fontSize: "large"
                        }


                        //beat button
                        Button {
                            id: subBeatButton

                            anchors {
                                top: subBeatSlider.bottom
                                left: parent.left
                            }

                            iconSource: "icons/noteIcon.svg"
                            color: UbuntuColors.orange
                            width: units.gu(5)
                            property string input: ""
                            onClicked: PopupUtils.open(soundSelector, subBeatButton)
                            onInputChanged: {
                                subBeatLabel.text = i18n.tr(input);
                                EffectFunctions.setMainSubEffect(input);

                                var vol = EffectFunctions.getSubVolume();
                                EffectFunctions.getMainSubEffect().volume = vol;
                            }

                        }

                        //beat info
                        Label {
                            id: subBeatLabel
                            anchors {
                                left: subBeatButton.right
                                leftMargin: units.gu(1)
                                verticalCenter: subBeatButton.verticalCenter
                            }
                            text: ""
                            fontSize: "medium"
                        }

                    }

                    Button {
                        id: saveDefaultButton
                        Layouts.item: "defaultButtonItem"
                        text: i18n.tr("Save Current Settings")
                        color: UbuntuColors.orange

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        onClicked: {
                            DbFunctions.saveSettings()
                            PopupUtils.open(dialog)
                        }
                    }
                }
            }
        }
    }
}
