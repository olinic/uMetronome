var soundList = ["bockie.wav","clank.wav","dut.wav","ping.wav","plop.wav","pong.wav","pop.wav","tick.wav","tock.wav"];
var effectArray = [];
var volume;
var subVolume;
var mainEffect;
var mainSubEffect;

function setupSoundModel() {

    for (var i=0; i < soundList.length; i++) {
        var filename = soundList[i];
        var name = rmExt(filename);
        soundFiles.append({name: name, file: filename})
    }

}

function rmExt(file) {
    var periodIndex = file.indexOf(".");
    var filename = file.substring(0, periodIndex);
    return filename;
}

function setupSoundEffects() {

    for (var i=0; i < soundList.length; i++) {
        var filename = soundList[i];

        var qmlStr = "import QtMultimedia 5.0; SoundEffect { source: \"./sounds/" + soundList[i] + "\"; volume: 1;}";
        var effect = Qt.createQmlObject(qmlStr, mainView, "SoundEffect" + i);
        effectArray[i] = effect;

        volume = mainBeatSlider.value;
        subVolume = subBeatSlider.value;
    }

}

function getEffect(sound) {
    var index = soundList.indexOf(sound);
    return effectArray[index];
}

function adjustVolume(level) {
    volume = level;

}

function adjustSubVolume(level) {
    subVolume = level;
}

function getVolume() {
    return volume;
}

function getSubVolume() {
    return subVolume;
}

function setMainEffect(sound) {
    mainEffect = soundList.indexOf(sound);
}

function setMainSubEffect(sound) {
    mainSubEffect = soundList.indexOf(sound);
}

function getMainEffect() {
    return effectArray[mainEffect];
}

function getMainSubEffect() {
    return effectArray[mainSubEffect];
}

function effectsAreSame() {
    return mainEffect == mainSubEffect;
}
