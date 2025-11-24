#!/bin/bash
# validate_aspect_ratios.sh - Verify processed card images maintain authentic proportions
#
# Canonical tarot aspect ratio: 11:19 (≈0.579)
# Acceptable range: 0.55-0.60 (accounts for slight variations in raw cards)

PROCESSED_DIR="RWS_Cards_Processed"
MIN_ASPECT=0.55
MAX_ASPECT=0.60
TARGET_ASPECT=0.579  # 11/19

echo "🔍 Validating card image aspect ratios..."
echo ""

# Check if processed directory exists
if [ ! -d "$PROCESSED_DIR/@3x" ]; then
    echo "❌ Error: $PROCESSED_DIR/@3x not found"
    echo "   Run ./process_images.sh first"
    exit 1
fi

# Check ImageMagick is installed
if ! command -v identify &> /dev/null; then
    echo "❌ Error: ImageMagick not found"
    echo "   Install with: brew install imagemagick"
    exit 1
fi

# Count total images
total_images=$(ls -1 "$PROCESSED_DIR/@3x"/*.png 2>/dev/null | wc -l | xargs)
if [ "$total_images" -eq 0 ]; then
    echo "❌ Error: No images found in $PROCESSED_DIR/@3x"
    exit 1
fi

echo "📊 Checking $total_images card images..."
echo ""

warnings=0
errors=0
aspect_sum=0

for img in "$PROCESSED_DIR/@3x"/*.png; do
    basename=$(basename "$img")

    # Get dimensions and calculate aspect ratio
    dimensions=$(identify -format "%wx%h" "$img")
    width=$(echo "$dimensions" | cut -d'x' -f1)
    height=$(echo "$dimensions" | cut -d'x' -f2)
    aspect=$(echo "scale=6; $width / $height" | bc)

    # Add to sum for average calculation
    aspect_sum=$(echo "$aspect_sum + $aspect" | bc)

    # Check if within acceptable range
    too_low=$(echo "$aspect < $MIN_ASPECT" | bc)
    too_high=$(echo "$aspect > $MAX_ASPECT" | bc)

    if [ "$too_low" -eq 1 ] || [ "$too_high" -eq 1 ]; then
        echo "❌ $basename: ${width}x${height} (aspect: $aspect) - OUT OF RANGE"
        ((errors++))
    else
        deviation=$(echo "scale=2; ($aspect - $TARGET_ASPECT) * 100" | bc)
        if (( $(echo "${deviation#-} > 2" | bc -l) )); then
            echo "⚠️  $basename: ${width}x${height} (aspect: $aspect, deviation: ${deviation}%)"
            ((warnings++))
        fi
    fi
done

# Calculate average aspect ratio
avg_aspect=$(echo "scale=6; $aspect_sum / $total_images" | bc)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Results:"
echo "   Total images:      $total_images"
echo "   Average aspect:    $avg_aspect (target: $TARGET_ASPECT)"
echo "   Acceptable range:  $MIN_ASPECT - $MAX_ASPECT"
echo ""

if [ $errors -gt 0 ]; then
    echo "❌ $errors image(s) OUT OF RANGE"
    echo "   Some cards have aspect ratios outside the acceptable range"
    exit 1
elif [ $warnings -gt 0 ]; then
    echo "⚠️  $warnings image(s) with deviations >2% from target"
    echo "   Cards are within range but not perfectly centered on target"
    echo "✅ All images within acceptable range ($MIN_ASPECT - $MAX_ASPECT)"
    exit 0
else
    echo "✅ Perfect! All images within acceptable range"
    echo "   Average aspect ratio: $avg_aspect (≈11:19)"
    exit 0
fi
