.import QtQuick.LocalStorage 2.0 as Sql

var db = null;

function getDatabase() {
    if (db === null) {
        try {
            db = Sql.LocalStorage.openDatabaseSync("sddm-sugar-candy-user-sessions", "1.0", "User Session Persistent Storage", 100000);
            db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS user_sessions(username TEXT PRIMARY KEY, session_file TEXT)');
            });
        } catch (err) {
            console.log("Error opening/creating user session database:", err);
        }
    }
    return db;
}

function getLastSessionForUser(username) {
    var sessionFile = "";
    var localDb = getDatabase();
    if (!localDb) return "";
    try {
        localDb.transaction(function(tx) {
            var rs = tx.executeSql('SELECT session_file FROM user_sessions WHERE username=?', [username]);
            if (rs.rows.length > 0) {
                sessionFile = rs.rows.item(0).session_file;
            }
        });
    } catch (err) {
        console.log("Error reading last session for user:", err);
    }
    return sessionFile;
}

function saveLastSessionForUser(username, sessionFile) {
    var localDb = getDatabase();
    if (!localDb) return;
    try {
        localDb.transaction(function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO user_sessions(username, session_file) VALUES(?, ?)', [username, sessionFile]);
        });
    } catch (err) {
        console.log("Error saving last session for user:", err);
    }
}
