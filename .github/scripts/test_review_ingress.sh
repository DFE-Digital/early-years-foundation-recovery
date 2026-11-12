#!/usr/bin/env bash
set -euo pipefail

docker build --tag recovery-review-ingress-check docker/review
docker run --rm --entrypoint sh recovery-review-ingress-check -ec '
  header="$(head -c 3072 /dev/zero | tr "\000" x)"
  printf "%s\n" \
    "server { listen 3000; location / { return 200 rails; } location = /large-login-redirect { add_header Content-Security-Policy \"$header\"; add_header Set-Cookie \"$header\"; return 302 /; } }" \
    "server { listen 4001; location / { return 200 simulator; } }" \
    > /etc/nginx/conf.d/test-backends.conf
  nginx -t
  nginx
  test "$(wget -qO- http://127.0.0.1:8080/)" = rails
  test "$(wget -qO- http://127.0.0.1:8080/users/sign-in)" = rails
  response="$(wget -SO- http://127.0.0.1:8080/large-login-redirect 2>&1)"
  echo "$response" | grep -q "302 "
  for path in authorize form-submit logout token userinfo .well-known/openid-configuration .well-known/jwks.json; do
    test "$(wget -qO- "http://127.0.0.1:8080/$path")" = simulator
  done
  for path in config config/ config/other; do
    response="$(wget -SO- "http://127.0.0.1:8080/$path" 2>&1 || true)"
    echo "$response" | grep -q "404 Not Found"
  done
  echo "All ingress routes passed; simulator configuration blocked"
'
