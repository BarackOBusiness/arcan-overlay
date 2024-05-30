# Arcan Overlay
This is an overlay for Gentoo Linux that serves to organize packaging of Arcan and related accessories.

To add this overlay, first ensure you have `eselect-repository` and `dev-vcs/git` emerged, then use the following command as root:
```
eselect repository add arcan https://github.com/BarackOBusiness/arcan-overlay
```
Then sync the repository with
```
emerge --sync arcan
```
