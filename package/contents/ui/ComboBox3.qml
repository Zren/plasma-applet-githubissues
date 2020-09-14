/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Templates 2.7 as T
import QtQuick.Controls 2.7 as Controls
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.5 as Kirigami
// import "private" as Private
// import "mobiletextselection" as MobileTextSelection

import org.kde.plasma.components 3.0 as PlasmaComponents3
// https://invent.kde.org/frameworks/plasma-framework/-/blame/master/src/declarativeimports/plasmacomponents3/ComboBox.qml
// https://github.com/qt/qtquickcontrols2/blame/dev/src/imports/controls/ComboBox.qml
// https://github.com/qt/qtquickcontrols2/blob/dev/src/quicktemplates2/qquickcombobox.cpp

PlasmaComponents3.ComboBox {
	id: control

	contentItem: T.TextField {
		id: textField
		padding: 0
		anchors {
			fill:parent
			leftMargin: control.leftPadding
			rightMargin: control.rightPadding
			topMargin: control.topPadding
			bottomMargin: control.bottomPadding
		}
		text: control.editable ? control.editText : control.displayText

		enabled: control.editable
		autoScroll: control.editable

		readOnly: control.down || !control.hasOwnProperty("editable") || !control.editable
		inputMethodHints: control.inputMethodHints
		validator: control.validator

		// Work around Qt bug where NativeRendering breaks for non-integer scale factors
		// https://bugreports.qt.io/browse/QTBUG-67007
		renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
		color: PlasmaCore.ColorScope.textColor
		selectionColor: Kirigami.Theme.highlightColor
		selectedTextColor: Kirigami.Theme.highlightedTextColor

		// selectByMouse: !Kirigami.Settings.tabletMode
		// cursorDelegate: Kirigami.Settings.tabletMode ? mobileCursor : undefined

		font: control.font
		horizontalAlignment: Text.AlignLeft
		verticalAlignment: Text.AlignVCenter
		opacity: control.enabled ? 1 : 0.3
		onFocusChanged: {
			if (focus) {
				// MobileTextSelection.MobileTextActionsToolBar.controlRoot = textField;
			}
		}

		// onTextChanged: MobileTextSelection.MobileTextActionsToolBar.shouldBeVisible = false;
		// onPressed: MobileTextSelection.MobileTextActionsToolBar.shouldBeVisible = true;

		onPressAndHold: {
			if (!Kirigami.Settings.tabletMode) {
				return;
			}
			forceActiveFocus();
			cursorPosition = positionAt(event.x, event.y);
			selectWord();
		}
	}
}
