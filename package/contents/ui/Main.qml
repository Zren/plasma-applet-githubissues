import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"
import "lib/Async.js" as Async
import "lib/Requests.js" as Requests

Item {
	id: widget

	Logger {
		id: logger
		name: 'githubissues'
		// showDebug: true
	}

	Plasmoid.icon: plasmoid.file("", "icons/octicon-mark-github.svg")
	Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground
	Plasmoid.hideOnWindowDeactivate: !plasmoid.userConfiguring

	readonly property string issueState: plasmoid.configuration.issueState
	readonly property var repoStringList: plasmoid.configuration.repoList

	property var issuesModel: []

	Octicons { id: octicons }

	Plasmoid.fullRepresentation: FullRepresentation {}

	function fetchIssues(repoString, issueState, callback) {
		logger.debug('fetchIssues', repoString, issueState)
		var url
		var isLocalFile = repoString.indexOf('file://') >= 0
		if (isLocalFile) { // Testing
			url = repoString
		// } else if () { // repoString contains two slashes
			// Eg: domain.com/User/Repo
		} else {
			url = 'https://api.github.com/repos/' + repoString + '/issues?state=' + issueState
		}

		Requests.getJSON({
			url: url
		}, function(err, data, xhr){
			logger.debug('fetchIssues.response.url', url)
			logger.debug('fetchIssues.response', err, data && data.length)
			// logger.debugJSON(data)

			if (isLocalFile) {
				callback(null, data) // We get HTTP 0 error for a local file, ignore it.
			} else {
				callback(err, data)
			}
		})
	}

	function updateIssuesModel() {
		logger.debug('updateIssuesModel')

		var tasks = []
		for (var i = 0; i < repoStringList.length; i++) {
			var repoString = repoStringList[i]
			var task = fetchIssues.bind(null, repoString, 'all')
			tasks.push(task)
		}

		Async.parallel(tasks, function(err, results){
			logger.debug('Async.parallel.done', err, results && results.length)
			if (err) {
				// Skip, keep existing results (we probably hit the rate limit).
				// A user has 60 requests per hour.
				// https://developer.github.com/v3/#rate-limiting
				// TODO: Show overlay error message for user feedback.
			} else {
				// logger.debugJSON(results)
				parseResults(results)
			}
		})
	}

	function issueCreatedDate(issue) {
		return new Date(issue.created_at).valueOf()
	}
	function parseResults(results) {
		// Concat all issue lists
		var issues = Array.prototype.concat.apply(results[0], results.slice(1))
		
		// Sort issues by creation date descending
		issues = issues.sort(function(a, b){
			return issueCreatedDate(b) - issueCreatedDate(a)
		})

		issuesModel = issues
	}

	Timer {
		id: debouncedUpdateIssuesModel
		interval: 400
		onTriggered: {
			logger.debug('debouncedUpdateIssuesModel.onTriggered')
			widget.updateIssuesModel()
		}
	}
	Timer {
		id: updateModelTimer
		running: true
		repeat: true
		interval: plasmoid.configuration.updateIntervalInMinutes * 60 * 1000
		onTriggered: {
			logger.debug('updateModelTimer.onTriggered')
			debouncedUpdateIssuesModel.restart()
		}
	}

	Connections {
		target: plasmoid.configuration
		onRepoListChanged: debouncedUpdateIssuesModel.restart()
		onIssueStateChanged: debouncedUpdateIssuesModel.restart()
	}

	function action_refresh() {
		debouncedUpdateIssuesModel.restart()
	}

	Component.onCompleted: {
		plasmoid.setAction("refresh", i18n("Refresh"), "view-refresh")

		updateIssuesModel()

		// plasmoid.action("configure").trigger() // Uncomment to test config window
	}
}
