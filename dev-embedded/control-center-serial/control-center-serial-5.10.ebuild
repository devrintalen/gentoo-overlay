# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop udev wrapper xdg-utils

MY_P="control-center-linux-x86_64-v${PV}"

DESCRIPTION="Total Phase Control Center Serial GUI for Aardvark, Cheetah, and Promira"
HOMEPAGE="https://www.totalphase.com/products/control-center-serial/"
SRC_URI="${MY_P}.zip"
S="${WORKDIR}/${MY_P}"

LICENSE="totalphase"
SLOT="0"
KEYWORDS="~amd64"

# fetch: downloads are gated behind a Total Phase account login, and the
# EULA forbids placing the product on publicly-accessible servers.
# strip: prebuilt vendor binaries.
RESTRICT="fetch strip"

# Qt 4.8 and its gstreamer-0.10/phonon/png12/xml2 stack are bundled in
# lib/; only the system libraries below are linked from outside the
# bundle (libruntime.so additionally hard-links against GTK2's libgdk).
RDEPEND="
	acct-group/plugdev
	dev-libs/glib:2
	media-libs/fontconfig
	media-libs/freetype
	sys-libs/glibc
	virtual/zlib
	x11-libs/gtk+:2
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender
"

BDEPEND="app-arch/unzip"

QA_PREBUILT="opt/${PN}/*"

pkg_nofetch() {
	einfo "${SRC_URI} is the Total Phase Control Center ${PV} package for Linux."
	einfo "Download it (free account login required) from"
	einfo "    ${HOMEPAGE}"
	einfo "and place it in your DISTDIR."
}

src_install() {
	# The zip is the final directory layout — the main binary loads
	# lib/libruntime.so and friends relative to its own location, so the
	# whole tree moves to /opt as-is. The EULA also requires copies to be
	# unmodified and complete (LICENSE.txt included).
	insinto /opt/${PN}
	doins -r .

	# doins drops the executable bits the zip carries.
	fperms 0755 "/opt/${PN}/Control Center" /opt/${PN}/bin/controlctr

	# bin/controlctr resolves the binary via dirname "$0", so a plain
	# symlink from /usr/bin would break it — use a wrapper instead.
	make_wrapper controlctr /opt/${PN}/bin/controlctr

	# The zip ships no application icon; files/${PN}.png is the 48x48
	# window icon the app sets at runtime (a Qt resource embedded in the
	# binary), captured from _NET_WM_ICON of a running instance.
	newicon -s 48 "${FILESDIR}/${PN}.png" "${PN}.png"

	make_desktop_entry controlctr "Total Phase Control Center" "${PN}" \
		"Development;Electronics"

	udev_dorules "${FILESDIR}/99-totalphase.rules"
}

pkg_postinst() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "Aardvark and Cheetah adapters are accessible to the 'plugdev'"
	elog "group. Add yourself with:"
	elog "    gpasswd -a <user> plugdev"
	elog
	elog "The Promira Serial Platform attaches as a USB network interface"
	elog "and is reached over TCP/IP — it needs no udev rule."
}

pkg_postrm() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update
}
