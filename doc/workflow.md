# Workflow

#### **kube-spawn-dir**
`/var/lib/kube-spawn` by default, can be set with `--dir`

#### **cluster-dir**
`<kube-spawn-dir>/default` by default, can be set with `--cluster-name`

## `create`

* _check provided config_ (not implemented)
* generate a config from defaults in `pkg/config/defaults.go`
* if we don't run with `--dev` download the needed binaries
  - `kubelet`, `kubeadm`, `kubectl`
* download `socat` (see #105)
* check/setup the host environment for requirements:
  - base image available (download if not and using default - `coreos`), can be set with `--image`
  - filesystem of **kube-spawn-dir** supports overlayfs
  - cni networking
  - modprobe `nf_conntrack`
  - set iptables rules for cni
  - selinux
  - _check version of CoreOS image_ (about to be removed)
* generate scripts and configs (using `pkg/script`)
* write config to **kube-spawn-dir**

To make files from the host available to the machines of the cluster we use the [`--overlay`][1] and [`--bind`][2] options of
`systemd-nspawn`.

[1]: https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html#--overlay=
[2]: https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html#--bind=

Under the **cluster-dir** you can find a directory called `rootfs`, as well as directories for every machine of the
cluster containing a `rootfs` directory as well.
Their subdirectories get overlayed on running `kube-spawn start`, with the machine dir being the upper-most, meaning all
modified files get written to it.

It is important that only `/etc`, `/opt` and `/bin` can be used.

Files and directories can also be bindmounted by editing the `kspawn.toml` file found in the **cluster-dir**.
It contains cluster-wide and per-machine `bindmount` sections for *read-write* and *read-only* bind.

_**[!]** the other commands load the configuration from **kube-spawn-dir** , this means they will not work without it_

## `start`

* start *n* machines, can be set with `--nodes` on `create`
*
* run:
  - `kubeadm init` on the first machine
  - `kubeadm join` on the rest

## `stop`

* stop running nodes
* no cleanup

## `restart`

* run stop & start

## `destroy`

* run stop
* remove **cluster-dir**
* remove cni networks created by `cnispawn`
