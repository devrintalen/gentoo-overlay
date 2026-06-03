# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop udev wrapper xdg-utils

MY_P="flash-center-linux-i686-v${PV}"

DESCRIPTION="Total Phase Flash Center memory programmer for Aardvark, Cheetah, and Promira"
HOMEPAGE="https://www.totalphase.com/products/flash-center/"
SRC_URI="${MY_P}.zip"
S="${WORKDIR}/${MY_P}"

LICENSE="totalphase"
SLOT="0"
KEYWORDS="~amd64"

# fetch: downloads are gated behind a Total Phase account login, and the
# EULA forbids placing the product on publicly-accessible servers.
# strip: prebuilt vendor binaries.
RESTRICT="fetch strip"

# Unlike Control Center, nothing is bundled: the only Linux build is a
# 32-bit GTK2 binary (lib/libruntime.so — an executable despite the
# name) that links everything below from the system, hence the
# abi_x86_32 deps. libpangox-1.0.so.0 is vestigial SDK linkage (no
# pango_x_* symbols are imported) and is satisfied by the
# x11-libs/pangox-compat resurrected in this overlay.
RDEPEND="
	acct-group/plugdev
	app-accessibility/at-spi2-core[abi_x86_32(-)]
	dev-libs/glib:2[abi_x86_32(-)]
	sys-libs/glibc
	x11-libs/gdk-pixbuf:2[abi_x86_32(-)]
	x11-libs/gtk+:2[abi_x86_32(-)]
	x11-libs/libX11[abi_x86_32(-)]
	x11-libs/libXft[abi_x86_32(-)]
	x11-libs/libXinerama[abi_x86_32(-)]
	x11-libs/libXxf86vm[abi_x86_32(-)]
	x11-libs/pango[abi_x86_32(-)]
	x11-libs/pangox-compat[abi_x86_32(-)]
"

BDEPEND="app-arch/unzip"

QA_PREBUILT="opt/${PN}/*"

pkg_nofetch() {
	einfo "${SRC_URI} is the Total Phase Flash Center ${PV} package for Linux."
	einfo "Download it (free account login required) from"
	einfo "    ${HOMEPAGE}"
	einfo "and place it in your DISTDIR."
}

src_install() {
	# The zip is the final directory layout — 'Flash Center' and
	# bin/flashcenter are dirname-"$0" shell scripts around
	# lib/libruntime.so, so the whole tree moves to /opt as-is. The
	# EULA also requires copies to be unmodified and complete
	# (LICENSE.txt included).
	#
	# Portage prints "Error! Installing dynamic libraries (.so) with
	# blank PROVIDES!" at merge time: lib/libruntime.so is the
	# application executable (ET_EXEC, no DT_SONAME), so PROVIDES is
	# correctly empty, but portage's sanity check
	# (portage.util._dyn_libs.dyn_libs.installed_dynlibs) only
	# pattern-matches the *.so filename and honors no exclusion
	# (PROVIDES_EXCLUDE does not reach it). Harmless — REQUIRES is
	# still recorded; renaming the file would fix it but would break
	# the unmodified-copy EULA terms above.
	insinto /opt/${PN}
	doins -r .

	# doins drops the executable bits the zip carries.
	fperms 0755 "/opt/${PN}/Flash Center" /opt/${PN}/bin/flashcenter \
		/opt/${PN}/lib/libruntime.so

	# bin/flashcenter resolves the launcher via dirname "$0", so a
	# plain symlink from /usr/bin would break it — use a wrapper.
	make_wrapper flashcenter /opt/${PN}/bin/flashcenter

	# The zip ships no application icon; files/${PN}.png is the 48x48
	# window icon extracted from the PNG embedded in lib/libruntime.so
	# (the Total Phase logo the app sets at runtime).
	#
	# The icon is installed as "flashcenter", not "${PN}": KDE's
	# KIconLoader tries dash-truncated fallback names within each
	# theme before moving down the inheritance chain, so an icon named
	# flash-center loses to breeze's actions/flash.svg and never
	# renders in the Plasma menu. A dash-free name cannot be
	# truncated.
	newicon -s 48 "${FILESDIR}/${PN}.png" flashcenter.png

	make_desktop_entry flashcenter "Total Phase Flash Center" flashcenter \
		"Development;Electronics"

	udev_dorules "${FILESDIR}/99-${PN}.rules"
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
	elog
	elog "Built-in memory part definitions live in /opt/${PN}/parts/."
	elog "Custom part files can be loaded from anywhere via the GUI."
}

pkg_postrm() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update
}
