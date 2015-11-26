[Unreleased] ([unreleased])
---------------------------
* remove assets submodule that should be added in the parent project (#3)
* optionally use NFS for synced_folders
* make ssh connection configurable via nodes.yaml
* make extra disks configurable
* use all cores by default, use 1/4 of overall RAM

v1.3.0 (2015-09-13)
-------------------
* make forwarded ports configurable (thanks to @johscheuer)

v1.2.0 (2015-08-24)
-------------------
* add linode provider support
* add digital ocean provider support

v1.1.1 (2015-06-21)
-------------------
* maintenance relase, updated submodules

v1.1.0 (2015-05-14)
-------------------
* disable default synced folder
* manage cpus & memory
* provide env vars for provision scripts
* rename share/ to shared/ everywhere
* enable/disable gui (headless VM mode)

v1.0.0 (2015-04-22)
-------------------
* support rex git install
* improve provisioning
* add assets git module
* allow atlas hosted base boxes, make it possible to specify base box url manually
* support puppet dist install

v0.1 (2015-03-21)
-----------------
* initial release
