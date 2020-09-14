// Version 7

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "lib"
import "lib/TimeUtils.js" as TimeUtils

Item {
	id: issueListView

	property bool isSetup: false
	property bool showHeading: true
	property bool showFilter: true
	property string headingText: ""
	property alias searchText: searchTextField.text
	property string selectedTag: ""
	property var tagModel: []

	signal refresh()
	signal doSearch(string searchText)
	signal tagFilterSelected(string tag)

	property string errorMessage: ''
	readonly property bool hasError: !!errorMessage

	property alias delegate: listView.delegate

	property alias scrollView: scrollView
	property alias listView: listView
	property alias heading: heading
	property alias searchTextField: searchTextField
	property alias tagComboBox: tagComboBox
	property alias relativeDateTimer: relativeDateTimer

	Layout.minimumWidth: 300 * units.devicePixelRatio
	Layout.minimumHeight: 200 * units.devicePixelRatio
	Layout.preferredHeight: 600 * units.devicePixelRatio

	RelativeDateTimer { id: relativeDateTimer }

	ColumnLayout {
		anchors.fill: parent
		visible: issueListView.isSetup

		PlasmaComponents.Label {
			id: heading
			Layout.fillWidth: true
			visible: issueListView.showHeading
			text: issueListView.headingText
			font.weight: Font.Bold
			font.pointSize: -1
			font.pixelSize: 18 * units.devicePixelRatio
			elide: Text.ElideRight
			wrapMode: Text.NoWrap
			fontSizeMode: Text.Fit

			PlasmaCore.ToolTipArea {
				anchors.fill: parent
				enabled: parent.truncated
				subText: parent.text
			}
		}

		RowLayout {
			id: filterRow
			visible: issueListView.showFilter

			PlasmaComponents3.TextField {
				id: searchTextField
				placeholderText: i18n("Search")
				Layout.fillWidth: true
				onTextChanged: debouncedTextChange.restart()

				Timer {
					id: debouncedTextChange
					interval: 400
					onTriggered: {
						issueListView.doSearch(searchTextField.text)
					}
				}
			}
			// ComboBox3 auto-closes on click release (KDE Bug #424076)
			// So we'll use a patched version until it's fixed.
			// PlasmaComponents3.ComboBox {
			ComboBox3 {
				id: tagComboBox
				textRole: "text"
				property string valueRole: "value"
				model: issueListView.tagModel
				property bool populated: false
				editable: false

				onCurrentIndexChanged: {
					if (populated && currentIndex >= 0) {
						var item = model[currentIndex]
						var itemValue = item[valueRole]
						tagFilterSelected(itemValue)
					}
				}

				function findValue(val) {
					for (var i = 0; i < model.length; i++) {
						var item = model[i]
						var itemValue = item[valueRole]
						if (itemValue == val) {
							return i
						}
					}
					return -1
				}

				function selectValue(val) {
					var index = findValue(val)
					if (index >= 0) {
						if (index != currentIndex) {
							currentIndex = index
						}
					} else {
						editText = val
					}
				}

				Connections {
					target: issueListView
					onSelectedTagChanged: {
						tagComboBox.selectValue(issueListView.selectedTag)
					}
				}

				Component.onCompleted: {
					tagComboBox.selectValue(issueListView.selectedTag)
					populated = true
				}
			}
		}

		ScrollView {
			id: scrollView
			Layout.fillWidth: true
			Layout.fillHeight: true

			ListView {
				id: listView
				width: scrollView.width

				model: issuesModel
			}
		}

	}

	ColumnLayout {
		id: errorLayout
		anchors.centerIn: parent
		visible: issueListView.hasError || !issueListView.isSetup
		spacing: units.largeSpacing
		width: parent.width

		PlasmaComponents.Label {
			visible: issueListView.hasError
			text: issueListView.errorMessage
			color: PlasmaCore.ColorScope.negativeTextColor
			Layout.fillWidth: true
		}

		PlasmaComponents.Button {
			visible: !issueListView.isSetup
			text: plasmoid.action("configure").text
			onClicked: plasmoid.action("configure").trigger()
			Layout.alignment: Qt.AlignHCenter
		}

		PlasmaComponents.Button {
			visible: issueListView.hasError
			text: i18n("Refresh")
			onClicked: issueListView.refresh()
			Layout.alignment: Qt.AlignHCenter
		}
	}
}
