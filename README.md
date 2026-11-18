# hunch-gentoo

A Gentoo overlay with hunch-host, built from hunch's git.

    eselect repository add hunch git https://github.com/roolebo/hunch-gentoo.git
    emaint sync -r hunch
    echo 'app-misc/hunch-host **' > /etc/portage/package.accept_keywords/hunch-host
    emerge app-misc/hunch-host

A live ebuild has no keywords, hence the `**`.

To build a branch of another clone instead, e.g. one not pushed yet:

    cat > /etc/portage/env/hunch-local.conf << EOF
    EGIT_OVERRIDE_REPO_ROOLEBO_HUNCH=ssh://HOST/path/to/hunch
    EGIT_OVERRIDE_BRANCH_ROOLEBO_HUNCH=host
    EOF
    echo 'app-misc/hunch-host hunch-local.conf' >> /etc/portage/package.env

USE flags:

- `browser`: serve the browser at this seat, and link to the hosts the
  seat allows
- `compute`: run speech models here, on the CPU; a weak host leaves it
  off and transcribes on another host
