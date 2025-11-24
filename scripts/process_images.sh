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

    # Canonical tarot aspect ratio is 11:19 (~0.579)
    # We preserve original proportions to maintain authentic Rider-Waite artwork

    # @3x (highest resolution) - height 2000px, width scales proportionally
    magick "$img" \
        -resize x2000 \
        -quality 90 \
        -strip \
        "$PROCESSED_DIR/@3x/${basename}.png"

    # @2x - height 1333px, width scales proportionally
    magick "$img" \
        -resize x1333 \
        -quality 90 \
        -strip \
        "$PROCESSED_DIR/@2x/${basename}.png"

    # @1x - height 666px, width scales proportionally
    magick "$img" \
        -resize x666 \
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