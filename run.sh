#!/bin/bash
# Quick launch script for Godot kart racing game

set -e

# Check if godot command is available
if ! command -v godot &> /dev/null; then
    echo "Error: 'godot' command not found in PATH"
    echo "Please install Godot 4.x or add it to your PATH"
    exit 1
fi

# Run the main scene
echo "Launching Mario Kart-style racing game..."
godot scenes/main.tscn
