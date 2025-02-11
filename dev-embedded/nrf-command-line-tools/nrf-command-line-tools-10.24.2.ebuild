EAPI=7

DESCRIPTION="nRF utilties for nRF51, nRF52, nRF53, and nRF91 series devices."
HOMEPAGE="https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools"
SRC_URI="https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools-10.24.2_linux-amd64.tar.gz"

LICENSE="Nordic-Non-Commercial"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-embedded/segger-jlink"

S="${WORKDIR}/nrf-command-line-tools"

src_unpack() {
	default
}

src_install() {
	dodir /opt/nrf-command-line-tools/bin
	cp "${S}/bin/"* "${D}/opt/nrf-command-line-tools/bin/"
	dosym /opt/nrf-command-line-tools/bin/nrfjprog /usr/bin/nrfjprog
	dosym /opt/nrf-command-line-tools/bin/mergehex /usr/bin/mergehex

	dodir /opt/nrf-command-line-tools/share
	cp -r "${S}/share/"* "${D}/opt/nrf-command-line-tools/share/"

	cp -r "${S}/python/"* "${D}/opt/nrf-command-line-tools/python/"

	dolib.so "${S}/lib/"*

	doheader "${S}/include"/*
}
