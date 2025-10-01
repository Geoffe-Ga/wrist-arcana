#!/bin/bash
# download_rws_cards.sh - Download complete Rider-Waite-Smith deck

set -e  # Exit on error

DOWNLOAD_DIR="RWS_Cards_Raw"
PROCESSED_DIR="RWS_Cards_Processed"

mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$PROCESSED_DIR"

echo "📥 Downloading Rider-Waite-Smith deck from sacred-texts.com..."
echo "⚖️  These images are in the public domain (pre-1923)"
echo ""

# Function to download file only if it doesn't exist
download_if_missing() {
    local output_file="$1"
    local url="$2"
    
    if [ -f "$output_file" ]; then
        echo "  ✓ Already exists: $(basename "$output_file")"
    else
        echo "  Downloading: $(basename "$output_file")..."
        curl -s -o "$output_file" "$url"
        sleep 0.5  # Be respectful to server
    fi
}

# Major Arcana (0-21)
echo "🎴 Downloading Major Arcana..."
for i in {0..21}; do
    padded=$(printf "%02d" $i)
    download_if_missing "$DOWNLOAD_DIR/major_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/ar$padded.jpg"
done

# Minor Arcana - Wands (wa)
echo "🎴 Downloading Wands..."
# Ace uses special naming
download_if_missing "$DOWNLOAD_DIR/wands_01.jpg" \
    "https://www.sacred-texts.com/tarot/pkt/img/waac.jpg"
# 2-10 use standard naming
for i in {2..10}; do
    padded=$(printf "%02d" $i)
    download_if_missing "$DOWNLOAD_DIR/wands_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/wa$padded.jpg"
done
# Court cards
download_if_missing "$DOWNLOAD_DIR/wands_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/wapa.jpg"
download_if_missing "$DOWNLOAD_DIR/wands_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/wakn.jpg"
download_if_missing "$DOWNLOAD_DIR/wands_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/waqu.jpg"
download_if_missing "$DOWNLOAD_DIR/wands_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/waki.jpg"

# Minor Arcana - Cups (cu)
echo "🎴 Downloading Cups..."
# Ace uses special naming
download_if_missing "$DOWNLOAD_DIR/cups_01.jpg" \
    "https://www.sacred-texts.com/tarot/pkt/img/cuac.jpg"
# 2-10 use standard naming
for i in {2..10}; do
    padded=$(printf "%02d" $i)
    download_if_missing "$DOWNLOAD_DIR/cups_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/cu$padded.jpg"
done
download_if_missing "$DOWNLOAD_DIR/cups_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cupa.jpg"
download_if_missing "$DOWNLOAD_DIR/cups_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cukn.jpg"
download_if_missing "$DOWNLOAD_DIR/cups_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cuqu.jpg"
download_if_missing "$DOWNLOAD_DIR/cups_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/cuki.jpg"

# Minor Arcana - Swords (sw)
echo "🎴 Downloading Swords..."
# Ace uses special naming
download_if_missing "$DOWNLOAD_DIR/swords_01.jpg" \
    "https://www.sacred-texts.com/tarot/pkt/img/swac.jpg"
# 2-10 use standard naming
for i in {2..10}; do
    padded=$(printf "%02d" $i)
    download_if_missing "$DOWNLOAD_DIR/swords_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/sw$padded.jpg"
done
download_if_missing "$DOWNLOAD_DIR/swords_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swpa.jpg"
download_if_missing "$DOWNLOAD_DIR/swords_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swkn.jpg"
download_if_missing "$DOWNLOAD_DIR/swords_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swqu.jpg"
download_if_missing "$DOWNLOAD_DIR/swords_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/swki.jpg"

# Minor Arcana - Pentacles (pe)
echo "🎴 Downloading Pentacles..."
# Ace uses special naming
download_if_missing "$DOWNLOAD_DIR/pentacles_01.jpg" \
    "https://www.sacred-texts.com/tarot/pkt/img/peac.jpg"
# 2-10 use standard naming
for i in {2..10}; do
    padded=$(printf "%02d" $i)
    download_if_missing "$DOWNLOAD_DIR/pentacles_$padded.jpg" \
        "https://www.sacred-texts.com/tarot/pkt/img/pe$padded.jpg"
done
download_if_missing "$DOWNLOAD_DIR/pentacles_page.jpg" "https://www.sacred-texts.com/tarot/pkt/img/pepa.jpg"
download_if_missing "$DOWNLOAD_DIR/pentacles_knight.jpg" "https://www.sacred-texts.com/tarot/pkt/img/pekn.jpg"
download_if_missing "$DOWNLOAD_DIR/pentacles_queen.jpg" "https://www.sacred-texts.com/tarot/pkt/img/pequ.jpg"
download_if_missing "$DOWNLOAD_DIR/pentacles_king.jpg" "https://www.sacred-texts.com/tarot/pkt/img/peki.jpg"

echo ""
echo "✅ Download process complete"
echo "📊 Checking file sizes..."

# Verify downloads
total_size=$(du -sh "$DOWNLOAD_DIR" | cut -f1)
file_count=$(ls -1 "$DOWNLOAD_DIR" | wc -l | xargs)

echo "   Total: $file_count files, $total_size"
echo ""

# Check for failed downloads (files < 1KB likely failed)
echo "🔍 Checking for failed downloads..."
failed=0
for file in "$DOWNLOAD_DIR"/*.jpg; do
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ "$size" -lt 1000 ]; then
        echo "   ⚠️  Warning: $(basename "$file") is suspiciously small ($size bytes)"
        failed=$((failed + 1))
    fi
done

if [ $failed -eq 0 ]; then
    echo "   ✅ All downloads look good!"
else
    echo "   ⚠️  Found $failed potentially failed downloads"
    echo "   Check the files manually and re-run if needed"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Review images in $DOWNLOAD_DIR"
echo "   2. Run process_images.sh to optimize and resize"
echo "   3. Import to Xcode Asset Catalog"