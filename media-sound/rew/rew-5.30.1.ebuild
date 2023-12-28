# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

DESCRIPTION="Room Acoustics Software"
HOMEPAGE="https://www.roomeqwizard.com/"
SRC_URI="https://www.roomeqwizard.com/installers/REW_linux_no_jre_$(ver_rs 1- _).sh"
LICENSE="rew"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND="virtual/jdk:1.8"


src_unpack() {
    mkdir "${WORKDIR}/${PF}"
    cp "${DISTDIR}/REW_linux_no_jre_$(ver_rs 1- _).sh" "${WORKDIR}/${PF}/"
}

src_prepare() {
    cd "${WORKDIR}/${PF}"

    addpredict /var/lib/portage/home/.java
    addpredict /usr/local/bin/roomeqwizard
    
    chmod +x "REW_linux_no_jre_$(ver_rs 1- _).sh"
    HOME=${HOME} ./"REW_linux_no_jre_$(ver_rs 1- _).sh" -q -console -dir "${S}" -nofilefailures
    eapply_user
}

src_install() {
    exeinto /opt/rew
    insinto /opt/rew
    
    doexe roomeqwizard
    doins *.jar
    doins -r .install4j
    doins roomeqwizard.vmoptions

    dolib.so libcsjsound_amd64.so


    doicon .install4j/roomeqwizard.png
    make_desktop_entry "/opt/rew/roomeqwizard %U" \
		       REW \
		       roomeqwizard \
		       "Audio;AudioVideo"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
