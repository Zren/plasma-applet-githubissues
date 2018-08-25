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

	readonly property string repoString: plasmoid.configuration.user + '/' + plasmoid.configuration.repo
	readonly property string issuesUrl: 'https://api.github.com/repos/' + repoString + '/issues?state=all'
	// readonly property string issuesUrl: plasmoid.file("", "ui/Zren-plasma-applet-tiledmenu-issues.json")

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
	Timer {
		id: debouncedUpdateIssuesModel
		interval: 400
		onTriggered: widget.updateIssuesModel()
	}

	Connections {
		target: plasmoid.configuration
		onUserChanged: debouncedUpdateIssuesModel.restart()
		onRepoChanged: debouncedUpdateIssuesModel.restart()
	}

	Plasmoid.hideOnWindowDeactivate: !plasmoid.userConfiguring
	Component.onCompleted: {
		updateIssuesModel()

		// plasmoid.action("configure").trigger() // Uncomment to test config window
	}
}
