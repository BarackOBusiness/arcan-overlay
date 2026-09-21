# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: fossil.eclass
# @MAINTAINER:
# Barack OBusiness <barackobusiness@proton.me>
# @SUPPORTED_EAPIS: 8 9
# @BLURB: Eclass for fetching and unpacking fossil repositories
# @DESCRIPTION:
# Eclass for maintaining live ebuilds using fossil as the upstream repository.

if [[ -z ${_FOSSIL_ECLASS} ]]; then
_FOSSIL_ECLASS=1

case ${EAPI} in
  8|9) ;;
  *) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

PROPERTIES+=" live"

BDEPEND="dev-vcs/fossil"

# @ECLASS_VARIABLE: EFOSSIL_STORE_DIR
# @USER_VARIABLE
# @DESCRIPTION:
# Storage directory for fossil clones.
# This is intended to be set by user in make.conf. Ebuilds must not set it.
# EFOSSIL_STORE_DIR=${DISTDIR}/fossil-src

# @ECLASS_VARIABLE: EFOSSIL_REPO_URL
# @REQUIRED
# @DESCRIPTION:
# URI to the repository. Only one URI for now, as per the git-r3 eclass it
# doesn't look too difficult to implement multiple fetches but just for the
# minimum viable eclass I'll hold off.

# @ECLASS_VARIABLE: EFOSSIL_BRANCH
# @DEFAULT_UNSET
# @DESCRIPTION:
# The branch name to checkout. If unset, the upstream default will be used.

# @ECLASS_VARIABLE: EFOSSIL_COMMIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# The tag name or commit identifier to check out. If unset. newest commit from
# the branch will be used.

# @ECLASS_VARIABLE: EVCS_OFFLINE
# @DEFAULT_UNSET
# @DESCRIPTION:
# If non-empty, this variable prevents any online operations.

# @FUNCTION: _fossil_store_path
# @USAGE: <repo-uri>
# @INTERNAL
# @DESCRIPTION:
# Print the path of the clone file for the given repository URI.
_fossil_store_path() {
  local uri=${1}
 	local id=${uri#*://}
	id=${id//[^[:alnum:]._-]/_}

  local distdir=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}
  : ${EFOSSIL_STORE_DIR:=${distdir}/fossil-src}

	printf '%s\n' "${EFOSSIL_STORE_DIR}/${id}.fossil"
}

# @FUNCTION: _fossil_env
# @INTERNAL
# @DESCRIPTION:
# Sandbox fossil global config into the build's temporary directory.
_fossil_env() {
  export FOSSIL_HOME=${T}/fossil-home
  mkdir -p "${FOSSIL_HOME}" || die "${FUNCNAME}: unable to create ${FOSSIL_HOME}"
}

# @FUNCTION: fossil_fetch
# @USAGE: [<repo-uri>]
# @description:
# Clones a remote fossil repository into the store, or pulls new artifacts if
# a clone already exists.
fossil_fetch() {
  debug-print-function ${FUNCNAME} "$@"

  local repo_uri=${1:-${EFOSSIL_REPO_URI}}
  [[ -n ${repo_uri} ]] || die "${FUNCNAME}: No URI provided and EFOSSIL_REPO_URI unset"

  local store=$(_fossil_store_path "${repo_uri}") || die
  local store_dir=${store%/*}

  _fossil_env

  addwrite "${store_dir}"
  if [[ ! -d ${store_dir} ]]; then
    (
      mkdir -p "${store_dir}"
    ) || die "${FUNCNAME}: unable to create ${store_dir}"
  fi

  if [[ -f ${store} ]]; then
    if [[ -n ${EVCS_OFFLINE} ]]; then
      einfo "EVCS_OFFLINE set: using existing clone ${store}"
    else
      einfo "Updating ${store} from ${repo_uri}"
      fossil pull "${repo_uri}" -R "${store}" --once \
        || die "${FUNCNAME}: pull from ${repo_uri} failed"
    fi
  elif [[ -n ${EVCS_OFFLINE} ]]; then
		eerror "A clone of the following repository is required to proceed:"
		eerror "  ${repo_uri}"
		eerror "However, network activity has been disabled using EVCS_OFFLINE and there"
		eerror "is no local clone available."
		die "No local clone of ${repo_uri}. Unable to proceed with EVCS_OFFLINE."
  else
    einfo "Cloning ${repo_uri} into ${store}"
    # Clone to a temporary file so an interrupted clone is never mistaken for
    # a usable repository on a subsequent run.
    rm -f "${store}.new" || die
    fossil clone --once "${repo_uri}" "${store}.new" \
      || die "${FUNCNAME}: clone of ${repo_uri} failed"
    mv "${store}.new" "${store}" || die
  fi
}

# @FUNCTION: fossil_checkout
# @USAGE: [<repo-uri> [<checkout-dir>]]
# @DESCRIPTION:
# Open a checkout of EFOSSIL_COMMIT or EFOSSIL_BRANCH from the local clone
# into the checkout directory, and set efossil_version.
fossil_checkout() {
  debug-print-function ${FUNCNAME} "$@"

  local repo_uri=${1:-${EFOSSIL_REPO_URI}}
  local out_dir=${2:-${WORKDIR}/${P}}
  [[ -n ${repo_uri} ]] || die "${FUNCNAME}: No URI provided and EFOSSIL_REPO_URI unset"

  local store=$(_fossil_store_path "${repo_uri}") || die
  [[ -f ${store} ]] || die "${FUNCNAME}: No clone at ${store}; was fossil_fetch run prior?"

  local version=${EFOSSIL_COMMIT:-${EFOSSIL_BRANCH}}

  _fossil_env

  mkdir -p "${out_dir}" || die
  # Using trunk in place of version here may be confusing to users when
  # upstream does not have a trunk branch, but it is probably the best
  # substitute for a default, tip would be incorrect.
  einfo "Checking out ${version:-trunk} into ${out_dir}"
  (
    [[ -n ${version} ]] && fossil open "${store}" "${version}" --workdir "${out_dir}"
    [[ ! -n ${version} ]] && fossil open "${store}" --workdir "${out_dir}"
  ) || die "${FUNCNAME}: unable to open ${store} ${version:-trunk} to ${out_dir}"
}

# @FUNCTION: fossil_src_unpack
# @DESCRIPTION:
# Fetch the repository and open a checkout of it.
fossil_src_unpack() {
  debug-print-function ${FUNCNAME} "$@"

  fossil_fetch
  fossil_checkout
}

fi

EXPORT_FUNCTIONS src_unpack
