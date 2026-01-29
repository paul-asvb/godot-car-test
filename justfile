# Godot Car Test - Build Commands

# Output directory for web build
export_dir := "build/web"

# Build the web version of the game
build-web:
    @mkdir -p {{export_dir}}
    godot --headless --export-release "Web" {{export_dir}}/index.html

# Clean build artifacts
clean:
    rm -rf build/

# Run the game locally
run:
    godot scenes/main.tscn

# Watch for file changes and rebuild web version automatically
watch:
    @echo "Watching for changes in .gd and .tscn files..."
    @while true; do \
        inotifywait -q -e modify,create,delete -r --include '\.(gd|tscn)$' . && \
        echo "Change detected, rebuilding..." && \
        just build-web; \
    done
