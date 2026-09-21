# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit cmake

DESCRIPTION="A powerful and versatile multimedia development framework"
HOMEPAGE="https://arcan-fe.com/"
LICENSE="BSD-3-Clause GPL-2.0-or-later"

if [[ ${PV} == 9999 ]]; then
	inherit fossil
	EFOSSIL_REPO_URI="https://chiselapp.com/user/letoram/repository/arcan"
else
	SRC_URI="https://chiselapp.com/user/letoram/repository/arcan/tarball/${PV}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

SLOT="0"

VIDEO_PLATFORMS="+dri gles +sdl"
AUDIO_PLATFORMS="+openal miniaudio"
IUSE="${VIDEO_PLATFORMS} ${AUDIO_PLATFORMS}
	camera +decode +encode +nested wayland docs debug
"
# at least one video platform must be selected, egl-dri and egl-gles are mutually exclusive
# egl-gles and sdl are also mutually exclusive whereas egl-dri supports hybrid-sdl
REQUIRED_USE="
	|| ( dri gles sdl )
	gles? ( !dri !sdl )
	?? ( openal miniaudio )
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
	openal? ( media-libs/openal )
	camera? ( media-libs/libuvc )
	decode? (
		<media-video/vlc-4.0
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

src_prepare() {
	cd "${S}"
	if ( use docs ); then
		cd "doc" && ruby docgen.rb mangen
		cd "${S}"
	fi
	cd "${S}/src"
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DDISTR_TAG='Gentoo Linux'
		-DCMAKE_BUILD_TYPE=$(usex debug "DebugTrace" "Release")
		-DAGP_PLATFORM=gl21
		-DVIDEO_PLATFORM=$(usex dri "egl-dri" $(usex gles "egl-gles" "sdl2"))
		-DHYBRID_SDL=$(usex dri $(usex sdl "ON" "OFF") "OFF")
		-DAUDIO_PLATFORM=$(usev openal || usev miniaudio || echo "stub")
		-DDISABLE_FSRV_DECODE=$(usex decode OFF ON)
		-DDISABLE_FSRV_ENCODE=$(usex encode OFF ON)
		-DDISABLE_WAYLAND=$(usex wayland OFF ON)
		-DENABLE_LWA=$(usex nested ON OFF)
	)
	cmake_src_configure
}

