function getDatabase() {
    var db =  Sql.LocalStorage.openDatabaseSync("uMetronomeSettings", "1.0", "User settings for the uMetronome App", 1536);

    //create table
    db.transaction(
        function(tx) {
             // Sound Settings
             var query ="CREATE TABLE IF NOT EXISTS Settings(mainVolume INTEGER, mainSound TEXT, subVolume INTEGER, subSound TEXT)";
             tx.executeSql(query);

             // Time Signature
             query ="CREATE TABLE IF NOT EXISTS TimeSignature(numBeats INTEGER, tempoDiv INTEGER, pattern TEXT, silentPattern TEXT, image TEXT)";
             tx.executeSql(query);

             // Tempo
             query ="CREATE TABLE IF NOT EXISTS Tempo(tempo INTEGER)";
             tx.executeSql(query);
        }
    );

    // Default values for new db
    db.transaction( function(tx) {
        // ------------ Sound Settings -----------------

        var result = tx.executeSql("SELECT COUNT(*) AS count FROM Settings");
        var count = result.rows.item(0).count;

        if(count == 0) {
            tx.executeSql("INSERT INTO Settings VALUES(?, ?, ?, ?)", [0.75, "tick.wav", 0.75, "tock.wav"])
        }

        // ----------- Time Signature ------------------

        result = tx.executeSql("SELECT COUNT(*) AS count FROM TimeSignature");
        count = result.rows.item(0).count;

        if(count == 0) {
            tx.executeSql("INSERT INTO TimeSignature VALUES(?, ?, ?, ?, ?)", [2, 2, "", "", "eighth.svg"])
        }

        // ------------- Tempo -------------------------

        result = tx.executeSql("SELECT COUNT(*) AS count FROM Tempo");
        count = result.rows.item(0).count;

        if(count == 0) {
            tx.executeSql("INSERT INTO Tempo VALUES(?)", [120])
        }

    });

    return db;
}


// ------------- GET EVERYTHING --------------------
function getDbItems() {
    var db = getDatabase()
    var dbItems = new Array()
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM Settings");
        dbItems["mainVolume"]= result.rows.item(0).mainVolume;
        dbItems["mainSound"] = result.rows.item(0).mainSound;
        dbItems["subVolume"]= result.rows.item(0).subVolume;
        dbItems["subSound"] = result.rows.item(0).subSound;

        result = tx.executeSql("SELECT * FROM TimeSignature");
        dbItems["numBeats"] = result.rows.item(0).numBeats;
        dbItems["tempoDiv"] = result.rows.item(0).tempoDiv;

        var pattern = result.rows.item(0).pattern;
        if (pattern == null) dbItems["pattern"] = "";           // assign empty string instead of null
        else dbItems["pattern"] = pattern;

        var silentPattern = result.rows.item(0).silentPattern;
        if (silentPattern == null) dbItems["silentPattern"] = ""; // assign empty string instead of null
        else dbItems["silentPattern"] = silentPattern;

        dbItems["beatImage"] = result.rows.item(0).image;

        result = tx.executeSql("SELECT * FROM Tempo");
        dbItems["tempo"] = result.rows.item(0).tempo;
    });
    return dbItems;
}

function saveSettings(mainVolume, mainSound, subVolume, subSound) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE Settings SET mainVolume=?, mainSound=?, subVolume=?, subSound=?", [mainVolume, mainSound, subVolume, subSound])
    });
}

function saveTimeSignature(numBeats, tempoDiv, pattern, silentPattern, img) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE TimeSignature SET numBeats=?, tempoDiv=?, pattern=?, silentPattern=?, image=?", [numBeats, tempoDiv, pattern, silentPattern, img])
    });
}

function saveTempo(tempo) {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE Tempo SET tempo=?", [tempo])
    });
}
