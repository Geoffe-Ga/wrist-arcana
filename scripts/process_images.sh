#!/bin/bash
# process_images.sh - Resize and optimize for Xcode

# Requires ImageMagick: brew install imagemagick

set -e  # Exit on error

DOWNLOAD_DIR="RWS_Cards_Raw"
PROCESSED_DIR="RWS_Cards_Processed"

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "❌ Error: ImageMagick not found"
    echo "   Install with: brew install imagemagick"
    exit 1
fi

# Check if raw directory exists
if [ ! -d "$DOWNLOAD_DIR" ]; then
    echo "❌ Error: $DOWNLOAD_DIR not found"
    echo "   Run ./download_rws_cards.sh first"
    exit 1
fi

echo "🎨 Processing images for watchOS..."
echo ""

# Create resolution directories
mkdir -p "$PROCESSED_DIR/@1x"
mkdir -p "$PROCESSED_DIR/@2x"
mkdir -p "$PROCESSED_DIR/@3x"

# Count total images
total_images=$(ls -1 "$DOWNLOAD_DIR"/*.jpg 2>/dev/null | wc -l | xargs)
if [ "$total_images" -eq 0 ]; then
    echo "❌ Error: No .jpg files found in $DOWNLOAD_DIR"
    exit 1
fi

echo "📊 Processing $total_images card images (3 resolutions each)"
echo "   Estimated time: ~$((total_images * 3 * 2)) seconds (~$((total_images * 3 * 2 / 60)) minutes)"
echo ""

current=0
failed=0
start_time=$(date +%s)

for img in "$DOWNLOAD_DIR"/*.jpg; do
    basename=$(basename "$img" .jpg)
    ((current++))
    echo "[$current/$total_images] Processing $basename..."

    # Canonical tarot aspect ratio is 11:19 (~0.579)
    # We preserve original proportions to maintain authentic Rider-Waite artwork

    # @3x (highest resolution) - height 2000px, width scales proportionally
    if ! magick "$img" -resize x2000 -quality 90 -strip "$PROCESSED_DIR/@3x/${basename}.png" 2>/dev/null; then
        echo "   ⚠️  Failed to create @3x for $basename"
        ((failed++))
    fi

    # @2x - height 1333px, width scales proportionally
    if ! magick "$img" -resize x1333 -quality 90 -strip "$PROCESSED_DIR/@2x/${basename}.png" 2>/dev/null; then
        echo "   ⚠️  Failed to create @2x for $basename"
        ((failed++))
    fi

    # @1x - height 666px, width scales proportionally
    if ! magick "$img" -resize x666 -quality 90 -strip "$PROCESSED_DIR/@1x/${basename}.png" 2>/dev/null; then
        echo "   ⚠️  Failed to create @1x for $basename"
        ((failed++))
    fi
done

end_time=$(date +%s)
elapsed=$((end_time - start_time))

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

processed_count=$(ls -1 "$PROCESSED_DIR/@3x" | wc -l | xargs)
echo "✅ Processed $processed_count images"

if [ $failed -gt 0 ]; then
    echo "⚠️  $failed operation(s) failed"
fi

echo "⏱️  Time elapsed: ${elapsed}s (~$((elapsed / 60))m $((elapsed % 60))s)"

original_size=$(du -sh "$DOWNLOAD_DIR" | cut -f1)
processed_size=$(du -sh "$PROCESSED_DIR" | cut -f1)

echo ""
echo "📊 Size comparison:"
echo "   Original:  $original_size"
echo "   Processed: $processed_size"
echo ""

if [ "$processed_count" -eq "$total_images" ] && [ $failed -eq 0 ]; then
    echo "🎯 Success! All images ready for Xcode"
    echo "   Import from: $PROCESSED_DIR"
    exit 0
else
    echo "⚠️  Warning: Some images may be missing or failed"
    echo "   Expected: $total_images images"
    echo "   Processed: $processed_count images"
    echo "   Failed operations: $failed"
    exit 1
fi