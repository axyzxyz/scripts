#!/bin/bash
curl https://127.0.0.1:6443/healthz -k -s -m 2 &>/dev/null ||exit 1