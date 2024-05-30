# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit git-r3

DESCRIPTION="A powerful and versatile multimedia development framework"
HOMEPAGE="https://arcan-fe.com/"
LICENSE="BSD-3-Clause GPL-2.0-or-later"

# TODO: Make versioned
EGIT_REPO_URI="https://github.com/letoram/${PN}.git"
SLOT="0"

DEPEND="${RDEPEND} >=arcan-base/arcan-0.6.3"

src_install() {
	insinto /usr/share/arcan/appl
	doins -r durden
}
