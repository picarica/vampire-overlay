# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

PYTHON_COMPAT=( python{3_6,3_7,3_8} )

inherit git-r3 eutils python-single-r1

DESCRIPTION="*booru style image collector and viewer"
HOMEPAGE="http://hydrusnetwork.github.io/hydrus/ https://github.com/hydrusnetwork/hydrus"
EGIT_REPO_URI="https://github.com/hydrusnetwork/hydrus.git"
IUSE="+ffmpeg miniupnpc +lz4 socks matplotlib"

LICENSE="WTFPL"
SLOT="0"
KEYWORDS=""

RDEPEND="$(python_gen_cond_dep '
		media-libs/opencv[python,${PYTHON_MULTI_USEDEP}]

		dev-python/wxpython:4.0[${PYTHON_MULTI_USEDEP}]
		dev-python/beautifulsoup:4[${PYTHON_MULTI_USEDEP}]
		dev-python/twisted[${PYTHON_MULTI_USEDEP}]
		dev-python/requests[${PYTHON_MULTI_USEDEP}]
		dev-python/numpy[${PYTHON_MULTI_USEDEP}]
		dev-python/lxml[${PYTHON_MULTI_USEDEP}]
		dev-python/pillow[${PYTHON_MULTI_USEDEP}]
		dev-python/pyyaml[${PYTHON_MULTI_USEDEP}]
		dev-python/psutil[${PYTHON_MULTI_USEDEP}]
		dev-python/send2trash[${PYTHON_MULTI_USEDEP}]
		dev-python/chardet[${PYTHON_MULTI_USEDEP}]
		dev-python/html5lib[${PYTHON_MULTI_USEDEP}]
		dev-python/nose[${PYTHON_MULTI_USEDEP}]
		dev-python/six[${PYTHON_MULTI_USEDEP}]

		sys-apps/coreutils
		x11-libs/gtkglext

		ffmpeg? ( virtual/ffmpeg )
		miniupnpc? ( net-libs/miniupnpc )
		lz4? ( dev-python/lz4[${PYTHON_MULTI_USEDEP}] )
		socks? (
				|| ( dev-python/requests[socks5,${PYTHON_MULTI_USEDEP}]
					dev-python/PySocks[${PYTHON_MULTI_USEDEP}] )
		)
		matplotlib? ( dev-python/matplotlib[${PYTHON_MULTI_USEDEP}] )
	')
	${PYTHON_DEPS}"

DEPEND="${RDEPEND}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	eapply "${FILESDIR}/paths-in-opt.patch"

	eapply_user

	# remove useless directories and files due to paths-in-opt.patch
	rm Readme.txt
	rm -r db/

	chmod a-x include/*.py
	rm -f "include/pyconfig.h"
	rm -f "include/Test"*.py
	rm -f "test.py"
	rm -rf "static/testing"
}

src_compile() {
	python3 -OO -m compileall -f .
}

src_install() {
	DOC="/usr/share/doc/${PF}"
	elog "Hydrus includes an excellent help, that can either be viewed at"
	elog "${DOC}/html/index.html"
	elog "or accessed through the hydrus help menu."

	DOCS="COPYING README.md"
	HTML_DOCS="${S}/help/"
	einstalldocs

	rm COPYING README.md
	rm -r help/
	ln -s "${DOC}/html" help

	use ffmpeg && ln -s "$(which ffmpeg)" bin/ffmpeg

	insopts -m0755
	insinto /opt/${PN}
	doins -r ${S}/* || die "Failed to move hydrus to opt."

	exeinto /usr/bin
	doexe "${FILESDIR}/hydrus-server"
	doexe "${FILESDIR}/hydrus-client"
}
