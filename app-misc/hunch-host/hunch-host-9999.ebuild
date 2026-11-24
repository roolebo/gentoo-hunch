# Copyright 2026 Roman Bolshakov
# Distributed under the terms of the MIT license

EAPI=8

# Edition 2024, and as_chunks
RUST_MIN_VER="1.88.0"

inherit cargo git-r3 systemd

DESCRIPTION="hunch: the tree of the human's devices, the seat, and their tools"
HOMEPAGE="https://github.com/roolebo/hunch"
EGIT_REPO_URI="https://github.com/roolebo/hunch.git"
# The series, under review
EGIT_BRANCH="hosts"

# The crates are MIT or offer it, and unicode-ident adds Unicode-3.0
LICENSE="MIT Unicode-3.0"
SLOT="0"
IUSE="+compute gnome +seat"
# The extension serves the seat's desktop, and draws its menu
REQUIRED_USE="gnome? ( seat )"

# compute builds ggml; the seat records through ALSA
DEPEND="seat? ( media-libs/alsa-lib )"
# secret-tool keeps the keys of hosts' servers
RDEPEND="
	${DEPEND}
	seat? ( app-crypt/libsecret )
	app-misc/jq
	app-misc/tmux
	gnome? ( gnome-base/gnome-shell )
"
BDEPEND="
	compute? ( dev-build/cmake )
	seat? ( virtual/pkgconfig )
"

src_unpack() {
	git-r3_src_unpack
	# It fetches the crates of the Cargo.toml in the current directory
	local crate
	for crate in host seat; do
		pushd "${S}/${crate}" > /dev/null || die
		cargo_live_src_unpack
		popd > /dev/null || die
	done
}

src_configure() {
	# Each crate takes its own features at build
	:
}

src_compile() {
	pushd host > /dev/null || die
	cargo_src_compile
	popd > /dev/null || die
	if use seat || use compute; then
		local features=wm
		use seat && features+=,seat
		use compute && features+=,compute
		pushd seat > /dev/null || die
		cargo_src_compile --no-default-features --features "${features}"
		popd > /dev/null || die
	fi
}

src_test() {
	pushd host > /dev/null || die
	cargo_src_test
	popd > /dev/null || die
}

src_install() {
	pushd host > /dev/null || die
	dobin "$(cargo_target_dir)"/{hunch-host,hunch-9p,hunch-browser-native}
	popd > /dev/null || die
	sed "s|@HUNCH_HOST@|${EPREFIX}/usr/bin/hunch-host|" \
		host/dist/hunch-host.service > "${T}/hunch-host.service" || die
	systemd_douserunit "${T}/hunch-host.service"
	dobin hunch hunch-editor hunch-browser
	install_firefox_host
	if use seat || use compute; then
		pushd seat > /dev/null || die
		dobin "$(cargo_target_dir)/hunch-seat"
		sed "s|@HUNCH_SEAT@|${EPREFIX}/usr/bin/hunch-seat|" \
			dist/hunch-seat.service > "${T}/hunch-seat.service" || die
		systemd_douserunit "${T}/hunch-seat.service"
		newdoc README.md README.seat.md
		popd > /dev/null || die
	fi
	insinto /usr/share/hunch
	doins -r skills
	dodoc README.md
	if use gnome; then
		insinto /usr/share/gnome-shell/extensions
		doins -r gnome/hunch@hunch
	fi
}

# What hunch-browser-native --install does for a user, for all users
install_firefox_host() {
	cat > "${T}/hunch.json" <<-EOF || die
		{
		  "name": "hunch",
		  "description": "hunch-browser-native, which serves the browser to hunch",
		  "path": "${EPREFIX}/usr/bin/hunch-browser-native",
		  "type": "stdio",
		  "allowed_extensions": ["firefox-hunch@hunch"]
		}
	EOF
	insinto /usr/lib/mozilla/native-messaging-hosts
	doins "${T}/hunch.json"
}

pkg_postinst() {
	elog "Each user runs hunch-host with:"
	elog "  systemctl --user enable --now hunch-host"
	elog "and after an upgrade restarts what runs the old build:"
	elog "  systemctl --user restart hunch-host hunch-seat"
	elog "Agents use the skill in ${EPREFIX}/usr/share/hunch/skills/hunch:"
	elog "  ln -s ${EPREFIX}/usr/share/hunch/skills/hunch ~/.claude/skills/hunch"
	if use seat || use compute; then
		elog "Each user runs the seat's service with:"
		elog "  systemctl --user enable --now hunch-seat"
	fi
	if use seat; then
		elog "The dictation key comes from evdev, which takes the group input:"
		elog "  usermod -aG input USER, then log in again"
	fi
	if use gnome; then
		elog "Then, in GNOME:"
		elog "  gnome-extensions enable hunch@hunch"
	fi
}
