/**
 * Knome Workspace Switcher - GNOME-like virtual desktops switcher for Plasma 6
 * SPDX-FileCopyrightText: 2024 Sakib Reza
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
}