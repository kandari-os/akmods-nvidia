ARG FEDORA_RELEASE="${FEDORA_RELEASE:-41}"
ARG KMOD_NAME=nvidia
ARG KMOD_VERSION=
ARG KERNEL_VERSION=
ARG REPOSITORY_TYPE=release

FROM quay.io/fedora-ostree-desktops/base:${FEDORA_RELEASE} AS builder

ARG FEDORA_RELEASE
ARG KMOD_NAME
ARG KMOD_VERSION
ARG KERNEL_VERSION
ARG REPOSITORY_TYPE

COPY certs /tmp/certs
COPY scripts /tmp/scripts
COPY kmods/${KMOD_NAME}/scripts/build /tmp/scripts
COPY kmods/${KMOD_NAME}/rpm-specs /tmp/rpm-specs
COPY kmods/${KMOD_NAME}/files /tmp/files

RUN chmod +x /tmp/scripts/*.sh && \
    /tmp/scripts/setup.sh && \
    /tmp/scripts/00-prebuild.sh && \
    /tmp/scripts/01-build.sh && \
    /tmp/scripts/final.sh

RUN rpm -ql /rpms/*.rpm


FROM scratch AS artifacts

ARG KMOD_NAME

COPY kmods/${KMOD_NAME}/scripts/install /scripts
COPY --from=builder /rpms /rpms
COPY --from=builder /var/cache/akmods/nvidia-vars /info/nvidia-vars
