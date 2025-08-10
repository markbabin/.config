#!/bin/bash
CONFIG_DIR="$HOME/.config/aerospace"

# Check current config by reading the symlink target
current_target=$(readlink "$CONFIG_DIR/aerospace.toml")
case "$current_target" in
    *laptop*) current="laptop" ;;
    *external*) current="external" ;;
    *) current="unknown" ;;
esac

# Show current state and options
echo "Current: $current"
echo "1) Switch to laptop"  
echo "2) Switch to external"
read -p "Choose (1/2): " choice

# Switch config based on choice
case $choice in
    1) ln -sf aerospace-laptop.toml "$CONFIG_DIR/aerospace.toml" 
       echo "→ Switched to laptop config" 
       aerospace reload-config ;;
    2) ln -sf aerospace-external.toml "$CONFIG_DIR/aerospace.toml"
       echo "→ Switched to external config" 
       aerospace reload-config ;;
    *) echo "Invalid choice" ;;
esac