#!/bin/sh

set -e

echo "kubernetes" | passwd --stdin root

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install \
	bind-utils \
	docker-1.10.3 \
	ebtables \
	ethtool \
	iproute \
	iptables-services \
	jq \
	less \
	netcat \
	net-tools \
	openssh-server \
	socat \
	strace \
	tmux \
	util-linux \
	wget

cat >>/etc/sysconfig/docker <<-EOF
INSECURE_REGISTRY='--insecure-registry=10.22.0.1:5000'
EOF

cat >/etc/sysconfig/docker-storage <<-EOF
DOCKER_STORAGE_OPTIONS="--storage-driver overlay"
EOF

cat >/etc/sysconfig/docker-storage-setup <<-EOF
STORAGE_DRIVER="overlay"
EOF

systemctl daemon-reload || true
systemctl enable docker.service
systemctl enable sshd.service

mkdir -p /etc/kubeadm
cat >/etc/kubeadm/kubeadm.yml <<-EOF
AuthorizationMode: AlwaysAllow
KubernetesVersion: latest
EOF

cat >>/etc/systemd/system/kubelet.service.d/20-kubeadm-extra-args.conf <<-EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=cgroupfs"
EOF
