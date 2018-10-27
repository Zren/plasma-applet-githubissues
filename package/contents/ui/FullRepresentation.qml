import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"
import "lib/TimeUtils.js" as TimeUtils

Item {
	id: popup

	Layout.minimumWidth: 300 * units.devicePixelRatio
	Layout.minimumHeight: 200 * units.devicePixelRatio
	Layout.preferredHeight: 600 * units.devicePixelRatio

	RelativeDateTimer { id: relativeDateTimer }

	ColumnLayout {
		anchors.fill: parent

		PlasmaComponents.Label {
			Layout.fillWidth: true
			text: plasmoid.configuration.user + ' / ' + plasmoid.configuration.repo
			font.weight: Font.Bold
			font.pixelSize: 24
			elide: Text.ElideRight
			wrapMode: Text.NoWrap
		}

		ScrollView {
			id: scrollView
			Layout.fillWidth: true
			Layout.fillHeight: true

			ListView {
				id: listView
				width: scrollView.width

				model: issuesModel
				delegate: ColumnLayout {
					spacing: 0
					width: listView.width
						
					property var issue: modelData

					Rectangle {
						// visible: index > 0
						Layout.fillWidth: true
						color: theme.textColor
						Layout.preferredHeight: 1 * units.devicePixelRatio
						opacity: 0.3
					}
					
					RowLayout {
						Layout.fillWidth: true

						property int sidePadding: 16 * units.devicePixelRatio
						Layout.rightMargin: sidePadding
						Layout.leftMargin: sidePadding

						property int padding: 8 * units.devicePixelRatio
						Layout.topMargin: padding
						Layout.bottomMargin: padding

						TextLabel {
							id: issueTitleIcon
							
							text: {
								if (issue.pull_request) {
									if (issue.state == 'open') {
										return octicons.gitPullRequest
									} else { // 'closed'
										// Note, there's currently no way to tell if a pull request was merged
										// or if it was closed. To find that out, we'd need to query 
										// the pull request api endpoint as well.
										if (true) { // issue.merged
											return octicons.gitMerge
										} else {
											return octicons.gitPullRequest
										}
									}
								} else {
									if (issue.state == 'open') {
										return octicons.issueOpened
									} else { // 'closed'
										return octicons.issueClosed
									}
								}
							}
							color: {
								if (issue.state == 'open') {
									return '#28a745'
								} else { // 'closed'
									if (issue.pull_request) {
										// Note: Assume it was merged
										if (true) { // issue.merged
											return '#6f42c1'
										} else {
											return '#cb2431'
										}
									} else {
										return '#cb2431'
									}
								}
							}
							font.family: "fontello"
							font.pointSize: -1
							font.pixelSize: 16 * units.devicePixelRatio
							// font.weight: Font.Bold
							Layout.alignment: Qt.AlignTop
							Layout.minimumWidth: 16 * units.devicePixelRatio
							Layout.minimumHeight: 16 * units.devicePixelRatio
						}

						ColumnLayout {
							spacing: 4 * units.devicePixelRatio

							TextButton {
								id: issueTitleLabel

								Layout.fillWidth: true
								text: issue.title
								font.weight: Font.Bold

								onClicked: Qt.openUrlExternally(issue.html_url)
							}
							TextLabel {
								id: timestampText
								Layout.fillWidth: true
								wrapMode: Text.Wrap
								font.family: 'Helvetica'
								font.pointSize: -1
								font.pixelSize: 12 * units.devicePixelRatio
								opacity: 0.6

								text: ""
								property var dateTime: {
									if (issue.state == 'open') { // '#19 opened 7 days ago by RustyRaptor'
										return issue.created_at
									} else { // 'closed'   #14 by JPRuehmann was closed on 5 Jul 
										return issue.closed_at
									}
								}
								property string dateTimeText: ""
								Component.onCompleted: timestampText.updateText()
								
								Connections {
									target: relativeDateTimer
									onTriggered: timestampText.updateText()
								}

								function updateRelativeDate() {
									dateTimeText = TimeUtils.getRelativeDate(dateTime)
								}

								function updateText() {
									updateRelativeDate()
									if (issue.state == 'open') { // '#19 opened 7 days ago by RustyRaptor'
										text = i18n("#%1 opened %2 by %3", issue.number, dateTimeText, issue.user.login)
									} else { // 'closed'   #14 by JPRuehmann was closed on 5 Jul
										if (issue.pull_request && true) { // Assume issue.merged=true
											text = i18n("#%1 by %3 was merged %2", issue.number, dateTimeText, issue.user.login)
										} else {
											text = i18n("#%1 by %3 was closed %2", issue.number, dateTimeText, issue.user.login)
										}
									}
								}
							}
						}

						MouseArea {
							id: commentButton
							Layout.alignment: Qt.AlignTop
							implicitWidth: commentButtonRow.implicitWidth
							implicitHeight: commentButtonRow.implicitHeight
							
							hoverEnabled: true
							cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
							property color textColor: containsMouse ? PlasmaCore.ColorScope.highlightColor : PlasmaCore.ColorScope.textColor

							onClicked: Qt.openUrlExternally(issue.html_url)

							RowLayout {
								id: commentButtonRow
								spacing: 0

								TextLabel {
									text: octicons.comment
									
									color: commentButton.textColor
									font.family: "fontello"
									// font.weight: Font.Bold
									font.pointSize: -1
									font.pixelSize: 16 * units.devicePixelRatio
									Layout.preferredHeight: 16 * units.devicePixelRatio
								}

								TextLabel {
									text: " " + issue.comments
									
									color: commentButton.textColor
									font.family: "Helvetica"
									// font.weight: Font.Bold
									font.pointSize: -1
									font.pixelSize: 12 * units.devicePixelRatio
									Layout.preferredHeight: 12 * units.devicePixelRatio
									Layout.alignment: Qt.AlignTop
								}
							}
						}
					}
					
				}
			}
		}

	}
}
