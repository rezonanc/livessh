#!/usr/bin/env bash

. ./vars
set -e

sudo ../contrib/mkimage.sh -t "${DEBOOTSTRAP_IMAGE_TAG}" debootstrap --include=ubuntu-minimal --components=main,universe,multiverse "${RELEASE}" "http://lt.archive.ubuntu.com/ubuntu"
