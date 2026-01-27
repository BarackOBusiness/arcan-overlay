# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit git-r3 cmake toolchain-funcs

DESCRIPTION="A Qt platform abstraction for Arcan"
HOMEPAGE="https://codeberg.org/vimpostor/qtarcan"
LICENSE="|| ( GPL-2.0 GPL-3.0 LGPL-3.0 )"

EGIT_REPO_URI="https://codeberg.org/vimpostor/qtarcan.git"
KEYWORDS="~amd64"
SLOT="6"

RDEPEND="
	arcan-base/arcan
	dev-qt/qtbase:6=[gui,opengl]
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/installdir.patch"
)

src_configure() {
	local mycmakeargs=(
		-DTARGET_QT_VERSION=$(ver_cut 1)
	)

	cmake_src_configure
}
