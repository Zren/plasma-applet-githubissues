import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"
import "lib/Requests.js" as Requests

Item {
	id: widget

	Plasmoid.icon: plasmoid.file("", "icons/octicon-mark-github.svg")

	property string user: 'Zren'
	property string repo: 'plasma-applet-tiledmenu'
	// readonly property string issuesUrl: 'https://api.github.com/repos/' + user + '/' + repo + '/issues?state=all'
	// readonly property string issuesUrl: 'Zren-plasma-applet-eventcalendar-issues.json'
	readonly property string issuesUrl: plasmoid.file("", "ui/Zren-plasma-applet-tiledmenu-issues.json")

	property var issuesModel: []

	Plasmoid.fullRepresentation: FullRepresentation {}

	function updateIssuesModel() {
		Requests.getJSON({
			url: issuesUrl
		}, function(err, data, xhr){
			console.log(err)
			console.log(data)
			widget.issuesModel = data
		})
	}
	Component.onCompleted: {
		updateIssuesModel()
	}
}
