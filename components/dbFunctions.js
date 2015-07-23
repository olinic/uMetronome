function getDatabase() {
    var db =  Sql.LocalStorage.openDatabaseSync("uMetronomeSettings", "1.0", "User settings for the uMetronome App", 512);
    //create table
    db.transaction(
        function(tx) {
             var query ="CREATE TABLE IF NOT EXISTS Settings(mainVolume INTEGER, mainSound TEXT, subVolume INTEGER, subSound TEXT)";
             tx.executeSql(query);
        }
    );

    //insert default if it is a new db
    db.transaction( function(tx) {
        var result = tx.executeSql("SELECT COUNT(*) AS count FROM Settings");
        var count = result.rows.item(0).count;

        if(count == 0) {
            tx.executeSql("INSERT INTO Settings VALUES(?, ?, ?, ?)", [0.75, "tick.wav", 0.75, "tock.wav"])
        }


    });

    return db;
}

function getDbItems() {
    var db = getDatabase()
    var dbItems = new Array()
    db.transaction(function(tx) {
        var result = tx.executeSql("SELECT * FROM Settings");
        dbItems["mainVolume"]= result.rows.item(0).mainVolume;
        dbItems["mainSound"] = result.rows.item(0).mainSound;
        dbItems["subVolume"]= result.rows.item(0).subVolume;
        dbItems["subSound"] = result.rows.item(0).subSound;
    });
    return dbItems;
}

function saveSettings() {
    var db = getDatabase()
    db.transaction(function(tx) {
        tx.executeSql("UPDATE Settings SET mainVolume=?, mainSound=?, subVolume=?, subSound=?", [mainBeatSlider.value, mainBeatLabel.text, subBeatSlider.value, subBeatLabel.text])
    });
}
