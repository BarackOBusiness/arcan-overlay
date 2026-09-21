# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DESCRIPTION="A powerful and versatile multimedia development framework"
HOMEPAGE="https://arcan-fe.com/"
LICENSE="BSD-3-Clause GPL-2.0-or-later"

inherit fossil
EFOSSIL_REPO_URI="https://chiselapp.com/user/letoram/repository/durden"
SLOT="0"

DEPEND="=arcan-base/arcan-9999"

src_install() {
	insinto /usr/share/arcan/appl
	doins -r durden
}
