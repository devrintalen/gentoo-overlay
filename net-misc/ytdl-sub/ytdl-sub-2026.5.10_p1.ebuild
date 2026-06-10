# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

# Upstream uses PEP 440 post-releases (e.g. 2026.5.10.post1) and ships the
# PEP 625 normalized sdist (ytdl_sub-*). Map Gentoo's _p suffix back to .post
# and reconstruct the normalized name for SRC_URI/S.
MY_PN="ytdl_sub"
MY_PV="${PV/_p/.post}"

DESCRIPTION="Automate downloading and metadata generation with yt-dlp"
HOMEPAGE="
	https://github.com/jmbannon/ytdl-sub
	https://pypi.org/project/ytdl-sub/
"
SRC_URI="https://files.pythonhosted.org/packages/source/${PN:0:1}/${PN}/${MY_PN}-${MY_PV}.tar.gz"
S="${WORKDIR}/${MY_PN}-${MY_PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=net-misc/yt-dlp-2026.3.17
	dev-python/colorama[${PYTHON_USEDEP}]
	dev-python/mediafile[${PYTHON_USEDEP}]
	dev-python/mergedeep[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
