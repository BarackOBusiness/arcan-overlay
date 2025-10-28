# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake

DESCRIPTION="A powerful and versatile multimedia development framework"
HOMEPAGE="https://arcan-fe.com/"
LICENSE="BSD-3-Clause GPL-2.0-or-later"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/letoram/${PN}.git"
else
	SRC_URI="https://github.com/letoram/${PN}/archive/refs/tags/${PV}.tar.gz"
	KEYWORDS="~amd64"
fi

SLOT="0"

VIDEO_PLATFORMS="+dri gles +sdl"
IUSE="${VIDEO_PLATFORMS}
	+audio camera +decode +encode nested wayland docs debug
"
# at least one video platform must be selected, egl-dri and egl-gles are mutually exclusive
# egl-gles and sdl are also mutually exclusive whereas egl-dri supports hybrid-sdl
REQUIRED_USE="
	|| ( dri gles sdl )
	gles? ( !dri !sdl )
	camera? ( decode )
"

DEPEND="
	dev-db/sqlite
	media-libs/libglvnd
	dev-lang/luajit
	media-libs/freetype
	media-libs/harfbuzz
	x11-libs/libxkbcommon
	dev-libs/libusb
	virtual/opengl[X]
	audio? ( media-libs/openal )
	camera? ( media-libs/libuvc )
	decode? (
		media-video/vlc
		app-accessibility/espeak-ng
		app-text/mupdf
	)
	encode? (
		media-video/ffmpeg
		media-libs/leptonica
		app-text/tesseract
	)
	wayland? ( dev-libs/wayland )
"
BDEPEND="
	dev-build/cmake
	docs? ( dev-lang/ruby )
"

# For LWA we're going to need to conditionally add a download for openal
# and unpack it into external during this phase
src_prepare() {
	cd "${S}"
	if ( use docs ); then
		cd "doc" && ruby docgen.rb mangen && cd ..
	fi
	cd "src"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDISTR_TAG='Gentoo Linux'
		-DCMAKE_BUILD_TYPE=$(usex debug "DebugTrace" "Release")
		-DAGP_PLATFORM=gl21
		-DAUDIO_PLATFORM=$(usex audio "openal" "stub")
		-DDISABLE_FSRV_DECODE=$(usex decode OFF ON)
		-DDISABLE_FSRV_ENCODE=$(usex encode OFF ON)
		-DDISABLE_WAYLAND=$(usex wayland OFF ON)
		-DENABLE_LWA=$(usex nested ON OFF)
	)

	if ( use dri ); then
		mycmakeargs+=(-DVIDEO_PLATFORM=egl-dri)
		use sdl && mycmakeargs+=(-DHYBRID_SDL=ON)
	elif ( use gles ); then
		mycmakeargs+=(-DVIDEO_PLATFORM=egl-gles)
	else
		mycmakeargs+=(-DVIDEO_PLATFORM=sdl2)
	fi
	cmake_src_configure
}

