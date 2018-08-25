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

	ScrollView {
		id: scrollView
		anchors.fill: parent

		ListView {
			id: listView
			width: scrollView.width

			model: issuesModel
			delegate: ColumnLayout {
				spacing: 0
				width: listView.width
					
				property var issue: modelData

				Rectangle {
					visible: index > 0
					Layout.fillWidth: true
					color: theme.textColor
					Layout.preferredHeight: 1 * units.devicePixelRatio
					opacity: 0.3
				}
			
				RowLayout {
					property int rightPadding: 16 * units.devicePixelRatio
					Layout.rightMargin: rightPadding
					Layout.fillWidth: true

					AppletIcon {
						source: {
							if (issue.state == 'open') {
								return "octicon-issue-open"
							} else { // 'closed'
								return "octicon-issue-closed"
							}
						}
						Layout.minimumWidth: 16 * units.devicePixelRatio
						Layout.minimumHeight: 16 * units.devicePixelRatio
						Layout.maximumWidth: Layout.minimumWidth
						property int padding: 8 * units.devicePixelRatio
						Layout.topMargin: padding
						Layout.bottomMargin: padding
						Layout.leftMargin: 16 * units.devicePixelRatio
						Layout.alignment: Qt.AlignTop
					}

					ColumnLayout {
						property int padding: 8 * units.devicePixelRatio
						Layout.topMargin: padding
						Layout.bottomMargin: padding
						spacing: 4 * units.devicePixelRatio

						PlasmaComponents.Label {
							Layout.fillWidth: true
							Layout.preferredHeight: contentHeight
							text: '<a href="' + issue.html_url + '">' + issue.title + '</a>'
							wrapMode: Text.Wrap
							font.family: 'Helvetica'
							font.pointSize: -1
							font.pixelSize: 16 * units.devicePixelRatio
							font.weight: Font.Bold
							linkColor: PlasmaCore.ColorScope.highlightColor
							onLinkActivated: Qt.openUrlExternally(link)
							
							MouseArea {
								anchors.fill: parent
								acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
								cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
							}
						}

						PlasmaComponents.Label {
							Layout.fillWidth: true
							Layout.preferredHeight: contentHeight
							text: {
								if (issue.state == 'open') { // '#19 opened 7 days ago by RustyRaptor'
									return i18n("#%1 opened %2 by %3", issue.number, TimeUtils.getRelativeDate(issue.created_at), issue.user.login)
								} else { // 'closed'   #14 by JPRuehmann was closed on 5 Jul 
									return i18n("#%1 by %3 was closed on %2", issue.number, TimeUtils.getRelativeDate(issue.closed_at), issue.user.login)
								}
							}
							wrapMode: Text.Wrap
							font.family: 'Helvetica'
							font.pointSize: -1
							font.pixelSize: 12 * units.devicePixelRatio
							opacity: 0.6
						}
					}

					RowLayout {
						visible: issue.comments > 0
						spacing: 0
						Layout.alignment: Qt.AlignTop

						AppletIcon {
							source: "octicon-comment"
							Layout.minimumWidth: 16 * units.devicePixelRatio
							Layout.minimumHeight: 16 * units.devicePixelRatio
							Layout.maximumWidth: Layout.minimumWidth
							property int padding: 8 * units.devicePixelRatio
							Layout.topMargin: padding
							Layout.bottomMargin: padding
							Layout.leftMargin: 16 * units.devicePixelRatio
						}
						PlasmaComponents.Label {
							text: " " + issue.comments
						}
					}
				}
				
			}
		}
	}
}
