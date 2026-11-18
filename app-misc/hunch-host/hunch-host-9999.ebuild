# Copyright 2026 Roman Bolshakov
# Distributed under the terms of the MIT license

EAPI=8

# Edition 2024
RUST_MIN_VER="1.85.0"

inherit cargo git-r3 systemd

DESCRIPTION="Serves a host's roles to hunch: window managers, seat, compute"
HOMEPAGE="https://github.com/roolebo/hunch"
EGIT_REPO_URI="https://github.com/roolebo/hunch.git"
S="${WORKDIR}/${P}/host"

# The crates are MIT or offer it, and unicode-ident adds Unicode-3.0
LICENSE="MIT Unicode-3.0"
SLOT="0"
IUSE="+browser +compute"

# compute builds ggml
BDEPEND="compute? ( dev-build/cmake )"

src_unpack() {
	git-r3_src_unpack
	# It fetches the crates of the Cargo.toml in the current directory
	pushd "${S}" > /dev/null || die
	cargo_live_src_unpack
	popd > /dev/null || die
}

src_configure() {
	local myfeatures=(
		wm
		$(usev browser)
		$(usev compute)
	)
	cargo_src_configure --no-default-features
}

src_install() {
	dobin "$(cargo_target_dir)/hunch-host"
	sed "s|@HUNCH_HOST@|${EPREFIX}/usr/bin/hunch-host|" dist/hunch-host.service \
		> "${T}/hunch-host.service" || die
	systemd_douserunit "${T}/hunch-host.service"
	dodoc README.md
}

pkg_postinst() {
	elog "Each user runs the service with:"
	elog "  systemctl --user enable --now hunch-host"
}
