# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

MY_PN="glfw-arcan"
SNAPSHOT="55821e787d1e94f09de3cbeefdf0e66f4221c71e"

DESCRIPTION="Portable OpenGL FrameWork"
HOMEPAGE="https://www.codeberg.org/eternaldankness/${MY_PN}"
SRC_URI="https://codeberg.org/eternaldankness/${MY_PN}/archive/${SNAPSHOT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc64 ~riscv ~x86"
IUSE="arcan wayland X"

# Most are dlopen'd so use strings or check the source:
# grep -Eiro '[a-z0-9-]+\.so\.[0-9]+'
DEPEND="
	wayland? (
		dev-libs/wayland[${MULTILIB_USEDEP}]
		dev-libs/wayland-protocols
	)
	X? (
		x11-base/xorg-proto
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXcursor[${MULTILIB_USEDEP}]
		x11-libs/libXi[${MULTILIB_USEDEP}]
		x11-libs/libXinerama[${MULTILIB_USEDEP}]
		x11-libs/libxkbcommon[${MULTILIB_USEDEP}]
		x11-libs/libXrandr[${MULTILIB_USEDEP}]
	)
"
RDEPEND="
	${DEPEND}
	media-libs/libglvnd[X?,${MULTILIB_USEDEP}]
	arcan? (
		arcan-base/arcan
	)
	wayland? (
		gui-libs/libdecor[${MULTILIB_USEDEP}]
	)
	X? (
		x11-libs/libXrender[${MULTILIB_USEDEP}]
		x11-libs/libXxf86vm[${MULTILIB_USEDEP}]
	)
"
BDEPEND="
	wayland? (
		dev-util/wayland-scanner
		kde-frameworks/extra-cmake-modules
	)
"

PATCHES=(
	"${FILESDIR}/pkgconfig.patch"
)

src_configure() {
	local mycmakeargs=(
		-DGLFW_BUILD_EXAMPLES=no
		-DGLFW_BUILD_WAYLAND=$(usex wayland)
		-DGLFW_BUILD_ARCAN=$(usex arcan)
		-DGLFW_BUILD_X11=$(usex X)
	)

	cmake-multilib_src_configure
}
