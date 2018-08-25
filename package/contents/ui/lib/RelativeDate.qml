import QtQuick 2.0

Text {
	id: timeText
	property var dateTime
	text: ""
	
	Connections {
		target: relativeDateTimer
		onTriggered: timeText.update()
	}
	Component.onCompleted: timeText.update()

	function update() {
		var now = new Date()
		var nowValue = now.valueOf()
		var dateTimeValue = dateTime.valueOf()
		var diff = nowValue - dateTimeValue
		if (diff < 60 * 1000) { // less than a minute
			text = i18n("Just Now")
		} else if (diff < 60 * 60 * 1000) { // less than an hour
			var minutes = Math.floor(diff / (60 * 1000))
			if (minutes >= 2) {
				text = i18n("%1 minutes ago", minutes)
			} else {
				text = i18n("%1 minute ago", minutes)
			}
		} else if (diff < 24 * 60 * 60 * 1000) { // less than a day
			var hours = Math.floor(diff / (60 * 60 * 1000))
			if (hours >= 2) {
				text = i18n("%1 hours ago", hours)
			} else {
				text = i18n("%1 hour ago", hours)
			}
		} else {
			text = Qt.formatDateTime(dateTime, "MMM d, yyyy h:mm AP")
		}
	}

}
