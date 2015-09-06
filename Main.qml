import QtQuick 2.2
import QtQuick.LocalStorage 2.0 as Sql
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.Pickers 1.0
import QtMultimedia 5.0
import Ubuntu.Layouts 1.0
import "ui"
import "components"
import "components/dbFunctions.js" as DbFunctions
import "components/effectFunctions.js" as EffectFunctions

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

    useDeprecatedToolbar: false // do not use the old toolbar, use the new header!

    anchorToKeyboard: true


    width: units.gu(50)
    height: units.gu(75)

    // -------------------- BUTTON COLORS ------------------------
    property string positiveColor: "#3fb24f" //green
    property string primaryColor: "#dd4814" //orange
    property string negativeColor: "#fc4949" //red


    property int tempoPickerHeight: units.gu(20)

    property variant beatPattern: ["main", "sub"];      // used to play specific patterns


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

        beatPattern[0] = "main";                        // The first beat should be a main beat

        // insert sub beats
        for (var i=1; i < numOfBeats; i++) {            // set the rest of the indices as sub beats, we will insert main beats or silent beats later
            beatPattern[i] = "sub";                     // set that index as a sub beat
        }

        // insert main beats based on pattern
        for (var i=0; i < pattern.length; i++) {
            var index;
            index = parseInt(pattern.charAt(i));        // get the index
            beatPattern[index] = "main"                 // set that index as a main beat
        }

        // insert silent beats based on pattern
        for (var i=0; i < silentPattern.length; i++) {
            var index;
            index = parseInt(silentPattern.charAt(i));  // get the index
            beatPattern[index] = "silent"               // set that index as a silent beat
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


        if (beatPattern[index] == "main") {     // play main beat if we are supposed to
            playMainSound();
        }
        else if (beatPattern[index] == "sub") { // play sub beat if we are supposed to
            playSubSound();
        }
        // else do nothing "silent"             // we are done!


        timer.num = (index + 1) % numOfBeats        // increment the index for the beat that I am on
    }



    function calculateBpm(ms) {                 // calculates the beats per minute based on the interval of ms (useful for the tempoFinder)
        var bpm = 60000/ms
        return bpm
    }


    // --------------------------------------------------------- LIST OF BEATS ----------------------------------------------
    // list of all the types of beats
    ListModel {
        id: beats
        /*
          name      // primary name of beat
          number    // how many beats are in the measure
          tempoDiv  // how to divide the time
          pattern   // pattern for irregular beats
          silentpattern // pattern for silent beats
          img       // image name for beat
          type      // category of the beat

        */

        ListElement {
            name: "Quarter"
            number: 1
            tempoDiv: 1
            pattern: ""
            silentPattern: ""
            img: "quarter.svg"
            type: "Typical Beats"
        }
        ListElement {
            name: "Eighth"
            number: 2
            tempoDiv: 2
            pattern: ""
            silentPattern: ""
            img: "eighth.svg"
            type: "Typical Beats"
        }
        ListElement {
            name: "Triplet"
            number: 3
            tempoDiv: 3
            pattern: ""
            silentPattern: ""
            img: "triplet.svg"
            type: "Typical Beats"
        }
        ListElement {
            name: "Triplet (Fall)"
            number: 3
            tempoDiv: 3
            pattern: ""
            silentPattern: "1"
            img: "fallTriplet.svg"
            type: "Typical Beats"
        }
        ListElement {
            name: "Triplet (Rise)"
            number: 3
            tempoDiv: 3
            pattern: ""
            silentPattern: "2"
            img: "riseTriplet.svg"
            type: "Typical Beats"
        }

        ListElement {
            name: "Sixteenth"
            number: 4
            tempoDiv: 4
            pattern: ""
            silentPattern: ""
            img: "sixteenth.svg"
            type: "Typical Beats"
        }
        ListElement {
            name: "Sixteenth (And A)"
            number: 4
            tempoDiv: 4
            pattern: ""
            silentPattern: "1"
            img: "sixteenthAndA.svg"
            type: "Typical Beats"
        }
        ListElement {
            name: "Dotted Eighth"
            number: 4
            tempoDiv: 4
            pattern: ""
            silentPattern: "12"
            img: "dottedEighth.svg"
            type: "Typical Beats"
        }

        ListElement {
            name: "Dotted Eighth (Rise)"
            number: 4
            tempoDiv: 4
            pattern: ""
            silentPattern: "23"
            img: "dottedEighthRise.svg"
            type: "Uncommon Beats"
        }
        ListElement {
            name: "Sixteenth (E And)"
            number: 4
            tempoDiv: 4
            pattern: ""
            silentPattern: "3"
            img: "sixteenthEAnd.svg"
            type: "Uncommon Beats"
        }
        ListElement {
            name: "Sixteenth (E A)"
            number: 4
            tempoDiv: 4
            pattern: ""
            silentPattern: "2"
            img: "sixteenthEA.svg"
            type: "Uncommon Beats"
        }
        ListElement {
            name: "Sixtuplet"
            number: 6
            tempoDiv: 6
            pattern: ""
            silentPattern: ""
            img: "sixtuplet.svg"
            type: "Uncommon Beats"
        }
        ListElement {
            name: "4/4 Quarter"
            number: 4
            tempoDiv: 1
            pattern: ""
            silentPattern: ""
            img: "44quarter.svg"
            type: "Common Measures"
        }
        ListElement {
            name: "3/4 Quarter"
            number: 3
            tempoDiv: 1
            pattern: ""
            silentPattern: ""
            img: "34quarter.svg"
            type: "Common Measures"
        }
        ListElement {
            name: "2/2 Cut Time"
            number: 2
            tempoDiv: 1
            pattern: ""
            silentPattern: ""
            img: "cutTime.svg"
            type: "Common Measures"
        }
        ListElement {
            name: "5/8 (3-2)"
            number: 5
            tempoDiv: 2
            pattern: "3"
            silentPattern: ""
            img: "32.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "5/8 (2-3)"
            number: 5   //number of beats in the measure
            tempoDiv: 2 //number to divide by to calc tempo
            pattern: "2"
            silentPattern: ""
            img: "23.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "7/8 (3-2-2)"
            number: 7
            tempoDiv: 2
            pattern: "35" // 3-5 --> beat 3 & 5
            silentPattern: ""
            img: "322.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "7/8 (2-3-2)"
            number: 7
            tempoDiv: 2
            pattern: "25"
            silentPattern: ""
            img: "232.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "7/8 (2-2-3)"
            number: 7
            tempoDiv: 2
            pattern: "24"
            silentPattern: ""
            img: "223.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "8/8 (3-3-2)"
            number: 8
            tempoDiv: 2
            pattern: "36"
            silentPattern: ""
            img: "332.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "8/8 (3-2-3)"
            number: 8
            tempoDiv: 2
            pattern: "35"
            silentPattern: ""
            img: "323.svg"
            type: "Irregular Beats"
        }
        ListElement {
            name: "8/8 (2-3-3)"
            number: 8
            tempoDiv: 2
            pattern: "25"
            silentPattern: ""
            img: "233.svg"
            type: "Irregular Beats"
        }
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
    Timer {
        id: timer
        interval: 500
        repeat: true
        running: false
        triggeredOnStart: false             // do not start automatically
        property int num: 0
        property int beat: 0
        property int subdivisions: 2
        property int tempoDivisions: 2      // divisions for calculating the tempo
        property int bpmCount: 120
        property string pattern: ""
        property string silentPattern: ""


        onTriggered: {                      // when the timer activates play a sound
            playBeat(num, subdivisions);
        }

        onPatternChanged: {
            buildBeatPattern(subdivisions, pattern, silentPattern); // update the beat pattern
        }
        onSilentPatternChanged: {
            buildBeatPattern(subdivisions, pattern, silentPattern); // update the beat pattern
        }


        function str2NumArray(str) {        // internal function; converts a string to an array of numbers
                                            // ex. "2348" --> [2, 3, 4, 8]
            var array = [];
            for (var i=0; i < str.length; i++) {
                array[i] = parseInt(str.charAt(i));
            }
            return array;
        }

        Component.onCompleted: {
            tempoUpdate();
        }
        onSubdivisionsChanged: {
            tempoUpdate();
            buildBeatPattern(subdivisions, pattern, silentPattern);
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

    // ------------------------------------------- BEAT SELECTOR ---------------------------------------------
    Component {
         id: beatSelector
         Popover {      // popover to select beat
             id: popover
             Column {
                 height: pageLayout.height

                 anchors {
                     top: parent.top
                     left: parent.left
                     right: parent.right
                 }

                 Header {       // Title of the beat selector
                     id: header
                     text: i18n.tr("Choose from beat selection")
                 }

                 ListView {     // List all the beats
                     height: pageLayout.height - header.height
                     width: parent.width

                     section.property: "type"
                     section.delegate: Rectangle {
                         width: parent.width

                         height: units.gu(1)

                         Text {
                             text: section      // get the section name
                             font.bold: true
                         }
                     }

                     model: beats               // fill the ListView with the beats
                     delegate: Standard {       // with each beat, use a Standard item
                         text: name             // display the name of the beat
                         onClicked: {           // Do this when the name is clicked
                             beatButton.text = i18n.tr(name)    // update the name of the button
                             timer.subdivisions = number        // update the properties of the timer
                             timer.num = 0
                             timer.pattern = pattern
                             timer.silentPattern = silentPattern
                             timer.tempoDivisions = tempoDiv
                             beatImage.source = "icons/" + img  // update the image of the beat
                             hide()             // I am done with the beat selector, so hide it
                         }
                     }
                 }
             }
         }
    }

    // ---------------------------------------- SOUND SELECTOR ------------------------------------------
    // for selecting the sound for the main beat and sub beat

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

                 Header {           // Title for the sound selector
                     id: header
                     text: i18n.tr("Choose from sound selection")
                 }

                 ListView {
                     height: pageLayout.height - header.height - okButton.height
                     width: parent.width

                     model: soundFiles
                     delegate: Standard {
                         text: i18n.tr(name)        // display the name of the sound
                         onClicked: {
                             caller.input = file    // update the sound

                             if(!timer.running) {   // if the metronome is not playing, play a sample sound
                                 var theEffect = EffectFunctions.getEffect(file)
                                 theEffect.play()
                             }
                         }
                     }
                 }
                 Button {           // Okay button to hide the sound selector
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


    // ------------------------------------------------ SAVE SETTINGS DIALOG ---------------------------------------------------
    // popup that display when the "save settings" button is clicked
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Confirmation")
            text: i18n.tr("Your settings have been saved!")
            Button {
                text: i18n.tr("Ok")
                color: positiveColor
                onClicked: PopupUtils.close(dialogue)   // close the dialog when the user clicks Ok
            }
        }
    }


    // ------------------------------------------------- TEMPO SELECTION FOR WIDE VIEW -------------------------------------------
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
                PopupUtils.close(tempoSheet)
            }
        }
    }

    // --------------------------------------------------- TEMPO FINDER ------------------------------------------------------
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
                        color: primaryColor
                        property int altValue: 0    // used to alternate the Text of the "Press" button
                        property double timeOne: 0  // used to calculate the bpm by using the difference between timeOne and timeTwo
                        property double timeTwo: 0
                        onClicked: {
                            altValue += 1           // alternate value
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
                    Label {     // displays the tempo from the two clicks
                        id: tempoFinderTempo
                        text: i18n.tr("0")
                        fontSize: "large"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {     // displays "bpm" next to the tempo
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
                        color: primaryColor
                        onClicked: PopupUtils.close(tempoFinderDialog)
                    }
                    Button {
                        id: acceptTempoButton
                        text: i18n.tr("Use This Tempo")
                        color: primaryColor


                        onClicked: {
                            //set the tempo
                            var tempo = tempoFinderTempo.text*1;
                            if (tempo >= 30 && tempo <= 240) {
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
                           ]

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
                       color: primaryColor



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
                            color: primaryColor
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
                            color: primaryColor
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
                        color: primaryColor

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
