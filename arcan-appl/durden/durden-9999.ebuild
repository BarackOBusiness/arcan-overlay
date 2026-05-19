# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DESCRIPTION="A powerful and versatile multimedia development framework"
HOMEPAGE="https://arcan-fe.com/"
LICENSE="BSD-3-Clause GPL-2.0-or-later"

# TODO: Make versioned
SRC_URI="https://chiselapp.com/user/letoram/repository/durden/tarball/master/durden-9999.tar.gz"
SLOT="0"

DEPEND=">=arcan-base/arcan-0.7.1"

src_install() {
	insinto /usr/share/arcan/appl
	doins -r durden
}
