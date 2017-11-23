BIN = kube-spawn
DOCKERIZED ?= y
DOCKER_TAG ?= latest
PREFIX ?= /usr
BINDIR ?= ${PREFIX}/bin
UID=$(shell id -u)

.PHONY: all clean dep install

VERSION=$(shell git describe --tags --always --dirty)

ifeq ($(DOCKERIZED),y)
all:
	docker build -t kube-spawn-build:$(DOCKER_TAG) -f Dockerfile.build .
	docker run --rm \
		-v `pwd`:/go/src/github.com/kinvolk/kube-spawn:Z \
		--user $(UID):$(UID) \
		kube-spawn-build
else
all:
	go build -o cni-noop ./cmd/cni-noop
	go build -o cnispawn ./cmd/cnispawn
	go build -o kube-spawn-runc ./cmd/kube-spawn-runc
	go build -o kube-spawn \
		-ldflags "-X main.version=$(VERSION)" \
		./cmd/kube-spawn
endif

update-vendor: | dep
	dep ensure
dep:
	@which dep || go get -u github.com/golang/dep/cmd/dep

clean:
	rm -f \
		cni-noop \
		cnispawn \
		kube-spawn \
		kube-spawn-runc

install:
	install cni-noop cnispawn kube-spawn kube-spawn-runc "$(BINDIR)"
