#!/bin/bash
# process_images.sh - Resize and optimize for Xcode

# Requires ImageMagick: brew install imagemagick

DOWNLOAD_DIR="RWS_Cards_Raw"
PROCESSED_DIR="RWS_Cards_Processed"

echo "🎨 Processing images for watchOS..."

# Create resolution directories
mkdir -p "$PROCESSED_DIR/@1x"
mkdir -p "$PROCESSED_DIR/@2x"
mkdir -p "$PROCESSED_DIR/@3x"

for img in "$DOWNLOAD_DIR"/*.jpg; do
    basename=$(basename "$img" .jpg)
    echo "  Processing $basename..."
    
    # @3x (highest resolution) - 1200x2000px
    magick "$img" \
        -resize 1200x2000^ \
        -gravity center \
        -extent 1200x2000 \
        -quality 90 \
        -strip \
        "$PROCESSED_DIR/@3x/${basename}.png"
    
    # @2x - 800x1333px
    magick "$img" \
        -resize 800x1333^ \
        -gravity center \
        -extent 800x1333 \
        -quality 90 \
        -strip \
        "$PROCESSED_DIR/@2x/${basename}.png"
    
    # @1x - 400x666px
    magick "$img" \
        -resize 400x666^ \
        -gravity center \
        -extent 400x666 \
        -quality 90 \
        -strip \
        "$PROCESSED_DIR/@1x/${basename}.png"
done

echo ""
echo "✅ Processed $(ls -1 "$PROCESSED_DIR/@3x" | wc -l | xargs) images"

original_size=$(du -sh "$DOWNLOAD_DIR" | cut -f1)
processed_size=$(du -sh "$PROCESSED_DIR" | cut -f1)

echo "📊 Size comparison:"
echo "   Original:  $original_size"
echo "   Processed: $processed_size"
echo ""
echo "🎯 Ready for Xcode! Import from: $PROCESSED_DIR"