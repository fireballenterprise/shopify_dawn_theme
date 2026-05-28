#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Setup Ruby Virtual Environment
# Installs the project Ruby version via rbenv and activates it locally.
# -----------------------------------------------------------------------------
setup_ruby() {
  echo -e
  echo "INFO: Install Project Version of Ruby with Rbenv"
  project_ruby_version="$(cat .ruby-version)"
  echo "INFO: Project Ruby Version: $project_ruby_version"
  rbenv versions | grep -q "$project_ruby_version" || rbenv install "$project_ruby_version" || exit 1

  echo -e
  echo "INFO: Activating Virtual Environment"
  rbenv local "$project_ruby_version" || exit 1
}

# -----------------------------------------------------------------------------
# Install Tools (Homebrew)
# Installs required CLI tools via Homebrew, skipping any already present.
# -----------------------------------------------------------------------------
install_tools() {
  echo -e
  echo "INFO: Installing Tools (Homebrew)"

  if command -v actionlint &>/dev/null; then
    echo "INFO: actionlint already installed ($(actionlint --version 2>/dev/null || echo 'version unknown'))"
  else
    brew install actionlint
  fi

  if command -v shellcheck &>/dev/null; then
    echo "INFO: shellcheck already installed ($(shellcheck --version | grep version: || echo 'version unknown'))"
  else
    brew install shellcheck
  fi
}

# -----------------------------------------------------------------------------
# Install Ruby Libraries (Gemfile)
# Configures bundler and installs all project gems into .vendor/bundle.
# -----------------------------------------------------------------------------
install_libraries() {
  echo -e
  echo "INFO: Installing Libraries (Gemfile)"
  bundle config set --local path '.vendor/bundle'   # stores gems in ./vendor
  bundle config set --local binstubs .bin           # set binstubs directory
  bundle install                                    # install gems
  bundle binstubs --all --path=.bin                 # generate binstubs for all gems
  export PATH="$PWD/.bin:$PATH"
  echo "INFO: Ruby Version: $(ruby -v)"
  echo "INFO: Bundler Version: $(bundle -v)"
  echo 'RUN: export PATH="$PWD/.bin:$PATH"'
}

# -----------------------------------------------------------------------------
# Shopify CLI Environment Setup
# Prompts for store domain and theme access token, exports them for the session.
# -----------------------------------------------------------------------------
setup_shopify_env() {
  echo -e
  echo "INFO: Shopify CLI Environment Setup"
  echo "These values are used by 'shopify theme pull/push' and rake shopify tasks."
  echo "Values are exported for this session only — not written to any file."
  echo -e

  read -rp "Enter your Shopify store domain (e.g. mystore.myshopify.com): " shopify_store
  read -rsp "Enter your Shopify Theme Access token (from Shopify Admin > Apps > Theme Access): " shopify_token
  echo -e

  if [[ -n "$shopify_store" && -n "$shopify_token" ]]; then
    export SHOPIFY_FLAG_STORE="$shopify_store"
    export SHOPIFY_CLI_THEME_TOKEN="$shopify_token"
    echo "INFO: Shopify env vars exported for this session."
  else
    echo "WARN: Skipping Shopify env setup — one or both values were blank."
  fi
}

# -----------------------------------------------------------------------------
# Run
# -----------------------------------------------------------------------------
setup_ruby
install_tools
install_libraries
setup_shopify_env
