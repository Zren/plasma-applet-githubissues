// Version 1

import QtQuick 2.0
import QtQuick.LocalStorage 2.0

// http://doc.qt.io/qt-5/qtquick-localstorage-qmlmodule.html
QtObject {
	id: localDb
	property string name
	property string version: "1"
	property string description: ""
	property int estimatedSize: 1 * 1024 * 1024 // 1 MiB
	property var db: null

	function initDb(callback) {
		db = LocalStorage.openDatabaseSync(name, version, description, estimatedSize)

		db.transaction(function(tx) {
			// Create the database if it doesn't already exist
			var sql = 'CREATE TABLE IF NOT EXISTS KeyValue('
			sql += 'name TEXT NOT NULL PRIMARY KEY,'
			sql += 'dataStr TEXT,'
			sql += 'created_at timestamp NOT NULL DEFAULT current_timestamp,'
			sql += 'updated_at timestamp NOT NULL DEFAULT current_timestamp)'
			tx.executeSql(sql)
			callback(null)
		})
	}

	function get(key, callback) {
		db.transaction(function(tx) {
			var rs = tx.executeSql('SELECT * FROM KeyValue WHERE name = ?', key)
			var row = null
			if (rs.rows.length >= 1) {
				var row = rs.rows.item(0)
			}
			console.log('db.get', key, row && row.updated_at, row && row.dataStr)
			callback(null, row)
		})
	}

	function getJSON(key, callback) {
		get(key, function(err, row){
			if (err) {
				callback(err, null, row)
			} else {
				if (row) {
					var data = row.dataStr
					if (row.dataStr) {
						data = JSON.parse(data)
					}
					callback(null, data, row)
				} else {
					callback(null, null, null)
				}
			}
		})
	}

	function set(key, value, callback) {
		db.transaction(function(tx) {
			tx.executeSql('INSERT OR REPLACE INTO KeyValue(name, dataStr, updated_at) VALUES (?, ?, current_timestamp)', [key, value])
			console.log('db.set', key, value)
			callback(null)
		})
	}

	function setJSON(key, value, callback) {
		var dataStr = JSON.stringify(value)
		set(key, dataStr, callback)
	}
}
