# Ubunut 16.04 dependencies 
sudo apt-get install automake autoconf  libtool gettext autotools-dev  intltool gperf  libcap-dev libmount-dev  xsltproc  xmlto -y 

# Setting up SystemD
git clone https://github.com/coreos/systemd
cd systemd
git checkout v231
./autogen.sh
./configure
make

# Setting up Kubernetes 
mkdir -p $GOPATH/src/k8s.io
cd $GOPATH/src/k8s.io
git clone https://github.com/kubernetes/kubernetes
git clone https://github.com/kubernetes/release

cd $GOPATH/src/k8s.io/kubernetes
build/run.sh make
cd cluster/images/hyperkube
make VERSION=latest

# Setting up Kubernetes with CNI 
mkdir -p $GOPATH/src/github.com/containernetworking
cd $GOPATH/src/github.com/containernetworking
git clone https://github.com/containernetworking/cni
cd cni
./build


sudo mkdir -p /etc/cni/net.d
sudo cat >/etc/cni/net.d/10-mynet.conf <<EOF
{
    "cniVersion": "0.2.0",
    "name": "mynet",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.22.0.0/16",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ]
    }
}
EOF
sudo cat >/etc/cni/net.d/99-loopback.conf <<EOF
{
    "cniVersion": "0.2.0",
    "type": "loopback"
}
EOF
```