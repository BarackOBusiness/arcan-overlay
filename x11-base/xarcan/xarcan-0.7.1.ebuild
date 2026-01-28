# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Patched variant of Xorg to run X applications under Arcan"
HOMEPAGE="https://codeberg.org/letoram/xarcan"

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://codeberg.org/letoram/xarcan"
	inherit git-r3
else
	SRC_URI="https://codeberg.org/letoram/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0"

# For now assume we only depend on arcan though that is certainly not correct
RDEPEND="
	=arcan-base/arcan-${PV}
"
DEPEND="
	${RDEPEND}
"

# Will conflict with existing xorg docs if applicable, I'll just remove them
# in hindsight I could've just overridden src_install but whatever, they both do the same thing
PATCHES=(
	"${FILESDIR}/nodocs.patch"
)
