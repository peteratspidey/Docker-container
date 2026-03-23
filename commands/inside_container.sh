#!/bin/bash

set -e

echo "======================================"
echo " MLST WORKFLOW STARTED "
echo "======================================"

# -------------------------------
# STEP 0: UNZIP FILES
# -------------------------------
echo "📦 Checking for zip files..."

if ls *.zip 1> /dev/null 2>&1; then
    echo "📦 Extracting zip files..."
    for f in *.zip; do
        echo "Extracting $f"
        unzip -o "$f" > /dev/null
    done
    echo "✅ Unzip completed"
else
    echo "No zip files found, skipping unzip"
fi

# -------------------------------
# STEP 1: CHECK GENOMES
# -------------------------------
echo "🔍 Searching for genome files..."

TOTAL=$(find . -type f -name "*.fna" | wc -l)

if [ "$TOTAL" -eq 0 ]; then
    echo "❌ No .fna files found!"
    exit 1
fi

echo "📊 Found $TOTAL genomes"

# -------------------------------
# STEP 2: RUN MLST
# -------------------------------
mkdir -p mlst_outputs

echo "⚡ Running MLST..."

find . -type f -name "*.fna" | \
parallel -j 8 '
    FILE={}
    SAFE_NAME=$(echo "$FILE" | sed "s|./||; s|/|_|g; s|\.fna$||")

    echo "Processing $FILE"

    mlst "$FILE" > mlst_outputs/${SAFE_NAME}.mlst \
                 2> mlst_outputs/${SAFE_NAME}.log
'

echo "✅ MLST completed"

# -------------------------------
# STEP 3: QC CHECK
# -------------------------------
echo "🔍 Performing QC checks..."

OUTPUT_COUNT=$(ls mlst_outputs/*.mlst | wc -l)
echo "📁 Output files: $OUTPUT_COUNT"

find mlst_outputs -name "*.mlst" -size 0 > failed_empty.txt || true
EMPTY_COUNT=$(wc -l < failed_empty.txt)

echo "❌ Empty outputs: $EMPTY_COUNT"

# -------------------------------
# STEP 4: COMBINE RESULTS
# -------------------------------
cat mlst_outputs/*.mlst > final_mlst_raw.txt

# -------------------------------
# STEP 5: CREATE SUMMARY
# -------------------------------
awk '{print $1"\t"$2"\t"$3}' final_mlst_raw.txt > mlst_summary.tsv

# -------------------------------
# STEP 6: CLASSIFY RESULTS
# -------------------------------
awk '$3 ~ /^[0-9]+$/' mlst_summary.tsv > valid_mlst.tsv
awk '$3 !~ /^[0-9]+$/' mlst_summary.tsv > failed_mlst.tsv

VALID_COUNT=$(wc -l < valid_mlst.tsv)
FAILED_COUNT=$(wc -l < failed_mlst.tsv)

echo "✔ Valid MLST: $VALID_COUNT"
echo "❌ Failed MLST: $FAILED_COUNT"

# -------------------------------
# STEP 7: ST DISTRIBUTION
# -------------------------------
cut -f3 valid_mlst.tsv | sort | uniq -c | sort -nr > st_distribution.txt

echo "Top STs:"
head st_distribution.txt

# -------------------------------
# STEP 8: PLOT
# -------------------------------
cat << 'EOF' > plot_st_distribution.py
import matplotlib.pyplot as plt

st = []
counts = []

with open("st_distribution.txt") as f:
    for line in f:
        c, s = line.strip().split()
        st.append(s)
        counts.append(int(c))

st = st[:10]
counts = counts[:10]

plt.figure()
plt.bar(st, counts)
plt.xlabel("Sequence Type (ST)")
plt.ylabel("Number of Genomes")
plt.title("Top ST Distribution")
plt.xticks(rotation=45)

plt.tight_layout()
plt.savefig("st_distribution.png")
EOF

python3 plot_st_distribution.py

echo "📈 Plot saved as st_distribution.png"

# -------------------------------
# FINAL REPORT
# -------------------------------
echo "==============================="
echo "📊 FINAL SUMMARY"
echo "Total genomes: $TOTAL"
echo "Valid MLST: $VALID_COUNT"
echo "Failed MLST: $FAILED_COUNT"
echo "Empty outputs: $EMPTY_COUNT"
echo "==============================="

echo "🎉 MLST pipeline completed successfully!"
