#!/usr/bin/env bash
set -euo pipefail
cmd=${1:-help}

case "$cmd" in
  doctor)     (cd ios && bundle install); (cd ios && bundle exec fastlane doctor);;
  pods)       (cd ios && pod install);;
  build)      (cd ios && bundle install); (cd ios && bundle exec fastlane build);;
  beta)       (cd ios && bundle install); (cd ios && bundle exec fastlane beta);;
  *)
    echo "Usage: scripts/ios.sh [doctor|pods|build|beta]"
  ;;
esac
