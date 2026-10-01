# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="A Qt platform abstraction for Arcan"
HOMEPAGE="https://codeberg.org/vimpostor/qtarcan"
LICENSE="|| ( GPL-2.0 GPL-3.0 LGPL-3.0 )"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/vimposter/${PN}.git"
else
	SRC_URI="https://codeberg.org/vimpostor/${PN}/archive/v${PV}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${PN}"
fi

SLOT="6"
RDEPEND="
	arcan-base/arcan
	dev-qt/qtbase:6=[gui,opengl]
"
DEPEND="${RDEPEND}"

# should be able to handle more targets than just amd64 multilib now
PATCHES=(
	"${FILESDIR}/installdir.patch"
)

src_configure() {
	local mycmakeargs=(
		-DTARGET_QT_VERSION=${SLOT}
	)

	cmake_src_configure
}
