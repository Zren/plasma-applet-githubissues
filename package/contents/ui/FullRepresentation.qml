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

						Text {
							id: issueTitleIcon
							
							text: {
								if (issue.state == 'open') {
									return octicons.issueOpened
								} else { // 'closed'
									return octicons.issueClosed
								}
							}
							color: {
								if (issue.state == 'open') {
									return '#28a745'
								} else { // 'closed'
									return '#cb2431'
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


						TextButton {
							id: issueTitleLabel

							Layout.fillWidth: true
							text: issue.title
							font.weight: Font.Bold

							onClicked: Qt.openUrlExternally(issue.html_url)
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

								Text {
									text: octicons.comment
									
									color: commentButton.textColor
									font.family: "fontello"
									// font.weight: Font.Bold
									font.pointSize: -1
									font.pixelSize: 16 * units.devicePixelRatio
									Layout.preferredHeight: 16 * units.devicePixelRatio
								}

								Text {
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
