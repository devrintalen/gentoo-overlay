# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: The comments in this file are for instruction and documentation.
# They're not meant to appear with your final, production ebuild.  Please
# remember to remove them before submitting or committing your ebuild.  That
# doesn't mean you can't add your own comments though.

# The EAPI variable tells the ebuild format in use.
# It is suggested that you use the latest EAPI approved by the Council.
# The PMS contains specifications for all EAPIs. Eclasses will test for this
# variable if they need to use features that are not universal in all EAPIs.
# If an eclass doesn't support latest EAPI, use the previous EAPI instead.
EAPI=7


# inherit lists eclasses to inherit functions from. For example, an ebuild
# that needs the eautoreconf function from autotools.eclass won't work
# without the following line:
inherit rpm desktop xdg-utils

# Eclasses tend to list descriptions of how to use their functions properly.
# Take a look at the eclass/ directory for more examples.

# Short one-line description of this package.
DESCRIPTION="Lattice Diamond FPGA development environment"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://www.latticesemi.com/latticediamond"

# Point to any required sources; these will be automatically downloaded by
# Portage.
SRC_URI="diamond_3_12-base-240-2-x86_64-linux.rpm"

# Source directory; the dir where the sources can be found (automatically
# unpacked) inside ${WORKDIR}.  The default value for S is ${WORKDIR}/${P}
# If you don't need to change it, leave the S= line out of the ebuild
# to keep it tidy.
S="${WORKDIR}"


# License of the package.  This must match the name of file(s) in the
# licenses/ directory.  For complex license combination see the developer
# docs on gentoo.org for details.
LICENSE="lattice.txt"

# The SLOT variable is used to tell Portage if it's OK to keep multiple
# versions of the same package installed at the same time.  For example,
# if we have a libfoo-1.2.2 and libfoo-1.3.2 (which is not compatible
# with 1.2.2), it would be optimal to instruct Portage to not remove
# libfoo-1.2.2 if we decide to upgrade to libfoo-1.3.2.  To do this,
# we specify SLOT="1.2" in libfoo-1.2.2 and SLOT="1.3" in libfoo-1.3.2.
# emerge clean understands SLOTs, and will keep the most recent version
# of each SLOT and remove everything else.
# Note that normal applications should use SLOT="0" if possible, since
# there should only be exactly one version installed at a time.
# Do not use SLOT="", because the SLOT variable must not be empty.
SLOT="0"

# Using KEYWORDS, we can record masking information *inside* an ebuild
# instead of relying on an external package.mask file.  Right now, you
# should set the KEYWORDS variable for every ebuild so that it contains
# the names of all the architectures with which the ebuild works.
# All of the official architectures can be found in the arch.list file
# which is in the profiles/ directory.  Usually you should just set this
# to "~amd64".  The ~ in front of the architecture indicates that the
# package is new and should be considered unstable until testing proves
# its stability.  So, if you've confirmed that your ebuild works on
# amd64 and ppc, you'd specify:
# KEYWORDS="~amd64 ~ppc"
# Once packages go stable, the ~ prefix is removed.
# For binary packages, use -* and then list the archs the bin package
# exists for.  If the package was for an x86 binary package, then
# KEYWORDS would be set like this: KEYWORDS="-* x86"
# Do not use KEYWORDS="*"; this is not valid in an ebuild context.
KEYWORDS="~amd64"

# Comprehensive list of any and all USE flags leveraged in the ebuild,
# with some exceptions, e.g., ARCH specific flags like "amd64" or "ppc".
# Not needed if the ebuild doesn't use any USE flags.
#IUSE="gnome X"

# A space delimited list of portage features to restrict. man 5 ebuild
# for details.  Usually not needed.
RESTRICT="fetch strip"


# Run-time dependencies. Must be defined to whatever this depends on to run.
# Example:
#    ssl? ( >=dev-libs/openssl-1.0.2q:0= )
#    >=dev-lang/perl-5.24.3-r1
# It is advisable to use the >= syntax show above, to reflect what you
# had installed on your system when you tested the package.  Then
# other users hopefully won't be caught without the right version of
# a dependency.
RDEPEND="dev-lang/python:2.7"


# Build-time dependencies that need to be binary compatible with the system
# being built (CHOST). These include libraries that we link against.
# The below is valid if the same run-time depends are required to compile.
#DEPEND="${RDEPEND}"

# Build-time dependencies that are executed during the emerge process, and
# only need to be present in the native build system (CBUILD). Example:
#BDEPEND="virtual/pkgconfig"

QA_PREBUILT="opt/diamond/modeltech/linuxloem/mgls/bin/mgcld
	opt/diamond/modeltech/linuxloem/vlm
	opt/diamond/modeltech/linuxloem/libmtipli.so
	opt/diamond/modeltech/linuxloem/vsimk
	opt/diamond/synpbase/linux_a_64/c_hdl
	opt/diamond/synpbase/linux_a_64/c_structver
	opt/diamond/synpbase/linux_a_64/c_ver
	opt/diamond/synpbase/linux_a_64/c_vhdl
	opt/diamond/synpbase/linux_a_64/lib/libxerces-c-3.1.so
	opt/diamond/synpbase/linux_a_64/mbin/synbatch
	opt/diamond/synpbase/linux_a_64/mbin/synplify
	opt/diamond/synpbase/linux_a_64/syn_nfilter
	opt/diamond/data/vmdata/drivers/ftdiusbdriver/libftd2xx.so.0.4.13
	opt/diamond/modeltech/linuxloem/mitcl/libmitcl.so
	opt/diamond/modeltech/linuxloem/nlviewST.so
	opt/diamond/modeltech/linuxloem/rmdb/librmdb.so
	opt/diamond/modeltech/linuxloem/mtiRPC/libmtiRPC.so
	opt/diamond/modeltech/linuxloem/libswiftpli.sl
	opt/diamond/modeltech/linuxloem/libmtipli.so
	opt/diamond/modeltech/linuxloem/QuestaCppOverride.so
	opt/diamond/modeltech/linuxloem/memory_interposer.so
	opt/diamond/modeltech/linuxloem/profile_system.so
	opt/diamond/modeltech/linuxloem/libsm.sl
	opt/diamond/modeltech/linuxloem/libhm.sl
	opt/diamond/modeltech/linuxloem/libwlf.so
	opt/diamond/modeltech/linuxloem/libuinfo.so"

src_unpack() {
    rpm_src_unpack ${A}
}


# The following src_configure function is implemented as default by portage, so
# you only need to call it if you need a different behaviour.
#src_configure() {
	# Most open-source packages use GNU autoconf for configuration.
	# The default, quickest (and preferred) way of running configure is:
	#econf
	#
	# You could use something similar to the following lines to
	# configure your package before compilation.  The "|| die" portion
	# at the end will stop the build process if the command fails.
	# You should use this at the end of critical commands in the build
	# process.  (Hint: Most commands are critical, that is, the build
	# process should abort if they aren't successful.)
	#./configure \
	#	--host=${CHOST} \
	#	--prefix=/usr \
	#	--infodir=/usr/share/info \
	#	--mandir=/usr/share/man || die
	# Note the use of --infodir and --mandir, above. This is to make
	# this package FHS 2.2-compliant.  For more information, see
	#   https://wiki.linuxfoundation.org/lsb/fhs
#}

# The following src_compile function is implemented as default by portage, so
# you only need to call it, if you need different behaviour.
#src_compile() {
	# emake is a script that calls the standard GNU make with parallel
	# building options for speedier builds (especially on SMP systems).
	# Try emake first.  It might not work for some packages, because
	# some makefiles have bugs related to parallelism, in these cases,
	# use emake -j1 to limit make to a single process.  The -j1 is a
	# visual clue to others that the makefiles have bugs that have been
	# worked around.

	#emake
#}

src_install() {
    insinto /opt/diamond
    doins -r usr/local/diamond/${PV}/.

    local tarballs="bin embedded_source modeltech cae_library examples \
    	  	synpbase data ispfpga tcltk"
    for tarball in ${tarballs}; do
	tar xzf usr/local/diamond/${PV}/${tarball}/${tarball}.tar.gz \
	    -C ${D}/opt/diamond/${tarball} \
	    --no-same-owner
	rm ${D}/opt/diamond/${tarball}/${tarball}.tar.gz
    done

    # local execbit
    # mapfile -t execbit < <(find usr/local/diamond/${PV} -type f -perm /+x -printf '/opt/diamond/%P\n' || die)
    # for file in "${execbit[@]}"; do
    # 	fperms +x "${file}"
    # done

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
