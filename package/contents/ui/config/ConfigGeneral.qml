import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ColumnLayout {
	property alias cfg_user: userTextField.text
	property alias cfg_repo: repoTextField.text

	ColumnLayout {
		Layout.alignment: Qt.AlignTop
		RowLayout {
			Label {
				text: i18n("User:")
			}
			TextField {
				id: userTextField
				Layout.fillWidth: true
			}
		}

		RowLayout {
			Label {
				text: i18n("Repo:")
			}
			TextField {
				id: repoTextField
				Layout.fillWidth: true
			}
		}
	}
}
