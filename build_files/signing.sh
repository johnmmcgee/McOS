#!/usr/bin/bash

set -eoux pipefail

# Signing
mkdir -p /etc/containers
mkdir -p /etc/pki/containers
mkdir -p /etc/containers/registries.d/

if [ -f /usr/etc/containers/policy.json ]; then
  cp /usr/etc/containers/policy.json /etc/containers/policy.json
fi

cat <<<"$(jq '.transports.docker |=. + {
   "ghcr.io/johnmmcgee/mcos": [
    {
        "type": "sigstoreSigned",
        "keyPath": "/etc/pki/containers/mcos.pub",
        "signedIdentity": {
            "type": "matchRepository"
        }
    }
]}' <"/etc/containers/policy.json")" >"/tmp/policy.json"
cp /tmp/policy.json /etc/containers/policy.json
cp /ctx/cosign.pub /etc/pki/containers/mcos.pub
tee /etc/containers/registries.d/mcos.yaml <<EOF
docker:
  ghcr.io/johnmmcgee/mcos:
    use-sigstore-attachments: true
EOF

mkdir -p /usr/etc/containers/
cp /etc/containers/policy.json /usr/etc/containers/policy.json
