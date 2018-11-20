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

	readonly property int updateIntervalInMillis: plasmoid.configuration.updateIntervalInMinutes * 60 * 1000
	readonly property string issueState: plasmoid.configuration.issueState
	readonly property var repoStringList: plasmoid.configuration.repoList

	property var issuesModel: []

	Octicons { id: octicons }

	LocalDb {
		id: localDb
		name: plasmoid.pluginName
		version: "1" // DB version, not Widget version
	}

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

	function hasExpired(dt, ttl) {
		var now = new Date()
		var diff = now.getTime() - dt.getTime()
		logger.debug('now:', now.getTime(), now)
		logger.debug('dt: ', dt.getTime(), dt)
		logger.debug('(diff-ttl):', diff, '-', ttl, '=', (diff-ttl), '(diff >= ttl):', diff >= ttl)
		return diff >= ttl
	}

	function getIssueList(repoString, issueState, callback) {
		logger.debug('getIssueList', repoString, issueState)
		localDb.getJSON(repoString, function(err, data, row){
			logger.debug('getJSON', repoString, data)

			var shouldUpdate = true
			if (data) {
				// Can we assume the timestamp is always UTC?
				// The 'Z' parses the timestamp in UTC.
				// Maybe check the length of the string?
				var rowUpdatedAt = new Date(row.updated_at + 'Z')
				var ttl = widget.updateIntervalInMillis
				shouldUpdate = hasExpired(rowUpdatedAt, ttl)
			}
			logger.debug('shouldUpdate', shouldUpdate)

			if (shouldUpdate) {
				fetchIssues(repoString, issueState, function(err, data) {
					localDb.setJSON(repoString, data, function(err){
						logger.debug('setJSON', repoString)
						callback(err, data)
					})
				})
			}
		})
	}

	function updateIssuesModel() {
		logger.debug('updateIssuesModel')

		var tasks = []
		for (var i = 0; i < repoStringList.length; i++) {
			var repoString = repoStringList[i]
			var task = getIssueList.bind(null, repoString, 'all')
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
	function concatLists(arr) {
		if (arr.length >= 2) {
			return Array.prototype.concat.apply(arr[0], arr.slice(1))
		} else if (arr.length == 1) {
			return arr[0]
		} else {
			return []
		}
	}
	function parseResults(results) {
		// Concat all issue lists
		var issues = concatLists(results)
		
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
		interval: widget.updateIntervalInMillis
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

		localDb.initDb(function(err){
			updateIssuesModel()
		})

		// plasmoid.action("configure").trigger() // Uncomment to test config window
	}
}
