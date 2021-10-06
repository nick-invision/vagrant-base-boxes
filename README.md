# vagrant-base-boxes

Updated base Vagrant boxes for local development purposes. Based off [ramsey/macos-vagrant-box](https://github.com/ramsey/macos-vagrant-box) and [macinbox](https://github.com/bacongravy/macinbox).

All boxes are large (20GB+), so first `vagrant up` will take some time.

## macos-bigsur-base (v10.16)

Created from [macos-catalina-base](https://app.vagrantup.com/nick-invision/boxes/macos-catalina-base/versions/0.0.1) base image, so it shares the same configuration.

## macos-catalina-base (v10.15.7)

Includes homebrew, py3, and XCode CLI tools, as well as manually enabled `auto login` of the `vagrant` user.
