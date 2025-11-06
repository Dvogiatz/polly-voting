#!/usr/bin/env bash
# Render build script

set -e

echo "Installing dependencies..."
mix deps.get --only prod

echo "Compiling dependencies..."
mix deps.compile

echo "Building assets..."
mix assets.deploy

echo "Digesting static files..."
mix phx.digest

echo "Build complete!"
