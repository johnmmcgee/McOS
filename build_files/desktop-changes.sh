#!/usr/bin/env bash

set -euox pipefail

echo "Tweaking existing desktop config..."

if [[ ${IMAGE} =~ bluefin|bazzite ]]; then
  rsync -rvKL /ctx/system_files/silverblue/ /

  systemctl enable dconf-update.service 
  systemctl enable rpm-ostree-countme.timer
  systemctl enable podman.socket 
  fc-cache -f /usr/share/fonts/inputmono 
  fc-cache -f /usr/share/fonts/outputsans 
  if [ ! -f /etc/systemd/user.conf ]; then cp /usr/lib/systemd/user.conf /etc/systemd/; fi 
  if [ ! -f /etc/systemd/system.conf ]; then cp /usr/lib/systemd/system.conf /etc/systemd/; fi 
  sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf 
  sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf 
  chmod a+x /usr/share/ublue-os/firstboot/*.sh 
  rm -f /usr/share/applications/htop.desktop 
  rm -f /usr/share/applications/nvtop.desktop 

  # custom gnome overrides
  mkdir -p /tmp/ublue-schema-test && \
  find /usr/share/glib-2.0/schemas/ -type f ! -name "*.gschema.override" -exec cp {} /tmp/ublue-schema-test/ \; && \
  cp /usr/share/glib-2.0/schemas/*-mcos-modifications.gschema.override /tmp/ublue-schema-test/ && \
  echo "Running error test for mcos gschema override. Aborting if failed." && \
  glib-compile-schemas --strict /tmp/ublue-schema-test || exit 1 && \
  echo "Compiling gschema to include mcos setting overrides" && \
  glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null
fi
