import QtQuick 2.2
import UMetronome 1.0                   // import C++ classes
import QtQuick.LocalStorage 2.0 as Sql  // import database
import Ubuntu.Components 1.2            // bunch of components
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0     // dialogs, popovers, etc
import Ubuntu.Components.Pickers 1.0    // picker for tempo
import QtMultimedia 5.0                 // sound
import Ubuntu.Layouts 1.0               // conditional layout
import "./dbFunctions.js" as DbFunctions            // handling database
import "./effectFunctions.js" as EffectFunctions    // handling sound effects

/*
   *Copyright 2014 by Oliver Nichols
   *Released under the GNU General Public License version 3
*/


MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "umetronome.otter"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    //useDeprecatedToolbar: false // do not use the old toolbar, use the new header!

    anchorToKeyboard: true


    width: units.gu(50)
    height: units.gu(75)

    // -------------------- BUTTON COLORS ------------------------
    property string positiveColor: "#3fb24f" //green
    property string primaryColor: "#dd4814" //orange
    property string negativeColor: "#fc4949" //red

    property string picPath: "icons/";

    // ------------------- ENUMERATIONS --------------------------
    property int main: 1;
    property int sub: 2;
    property int silent: 3;


    property int tempoPickerHeight: units.gu(20)

    property variant beatPattern: [main, sub];      // used to play specific patterns


    // ---------------------------------------------------- SOUND FUNCTIONS --------------------------------------------------------
    function calcInterval(bpm, subdivisions) { // calculates the time in ms between each beat and sub-beat
        var interval = 60000/bpm                // beats per minute
        interval = interval/subdivisions        // divide to include sub-beats
        return interval
    }

    function playMainSound() {
        var effect = EffectFunctions.getMainEffect();   // get the main sound effect
        if (EffectFunctions.effectsAreSame()) {         // if the main sound and sub sound are using the same sound effect, adjust the volume to the main volume
            var vol = EffectFunctions.getVolume();      // get the main volume
            effect.volume = vol;                        // set the volume
        }
        effect.play();                      // play the sound
    }

    function playSubSound() {
        var subEffect = EffectFunctions.getMainSubEffect();
        if (EffectFunctions.effectsAreSame()) {
            var vol = EffectFunctions.getSubVolume();
            subEffect.volume = vol;
        }

        subEffect.play()
    }

    function buildBeatPattern(numOfBeats, pattern, silentPattern) {
        beatPattern.splice(numOfBeats, 7);                 // reduces the array to the length of number of beats

        beatPattern[0] = main;                        // The first beat should be a main beat

        // insert sub beats
        for (var i=1; i < numOfBeats; i++) {            // set the rest of the indices as sub beats, we will insert main beats or silent beats later
            beatPattern[i] = sub;                     // set that index as a sub beat
        }

        // insert main beats based on pattern
        for (var i=0; i < pattern.length; i++) {
            var index;
            index = parseInt(pattern.charAt(i));        // get the index
            beatPattern[index] = main;                 // set that index as a main beat
        }

        // insert silent beats based on pattern
        for (var i=0; i < silentPattern.length; i++) {
            var index;
            index = parseInt(silentPattern.charAt(i));  // get the index
            beatPattern[index] = silent;               // set that index as a silent beat
        }

        /*console.log(pattern);                         // debugging
        console.log(silentPattern);
        console.log(beatPattern);*/
    }

    function playBeat(index, numOfBeats) {
        if(index%numOfBeats == 0) { // first beat

            if(timer.beat == 0) {
                metronomeLine.state = ""        // cannot remember the purpose of this line, but it makes the state changes work
                metronomeLine.state = "rotate"  // start the rotation
                timer.beat = 1                  // prevents activating the clockwise rotation when the needle reaches the right side, the rotation will automatically bring it back
            }
            else {
                timer.beat = 0                  // Needle is on the right now, change the value to 0 so that the rotation is activated when it hits the left side.
            }
        }


        if (beatPattern[index] == main) {       // play main beat if we are supposed to
            playMainSound();
        }
        else if (beatPattern[index] == sub) {   // play sub beat if we are supposed to
            playSubSound();
        }
        // else do nothing "silent"             // we are done!


        timer.num = (index + 1) % numOfBeats    // increment the index for the beat that I am on
    }



    function calculateBpm(ms) {                 // calculates the beats per minute based on the interval of ms (useful for the tempoFinder)
        var bpm = 60000/ms
        return bpm
    }


    Beats {
        id: beats;
    }


    // ------------------------------------------------------ SETUP SOUND EFFECTS -----------------------------------------
    // Creates sound effects for all the sounds
    ListModel {
        id: soundFiles

        Component.onCompleted: {
            // go into the EffectFunctions inside the Components Folder and setup all the sound effects
            EffectFunctions.setupSoundModel();
            EffectFunctions.setupSoundEffects();

            EffectFunctions.adjustVolume(mainBeatSlider.value)          // get the main volume
            EffectFunctions.adjustSubVolume(subBeatSlider.value)        // get the sub volume


            EffectFunctions.getMainEffect().volume = EffectFunctions.getVolume();       // set the volume of the main effect
            EffectFunctions.getMainSubEffect().volume = EffectFunctions.getSubVolume(); // set the volume of the sub effect
        }
    }

    // ---------------------------------------------------- TIMER ----------------------------------------------------------
    // Timer handles all of the timing of beats
    UTimer {                                // C++ class with increased precision
        id: timer
        interval: 500
        singleShot: false
        property bool running: false;       // do not depend on active for notifications, use this
        property int num: 0                 // num for the current beat (same as the common use for i)
        property int beat: 0                // used for controlling the state of uMetronome (state is used for the rotation of the needle)
        property int subdivisions: 2        // how many beats are in the measure (corresponds to number in the list of beats)
        property int tempoDivisions: 2      // divisions for calculating the tempo
        property int bpmCount: 140          // bpm
        property string pattern: ""
        property string silentPattern: ""


        onTimeout: {                      // when the timer activates play a sound
            playBeat(num, subdivisions);
        }

        onPatternChanged: {
            buildBeatPattern(subdivisions, pattern, silentPattern); // update the beat pattern
        }
        onSilentPatternChanged: {
            buildBeatPattern(subdivisions, pattern, silentPattern); // update the beat pattern
        }


        function play() {
            start();
            running = true;
        }

        function pause() {
            stop();
            running = false;
            num = 0
            beat = 0
        }

        function str2NumArray(str) {        // internal function; converts a string to an array of numbers
                                            // ex. "2348" --> [2, 3, 4, 8]
            var array = [];
            for (var i=0; i < str.length; i++) {
                array[i] = parseInt(str.charAt(i));
            }
            return array;
        }

        Component.onCompleted: {            // do this on startup
            // get stuff from database
            var items = DbFunctions.getDbItems();
            subdivisions = items['numBeats'];
            tempoDivisions = items['tempoDiv'];
            bpmCount = items['tempo'];
            pattern = items['pattern'];
            silentPattern = items['silentPattern'];
            mainTempoPicker.getUpdate();

            tempoUpdate();
        }

        // update when a change is made
        onSubdivisionsChanged: {
            tempoUpdate();
            buildBeatPattern(subdivisions, pattern, silentPattern);
        }
        onTempoDivisionsChanged: {
            tempoUpdate();
        }
        onBpmCountChanged: {
            tempoUpdate();

            // update database
            DbFunctions.saveTempo(bpmCount);
        }

        // define how to update the tempo
        function tempoUpdate() {
            interval = calcInterval(bpmCount, tempoDivisions)

            // how fast the needle should move
            leftRotation.duration = interval*(subdivisions)
            rightRotation.duration = interval*(subdivisions)
        }
    }

    BeatSelector {
        id: beatSelector;
    }

    // ---------------------------------------- SOUND SELECTOR ------------------------------------------
    // for selecting the sound for the main beat and sub beat

    Component {
         id: soundSelector


         Popover {
             id: soundPopover
             Column {
                 height: pageLayout.height  // fill the height of the page
                 width: 200
                 anchors {
                     top: parent.top
                     left: parent.left
                     right: parent.right
                 }

                 PopoverHeader {
                     id: sHeader;
                     text: "Choose from sound selection";
                     width: parent.width;
                 }

                 ListView {
                     height: pageLayout.height - sHeader.height - okButton.height
                     width: parent.width

                     model: soundFiles              // populate the list with the sounds

                     clip: true;

                     delegate: Standard {           // use a Standard to display each sound
                         text: i18n.tr(name)        // display the name of the sound

                         onClicked: {
                             caller.input = file    // update the sound

                             if(!timer.active) {   // if the metronome is not playing, play a sample sound
                                 var theEffect = EffectFunctions.getEffect(file)

                                 // get volume of effect based on selector (main or sub)
                                 var playVol = 1;
                                 var setBack = false;       // do we need to set the volume back? we do not want to change the other effect's volume to mess it up
                                 var setBackVol = 1;

                                 if (caller.type == main) {
                                     playVol = EffectFunctions.getVolume();
                                     if (EffectFunctions.getMainSubEffect() == theEffect) {
                                         setBack = true;
                                         setBackVol = EffectFunctions.getSubVolume();
                                     }
                                 } else if (caller.type == sub) {
                                     playVol = EffectFunctions.getSubVolume();
                                     if (EffectFunctions.getMainEffect() == theEffect) {
                                         setBack = true;
                                         setBackVol = EffectFunctions.getVolume();
                                     }
                                 }

                                 theEffect.volume = playVol;          // volume to play at
                                 theEffect.play()

                                 if (setBack) {
                                     theEffect.volume = setBackVol;
                                 }

                             }
                         }
                     }
                 }
                 Button {                           // Okay button to close the sound selector
                     id: okButton
                     text: i18n.tr("Ok")
                     color: positiveColor
                     onClicked: {
                         hide()
                     }
                 }
             }
         }
    }

    SaveSettingsDialog {
        id: dialog;
    }


    TempoDialog {
        id: extraTempoSection
    }

    TempoFinder {
        id: tempoFinder;
    }

    // -------------------------------------------------------- TABS THAT DISPLAY CONTENT --------------------------------------------------
    //These are the tabs to be displayed
    Tabs {
        id: tabs

        //Metronome Tab
        Tab {
            title: i18n.tr("uMetronome")

            page: Page {
               id: metronomePage

               head.actions: [      // add buttons to the header
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


                   layouts: [
                        ConditionalLayout {
                            name: "wide"
                            when: pageLayout.width > pageLayout.height*1.3

                            Item {
                                anchors.fill: parent

                                //make item id's different from the default (add w- for wide)
                                ItemLayout {
                                    item: "metronomeItem"

                                    height: parent.height - units.gu(1)
                                    width: parent.width - wBeatImgItem.width;
                                    anchors {
                                        left: parent.left
                                        top: parent.top
                                    }
                                }


                                ItemLayout {
                                    id: wExtraTempoItem
                                    item: "extraTempoItem"
                                    width: wBeatImgItem.width;
                                    height: units.gu(5)

                                    anchors {
                                        right: parent.right
                                        bottom: wBeatImgItem.top
                                    }
                                }

                                ItemLayout {    // the tempo item needs to exist in this conditional layout even though it is invisible,
                                                // otherwise it will be gone when we switch to the other layout
                                    item: "tempoItem"
                                    opacity: 0
                                }


                                ItemLayout {
                                    id: wStartItem
                                    item: "startItem"
                                    width: wBeatImgItem.width;
                                    height: units.gu(5)

                                    anchors {
                                        horizontalCenter: wExtraTempoItem.horizontalCenter;
                                        bottom: wExtraTempoItem.top
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
                           when: pageLayout.width <= pageLayout.height*1.3
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
                                       bottom: startItem.top
                                       margins: units.gu(1)
                                   }
                               }
                               ItemLayout {
                                   id: startItem
                                   item: "startItem"
                                   width: beatImgItem.width;
                                   height: units.gu(5)
                                   anchors {
                                       //top: metronomeItem.bottom
                                       bottom: parent.bottom
                                       horizontalCenter: parent.horizontalCenter;
                                       margins: units.gu(1)
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
                               metronomeLine.height = width/2;
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
                                   metronomeLine.height = parent.width/2;
                               }
                           }

                           transformOrigin: Item.Bottom
                           rotation: 300
                           smooth: true

                           states: [
                               State {
                                   name: "rotate"
                                   PropertyChanges {
                                       target: metronomeLine
                                   }
                               }
                           ]


                           transitions: [
                               Transition {
                                   to: "rotate"
                                   SequentialAnimation {

                                       RotationAnimation {
                                           id: rightRotation
                                           target: metronomeLine
                                           duration: timer.interval*(timer.subdivisions)
                                           direction: RotationAnimation.Shortest
                                           property: "rotation"
                                           from: 300
                                           to: 60
                                       }


                                       RotationAnimation {
                                           id: leftRotation
                                           target: metronomeLine
                                           duration: timer.interval*(timer.subdivisions - 1)
                                           direction: RotationAnimation.Shortest
                                           property: "rotation"
                                           from: 60
                                           to: 300
                                       }

                                   }
                              }
                           ]

                       }

                    }

                   Item {
                       id: beatImageItem
                       Layouts.item: "beatImgItem"
                       height: units.gu(20)
                       //color: "red"

                       MouseArea {
                           height: beatImage.height
                           width: beatImage.width

                           anchors {
                               bottom: parent.bottom
                           }



                           UbuntuShape {
                                id: ubeatImage
                                anchors {
                                    bottom: parent.bottom
                                }
                                width: beatImage.width;
                                height: beatImage.height;

                                backgroundColor: "#F0DDDD";

                                source: Image {
                                    id: beatImage
                                    source: picPath + "eighth.svg"

                                    Component.onCompleted: {
                                        var items = DbFunctions.getDbItems();
                                        source = picPath + items['beatImage'];
                                    }
                                }
                           }

                           onClicked: PopupUtils.open(beatSelector, beatButton)
                       }

                   }

                   //Start
                   UbuntuShape {
                       id: startButton
                       Layouts.item: "startItem"
                       backgroundColor: "#F0DDDD"

                       sourceFillMode: UbuntuShape.PreserveAspectFit;


                       source: Image {
                           id: startImg
                           source: startButton.playSrc;

                       }

                       property string playSrc: picPath + "play.svg";
                       property string stopSrc: picPath + "stop.svg";
                       property bool playing: timer.running;
                       property int subbeats: 2

                       MouseArea {
                           anchors.fill: parent;

                           onClicked: {
                               if (startButton.playing) {
                                   // stop
                                   timer.pause();
                               } else {
                                   timer.play()
                               }
                           }
                       }



                       onPlayingChanged: {
                           if (playing) {
                               // give option to stop
                               startImg.source = stopSrc;
                           } else {
                               // give option to play
                               startImg.source = playSrc;
                           }
                       }

                   }




                   // Beat Selection goes here
                   Button {
                       id: beatButton
                       Layouts.item: "beatItem"



                       text: "Eighth"
                       color: primaryColor
                       onClicked: PopupUtils.open(beatSelector, beatButton)
                   }


                   //Stop
                   Button {
                       id: stopButton
                       Layouts.item: "stopItem"
                       text: i18n.tr("Stop")
                       color: primaryColor



                       onClicked: {
                           timer.pause()

                       }
                   }

                   //extra tempo button for different layouts
                   Button {
                       id: extraTempoButton

                       Layouts.item: "extraTempoItem"
                       text: i18n.tr("Tempo")
                       color: primaryColor

                       onClicked: PopupUtils.open(extraTempoSection)
                   }
               }
           }


        }

        Tab {
            title: i18n.tr("Settings")
            page: Page {

                head.actions: [
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
                            iconSource: picPath + "noteIcon.svg"
                            color: primaryColor
                            width: units.gu(5)

                            anchors {
                                top: mainBeatSlider.bottom
                            }

                            property int type: main;
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

                            iconSource: picPath + "noteIcon.svg"
                            color: primaryColor
                            width: units.gu(5)

                            property int type: sub;
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
                        color: primaryColor

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        onClicked: {
                            DbFunctions.saveSettings(mainBeatSlider.value, mainBeatLabel.text, subBeatSlider.value, subBeatLabel.text)
                            PopupUtils.open(dialog)
                        }
                    }
                }
            }
        }
    }
}
