EAPI=8

inherit desktop xdg-utils

DESCRIPTION="Lattice Diamond FPGA development environment"
HOMEPAGE="https://www.latticesemi.com/latticediamond"
LICENSE="lattice"

# 3.14 ships as a Qt Installer Framework GUI installer that hangs in unattended
# (--script) mode on this build (parent waits on eventfd while a child IPC
# process busy-loops on a never-created /tmp/{uuid} Unix socket — looks like a
# QtIFW 2.0.1 RemoteServerConnection issue specific to Lattice's installer).
#
# Workaround: install Diamond by hand once, then repackage the resulting tree
# as a prebuilt distfile that this ebuild stages into the image. The full
# recipe is printed by pkg_nofetch when the distfile is missing.
MY_PV="3.14.0.75.2"
SRC_URI="diamond-${MY_PV}-amd64-prebuilt.tar.zst"

S="${WORKDIR}"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch strip"

RDEPEND="dev-lang/python:2.7
	>=sys-libs/glibc-2.36-r5
	>=media-libs/libjpeg-turbo-2.1.4
	>=media-libs/tiff-4.5.0
	>=sys-libs/zlib-1.2.13-r1
	>=dev-libs/glib-2.74.4
	>=sys-libs/libselinux-3.4
	>=dev-libs/libgamin-0.1.10-r6
	>=dev-libs/libusb-compat-0.1.5-r3
	>=media-libs/freetype-2.12.1-r1
	>=media-libs/fontconfig-2.14.0-r1
	>=dev-libs/expat-2.5.0
	>=x11-libs/libX11-1.8.1
	>=x11-libs/libICE-1.1.1-r1
	>=x11-libs/libXt-1.2.1
	>=x11-libs/libXft-2.3.6
	>=x11-libs/libXi-1.8
	>=x11-libs/libXext-1.3.5
	>=x11-libs/libXrender-0.9.11"

BDEPEND="app-arch/zstd
	media-gfx/imagemagick"

# Hand-curated QA list from 3.12 covered the prebuilt libs that Lattice ships;
# 3.14's tree is similar but not yet verified. Catch-all for the first pass —
# refine after a successful install with:
#   find /opt/diamond -type f \( -name '*.so*' -o -perm /+x \) \
#       | sed 's|^/||' | sort -u
QA_PREBUILT="opt/diamond/*"

src_unpack() {
	# Portage's default unpack skips .tar.zst on this machine (EAPI=8
	# notwithstanding). Drive tar directly.
	cd "${WORKDIR}" || die
	tar --zstd -xf "${DISTDIR}/${A}" || die "tar --zstd failed on ${A}"
}

pkg_nofetch() {
	einfo "${SRC_URI} is a hand-built repackage of an interactively-installed"
	einfo "Diamond ${PV} tree. The IFW installer hangs in unattended mode on"
	einfo "this Lattice build, so the distfile must be produced manually."
	einfo
	einfo "Recipe:"
	einfo
	einfo "  1. Unpack the original installer:"
	einfo "       mkdir -p /tmp/diamond-stage && cd /tmp/diamond-stage"
	einfo "       unzip ~/Downloads/${MY_PV}_Diamond_lin.zip"
	einfo "       chmod +x ${MY_PV}_Diamond_lin.run"
	einfo
	einfo "  2. Run the GUI installer; pick install directory"
	einfo "         /tmp/diamond-stage/opt/diamond"
	einfo "     so the result is a self-contained opt/diamond/ tree under"
	einfo "     the staging root. Accept the license, select all components."
	einfo
	einfo "       ./${MY_PV}_Diamond_lin.run"
	einfo
	einfo "  3. Verify the install landed:"
	einfo "       ls /tmp/diamond-stage/opt/diamond/bin/lin64/diamond"
	einfo
	einfo "  4. Tar from the staging root (the ebuild expects opt/diamond"
	einfo "     at the top of the archive):"
	einfo "       cd /tmp/diamond-stage"
	einfo "       tar --zstd -cf ${SRC_URI} opt/"
	einfo
	einfo "  5. Stage the distfile and regenerate the Manifest:"
	einfo "       sudo install -m 644 ${SRC_URI} ${DISTDIR}/"
	einfo "       cd <overlay>/dev-embedded/diamond"
	einfo "       ebuild diamond-${PV}.ebuild manifest"
	einfo
	einfo "  6. Re-emerge:"
	einfo "       emerge -av =${CATEGORY}/${PF}"
}

src_install() {
	# The tarball is laid out as opt/diamond/... so a single cp -a stages it.
	[[ -d "${WORKDIR}/opt/diamond" ]] || die \
		"${WORKDIR}/opt/diamond not found — distfile layout wrong?"
	dodir /opt
	cp -a "${WORKDIR}/opt/diamond" "${ED}/opt/" || die

	local icon_src="${ED}/opt/diamond/docs/webhelp/eng/connect/Lattice_Icon.ico"
	if [[ -f "${icon_src}" ]]; then
		convert "${icon_src}" "${T}/lattice.png" || die
		doicon "${T}/lattice.png"
	else
		ewarn "Lattice icon not found at expected path; skipping doicon."
	fi

	make_desktop_entry /opt/diamond/bin/lin64/diamond \
		"Lattice Diamond" \
		"lattice" \
		Development
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
