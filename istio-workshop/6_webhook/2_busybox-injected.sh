#!/bin/bash

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

istioctl kube-inject -f "$script_dir"/busybox.yaml > "$script_dir"/busybox-injected.yaml

# diff-so-fancy "$script_dir"/busybox.yaml "$script_dir"/busybox-injected.yaml
diff "$script_dir"/busybox.yaml "$script_dir"/busybox-injected.yaml
