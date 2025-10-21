# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake

DESCRIPTION="A powerful and versatile multimedia development framework"
HOMEPAGE="https://arcan-fe.com/"
LICENSE="BSD-3-Clause GPL-2.0-or-later"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/letoram/${PN}.git"
else
	SRC_URI="https://github.com/letoram/${PN}/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

SLOT="0"

# Pick a better name for the hybrid-sdl support flag than nested
IUSE="wayland +nested -ffmpeg"

# More to figure out likely
RDEPEND="
	nested? ( media-libs/libsdl2 )
"
DEPEND="${RDEPEND}
	dev-lang/luajit
	x11-libs/libdrm
	x11-libs/libxkbcommon
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/openal
	wayland? ( dev-libs/wayland )
	ffmpeg? ( <media-libs/ffmpeg-8 )
"
BDEPEND="dev-build/cmake"

src_prepare() {
	# ???????? What the FUCK
	cd "${S}/src"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDISTR_TAG='Gentoo Linux'
		-DBUILD_PRESET="everything"
		-DVIDEO_PLATFORM=egl-dri
		-DHYBRID_SDL=$(use nested && echo ON || echo OFF)
		-DDISABLE_WAYLAND=$(use wayland && echo OFF || echo ON)
		-DDISABLE_FSRV_ENCODE=$(use ffmpeg && echo OFF || echo ON)
	)
	cmake_src_configure
}

