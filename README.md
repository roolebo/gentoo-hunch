# gentoo-hunch

A Gentoo overlay with hunch, built from git:

- `app-misc/hunch-host`: hunch-host, with its user unit, and the native
  messaging host that lets Firefox's extension reach it
- `www-plugins/firefox-hunch`: the extension, for all users

Its branch `hosts` builds the multihost series, from the branches
`hosts` of hunch and firefox-hunch, which are rewritten while under
review.

    cat > /etc/portage/repos.conf/hunch.conf << EOF
    [hunch]
    location = /var/db/repos/hunch
    sync-type = git
    sync-uri = https://github.com/roolebo/gentoo-hunch.git
    sync-git-clone-extra-opts = --branch hosts
    EOF
    emaint sync -r hunch
    printf '%s **\n' app-misc/hunch-host www-plugins/firefox-hunch \
        > /etc/portage/package.accept_keywords/hunch
    emerge app-misc/hunch-host www-plugins/firefox-hunch

Live ebuilds have no keywords, hence the `**`. To build what the
branches hold now:

    emerge -1 app-misc/hunch-host www-plugins/firefox-hunch

USE flags of hunch-host:

- `browser`: serve the browser at this seat, and link to the hosts the
  seat allows
- `compute`: run speech models here, on the CPU; a weak host leaves it
  off and transcribes on another host
- `seat`: take dictation at this host, with its keys and microphone
- `gnome`: GNOME Shell's extension, which types the dictation into
  GNOME's windows and shows the seat in the top bar
