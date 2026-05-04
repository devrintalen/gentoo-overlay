EAPI=8

inherit desktop udev xdg-utils

DESCRIPTION="Lattice Diamond FPGA development environment"
HOMEPAGE="https://www.latticesemi.com/latticediamond"
LICENSE="lattice"

MY_PV="3.14.0.75.2"
SRC_URI="${MY_PV}_Diamond_lin.zip"

S="${WORKDIR}"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="fetch strip"

# All device families are default-on (matches upstream's "select all"); the
# big optional add-ons (Questa simulator, LatticeMico) default off because of
# their size.
IUSE="+crosslink +crosslinkplus +ecp5 latticemico +machnx +machxo3d
	+machxo3l +machxo3lfp questasim +machxo2"

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

BDEPEND="|| ( app-arch/7zip app-arch/p7zip )
	media-gfx/imagemagick"

QA_PREBUILT="opt/diamond/*"

# The ${MY_PV}_Diamond_lin.run inside the .zip is a Qt Installer Framework
# 2.0.1 binary. After the ELF + Qt resources, it embeds 30 raw 7z archives
# glued end-to-end with 40-byte SHA1 hex strings as separators. Each archive
# corresponds to one of the installer's 22 components — 11 components carry
# real data, 11 are empty placeholders for greyed-out / deprecated device
# families whose data already lives in `base`.
#
# We slice the archives we want straight out of the .run by exact byte
# range. The Manifest's checksum on the surrounding .zip guarantees byte
# identity of the .run, which guarantees the offsets are stable. If Lattice
# ships a new build, every offset must be re-derived. To do that, walk the
# .run for the 7z magic ("37 7a bc af 27 1c"), compute each archive's size
# from its 32-byte header (32 + nextHeaderOffset + nextHeaderSize), and
# match (size, name) pairs against the trailing TOC in the last ~1.6 KB of
# the .run.
RUN_FILE="${MY_PV}_Diamond_lin.run"

# offset size tag — extracted unconditionally
DIAMOND_BASE_ARCHIVES=(
	"1384409685   43599561  bin"
	"1428009286  149747637  cae_library"
	"1577756963   10874022  data"
	"1588631025   10122814  docs"
	"1598753879     102667  embedded_source"
	"1598856586   20067984  examples"
	"1618924610  221906052  ispfpga"
	"1840830702      31669  license"
	"1840862411    4436084  module"
	"1845298535  404266137  synpbase"
	"2249564712    2568690  tcltk"
)

# use-flag offset size — extracted iff `use $flag` is true
DIAMOND_OPTIONAL_ARCHIVES=(
	"questasim       43337851  1130294611"
	"latticemico   1177322006   207086738"
	"ecp5          2255445111    13369558"
	"machxo3l      2252133763     3310987"
	"machxo3d        38565202     2502051"
	"machxo3lfp      41067382     2269872"
	"machnx        1173632591     1592017"
	"crosslink     2268814798     1643916"
	"machxo2       1176054572     1267299"
	"crosslinkplus 1175224977      829466"
)

pkg_nofetch() {
	einfo "${SRC_URI} is the Lattice Diamond ${MY_PV} installer."
	einfo "Download it from ${HOMEPAGE} and place it in your DISTDIR."
}

# Slice <size> bytes starting at <offset> out of the .run, then 7z-extract
# into ${ED}/opt/diamond.
diamond_extract_slice() {
	local offset="$1" size="$2" tag="$3"
	local tmp="${T}/diamond-${tag}.7z"
	einfo "Extracting ${tag} (${size} bytes @ ${offset})"
	# tail -c +N skips N-1 bytes (lseek on regular files); head -c stops
	# the stream at exactly `size`. Faster than dd bs=1 by orders of
	# magnitude, and no alignment hoop-jumping.
	tail -c "+$((offset + 1))" "${WORKDIR}/${RUN_FILE}" \
		| head -c "${size}" >"${tmp}" \
		|| die "slice failed for ${tag}"
	7z x -y -bso0 -bsp0 -bse2 -o"${ED}/opt/diamond" "${tmp}" \
		|| die "7z extraction failed for ${tag}"
	rm -f "${tmp}" || die
}

src_install() {
	[[ -f "${WORKDIR}/${RUN_FILE}" ]] \
		|| die "${RUN_FILE} not found after unpack — distfile layout wrong?"

	dodir /opt/diamond

	local spec offset size tag flag
	for spec in "${DIAMOND_BASE_ARCHIVES[@]}"; do
		read -r offset size tag <<<"${spec}"
		diamond_extract_slice "${offset}" "${size}" "${tag}"
	done

	for spec in "${DIAMOND_OPTIONAL_ARCHIVES[@]}"; do
		read -r flag offset size <<<"${spec}"
		use "${flag}" && diamond_extract_slice "${offset}" "${size}" "${flag}"
	done

	# Icon path's casing has shifted between Diamond versions; find rather
	# than hard-code.
	local icon_src
	icon_src=$(find "${ED}/opt/diamond/docs" -iname Lattice_Icon.ico 2>/dev/null | head -1)
	if [[ -n "${icon_src}" && -f "${icon_src}" ]]; then
		convert "${icon_src}" "${T}/lattice.png" || die
		doicon "${T}/lattice.png"
	else
		ewarn "Lattice icon not found under docs/; skipping doicon."
	fi

	make_desktop_entry /opt/diamond/bin/lin64/diamond \
		"Lattice Diamond" \
		"lattice" \
		Development

	udev_dorules "${FILESDIR}/92-lattice.rules"
}

pkg_postinst() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "Diamond requires a node-locked license file to run."
	elog "Request one at https://www.latticesemi.com/Support/Licensing"
	elog "and install it as \${HOME}/lattice/license.dat."
	elog
	elog "USB programming cables (Lattice USB2A, HW-USBN-2B) are accessible"
	elog "to the 'plugdev' group. Add yourself with:"
	elog "    gpasswd -a <user> plugdev"
}

pkg_postrm() {
	udev_reload
	xdg_desktop_database_update
	xdg_icon_cache_update
}
