import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.5 as Kirigami

import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	property var cfg_repoList
	property alias cfg_headingText: headingTextField.text
	property alias cfg_updateIntervalInMinutes: updateIntervalInMinutesSpinBox.value

	ColumnLayout {
		Layout.alignment: Qt.AlignTop

		Kirigami.FormLayout {
			Layout.fillWidth: true
			wideMode: true

			ConfigStringList {
				id: repoListTextField
				Kirigami.FormData.label: i18n("Repos:")
				Layout.fillWidth: true
				placeholderText: i18n("User/Repo\nUser/Repo")
				textAreaText: parseValue(cfg_repoList)
				onTextAreaTextChanged: cfg_repoList = parseText(textAreaText)
			}

			TextField {
				id: headingTextField
				Kirigami.FormData.label: i18n("Heading:")
				Kirigami.FormData.checkable: true
				Kirigami.FormData.checked: plasmoid.configuration.showHeading
				Kirigami.FormData.onCheckedChanged: plasmoid.configuration.showHeading = Kirigami.FormData.checked
				Layout.fillWidth: true
			}

			ConfigRadioButtonGroup {
				Kirigami.FormData.label: i18n("Issues:")
				configKey: "issueState"
				model: [
					{ value: "open", text: i18n("Open Issues") },
					{ value: "closed", text: i18n("Closed Issues") },
					{ value: "all", text: i18n("Open + Closed Issues") },
				]
			}

			MessageWidget {
				text: i18n("Every IP can only perform 60 API requests to GitHub per hour.\nEach repository listed is 1 request.")
				messageType: information
				visible: true
				closeButtonVisible: false
				Layout.fillWidth: true
			}

			SpinBox {
				id: updateIntervalInMinutesSpinBox
				Kirigami.FormData.label: i18n("Update Every:")
				stepSize: 5
				minimumValue: 5
				maximumValue: 24 * 60
				suffix: i18nc("Polling interval in minutes", "min")
			}

			ConfigCheckBox {
				configKey: "showBackground"
				text: i18n("Desktop Widget: Show background")
			}
		}
	}
}
