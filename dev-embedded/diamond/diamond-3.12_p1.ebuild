EAPI=7

inherit rpm desktop xdg-utils

DESCRIPTION="Lattice Diamond FPGA development environment"
HOMEPAGE="https://www.latticesemi.com/latticediamond"
LICENSE="lattice"
SRC_URI="diamond_3_12-base-240-2-x86_64-linux.rpm
	diamond_3_12-sp1-454-2-x86_64-linux.rpm"
MY_PV=$(ver_cut 1-2)

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
	>=sys-libs/libuuid-1.0.3
	>=x11-libs/libXt-1.2.1
	>=x11-libs/libXext-1.3.5
	>=x11-libs/libXrender-0.9.11
	>=x11-libs/libXi-1.8
	>=x11-libs/libXft-2.3.6"

QA_PREBUILT="opt/diamond/data/vmdata/drivers/ftdiusbdriver/libftd2xx.so.0.4.13
	opt/diamond/modeltech/linuxloem/QuestaCppOverride.so
	opt/diamond/modeltech/linuxloem/libhm.sl
	opt/diamond/modeltech/linuxloem/libmtipli.so
	opt/diamond/modeltech/linuxloem/libmtipli.so
	opt/diamond/modeltech/linuxloem/libsm.sl
	opt/diamond/modeltech/linuxloem/libswiftpli.sl
	opt/diamond/modeltech/linuxloem/libuinfo.so
	opt/diamond/modeltech/linuxloem/libwlf.so
	opt/diamond/modeltech/linuxloem/memory_interposer.so
	opt/diamond/modeltech/linuxloem/mgls/bin/mgcld
	opt/diamond/modeltech/linuxloem/mitcl/libmitcl.so
	opt/diamond/modeltech/linuxloem/mtiRPC/libmtiRPC.so
	opt/diamond/modeltech/linuxloem/nlviewST.so
	opt/diamond/modeltech/linuxloem/profile_system.so
	opt/diamond/modeltech/linuxloem/rmdb/librmdb.so
	opt/diamond/modeltech/linuxloem/vlm
	opt/diamond/modeltech/linuxloem/vsimk
	opt/diamond/synpbase/linux_a_64/c_hdl
	opt/diamond/synpbase/linux_a_64/c_structver
	opt/diamond/synpbase/linux_a_64/c_ver
	opt/diamond/synpbase/linux_a_64/c_vhdl
	opt/diamond/synpbase/linux_a_64/comp_baseunittest
	opt/diamond/synpbase/linux_a_64/concintegtests
	opt/diamond/synpbase/linux_a_64/lib/libxerces-c-3.1.so
	opt/diamond/synpbase/linux_a_64/mbin/synbatch
	opt/diamond/synpbase/linux_a_64/mbin/synplify
	opt/diamond/synpbase/linux_a_64/raw2fsdb
	opt/diamond/synpbase/linux_a_64/syn_nfilter"

src_unpack() {
    rpm_src_unpack ${A}
}

src_install() {
    insinto /opt/diamond
    doins -r usr/local/diamond/${MY_PV}/.

    local tarballs="bin embedded_source modeltech cae_library examples synpbase data ispfpga tcltk"
    for tarball in ${tarballs}; do
	tar xzf usr/local/diamond/${MY_PV}/${tarball}/${tarball}.tar.gz \
	    -C ${D}/opt/diamond/${tarball} \
	    --no-same-owner
	rm ${D}/opt/diamond/${tarball}/${tarball}.tar.gz
    done

    # Do the sp1 upgrade
    local sp_dirs="bin cae_library data docs embedded_source examples ispfpga modeltech module synpbase tcltk"
    for dir in ${sp_dirs}; do
	cp -r -f usr/local/diamond/${MY_PV}/sp/${dir}/. ${D}/opt/diamond/${dir}
    done
    rm -rf ${D}/opt/diamond/sp

    convert ${D}/opt/diamond/docs/webhelp/eng/connect/Lattice_Icon.ico ${T}/lattice.png
    doicon ${T}/lattice.png

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
