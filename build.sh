#!/bin/bash

set -e

# 🌈 Let's make some magic happen! 
echo "🚀 Starting the awesome file copying process..."
for lang in python go java js; do
    if [ ! -d "$lang" ]; then
        continue # Skip non-existent directories
    fi


    for dir in "$lang"/*; do
        echo "📂 Processing directory: $dir"
        if [ -d "$dir" ]; then
            # Copy bootstrap files (sh, bat, ps1)
            for ext in sh bat ps1; do
                source_bootstrap_file="$lang/bootstrap.$ext"
                if [ -f "$source_bootstrap_file" ]; then
                    cp -f "$source_bootstrap_file" "$dir/bootstrap.$ext"
                    echo "  ✨ Bootstrap $ext file copied successfully!"
                fi
            done
            for shared_dir in shared/*; do
                if [ "$lang" = "java" ]; then
                    target_dir="$dir/src/main/resources"
                    cp -rf "$shared_dir" "$target_dir/"
                    echo "  ✅ Shared resources copied: $shared_dir to $target_dir"
                    continue
                fi
                shared_dirname=$(basename "$shared_dir")
                cp -rf "$shared_dir" "$dir/"
                echo "  ✅ Shared resources copied: $shared_dirname"
            done
        fi
    done
done
echo "🎉 Shared files copied successfully! 🌟"
echo ""

echo "🚀 Creating release packages..."

# Create release directory for packages
rm -rf release || true
mkdir -p release

# Package each client directory
for lang in python go java nodejs; do
    if [ ! -d "$lang" ]; then
        continue # Skip non-existent directories
    fi

    # Process each client type directory
    for dir in "$lang"/*; do
        if [ -d "$dir" ]; then
            # Get directory name
            client_type=$(basename "$dir")
            # Remove -oauth suffix from directory name
            client_type=${client_type%-oauth}
            # Build final zip filename
            zip_name="${lang}_${client_type}.zip"

            echo "📦 Packaging directory $dir into $zip_name..."
            # Enter directory and create zip package, excluding temp files
            # Use find command to exclude .venv directory first, then package remaining files
            (cd "$dir" && find . -type d -name ".venv" -prune -o -type f -print | \
             grep -v "__pycache__" | \
             grep -v "\.pyc$" | \
             grep -v "\.DS_Store" | \
             grep -v "coze_oauth_config.json" | \
             grep -v "node_modules" | \
             grep -v "package-lock.json" | \
             zip "../../release/$zip_name" -@)
            echo "  ✨ Package created successfully: release/$zip_name"
        fi
    done
done

echo "📚 All packages have been created in the release directory!"

echo "🎉 All done!"