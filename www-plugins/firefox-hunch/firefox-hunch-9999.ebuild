# Copyright 2026 Roman Bolshakov
# Distributed under the terms of the MIT license

EAPI=8

inherit git-r3

DESCRIPTION="Lets an agent read the page the human works on, through hunch"
HOMEPAGE="https://github.com/roolebo/firefox-hunch"
EGIT_REPO_URI="https://github.com/roolebo/firefox-hunch.git"
# Native messaging, which hunch's hosts branch serves
EGIT_BRANCH="hosts"

LICENSE="MIT"
SLOT="0"

# It talks to hunch-browser-native, by native messaging
RDEPEND="app-misc/hunch-host"

# Firefox's id, under which it looks for the extensions of all users
FIREFOX="{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
DIR="/usr/share/mozilla/extensions/${FIREFOX}/firefox-hunch@hunch"

src_install() {
	insinto "${DIR}"
	doins -r extension/.
}

pkg_postinst() {
	elog "Firefox offers it at its next start, if it takes unsigned"
	elog "extensions installed for all users. Otherwise load it each start"
	elog "in about:debugging, Load Temporary Add-on:"
	elog "  ${DIR}/manifest.json"
}
