# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal

DESCRIPTION="Compatibility library providing the pangox API removed from pango 1.31"
HOMEPAGE="https://gitlab.gnome.org/Archive/pangox-compat"
SRC_URI="https://download.gnome.org/sources/${PN}/$(ver_cut 1-2)/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~amd64"

# Resurrected from ::gentoo (removed 2019, bug #571866) because the
# Total Phase Flash Center binary carries a DT_NEEDED entry for
# libpangox-1.0.so.0 — vestigial SDK linkage; it imports no pango_x_*
# symbols and only needs the library to be loadable. Multilib because
# that binary is 32-bit only.
RDEPEND="
	dev-libs/glib:2[${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/pango[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-pango-1.44.patch
	"${FILESDIR}"/${P}-glib-g-const-return.patch
)

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf --disable-static
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
