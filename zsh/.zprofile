# Homebrew (Apple Silicone)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Visual Studio Code
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
alias code='/usr/bin/code'

# Setting up kubeconfig to manage homelab-k3s
export KUBECONFIG=~/.kube/config-homelab-k3s

# BookStack Homelab remote management
export BOOKSTACK_URL="https://docs.local.thomasvoishere.com"
export BOOKSTACK_TOKEN_ID="mHyou2Z2EDtc7YbS7r9n2g9fhQud7Xpe"
export BOOKSTACK_TOKEN_SECRET="JLxUEc6x8vULYNOIOvGzage7222J8sJH"
