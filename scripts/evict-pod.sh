#!/usr/bin/env bash

set -e

usage="Usage: $0 POD_ID [NAMESPACE] [API_URL]"

pod_id="$1"
namespace="$2"
api_url="$3"

if [[ -z "$namespace" ]]; then
    namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}')
    namespace="${namespace:-default}"
fi

api_url="${api_url:-127.0.0.1:8001}"

if [[ -z "$pod_id" ]]; then
    echo $usage
    exit 1
fi

echo "Attempting to evict pod $pod_id from namespace $namespace, api_url=$api_url"
echo

post_body="$(mktemp)"
cat > "$post_body" <<EOF
{
  "apiVersion": "policy/v1beta1",
  "kind": "Eviction",
  "metadata": {
    "name": "$pod_id",
    "namespace": "$namespace"
  }
}
EOF

curl \
    -H 'Content-type: application/json' \
    "http://$api_url/api/v1/namespaces/$namespace/pods/$pod_id/eviction" \
    -d @"$post_body"

echo

