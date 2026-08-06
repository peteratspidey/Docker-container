#!/bin/bash
set -e

# =============================================================================
# NCBI Genome Downloader — Final Verified Version
# Run INSIDE container as peter
# Verified on: datasets 18.26.0 | dataformat 18.26.0 | Ubuntu 24.04
# Output: /data/<organism_or_label>/
# Supports two input modes:
#   1) Organism name (taxon search, filtered by assembly level/source)
#   2) GCF/GCA accession(s) — exact assemblies, typed in or from a file
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║           NCBI Genome Downloader                     ║"
echo "║     Levels: complete · chromosome · scaffold         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# -------------------------------
# 1. Dependency check
# -------------------------------
echo "[CHECK] Verifying tools..."
MISSING=0
for tool in datasets dataformat unzip; do
    if ! command -v "$tool" &>/dev/null; then
        echo "  [MISSING] $tool"
        MISSING=1
    else
        echo "  [OK] $tool"
    fi
done
if [[ "$MISSING" -eq 1 ]]; then
    echo "[ERROR] Missing tools. Run init_container.sh first."
    exit 1
fi
echo ""

# -------------------------------
# 2. Input mode
# -------------------------------
echo "How do you want to specify the genome(s)?"
echo "  [1] By organism name  (e.g. 'Morganella morganii')"
echo "  [2] By GCF/GCA accession(s)  (e.g. GCF_000026345.1)"
read -rp "  Choice [1-2, default=1]: " MODE_CHOICE
MODE_CHOICE="${MODE_CHOICE:-1}"

ACCESSIONS=()
ACC_FILE=""
TAXON=""
LABEL=""

if [[ "$MODE_CHOICE" == "2" ]]; then
    # ---------------------------
    # 2b. Accession-based input
    # ---------------------------
    echo ""
    echo "Enter accession(s) directly (space-separated), or a path to a file"
    echo "with one accession per line. Leave blank to be prompted for a file."
    read -rp "  Accessions: " ACC_INPUT

    if [[ -z "$ACC_INPUT" ]]; then
        read -rp "  Path to accession list file: " ACC_FILE
        if [[ ! -f "$ACC_FILE" ]]; then
            echo "[ERROR] File not found: $ACC_FILE"
            exit 1
        fi
    elif [[ -f "$ACC_INPUT" ]]; then
        # user typed a path instead of accessions
        ACC_FILE="$ACC_INPUT"
    else
        # split on whitespace/commas into an array
        read -ra ACCESSIONS <<< "$(echo "$ACC_INPUT" | tr ',' ' ')"
    fi

    if [[ -z "$ACC_FILE" && "${#ACCESSIONS[@]}" -eq 0 ]]; then
        echo "[ERROR] No accessions provided."
        exit 1
    fi

    # basic sanity check on format (GCF_/GCA_ + 9 digits + version)
    check_accession() {
        [[ "$1" =~ ^GC[FA]_[0-9]{9}\.[0-9]+$ ]]
    }
    if [[ -n "$ACC_FILE" ]]; then
        while read -r acc; do
            [[ -z "$acc" ]] && continue
            if ! check_accession "$acc"; then
                echo "[WARN] '$acc' doesn't look like a valid GCF/GCA accession — proceeding anyway."
            fi
        done < "$ACC_FILE"
    else
        for acc in "${ACCESSIONS[@]}"; do
            if ! check_accession "$acc"; then
                echo "[WARN] '$acc' doesn't look like a valid GCF/GCA accession — proceeding anyway."
            fi
        done
    fi

    echo ""
    read -rp "Label for this download (used for output folder, e.g. 'morganella_batch1'): " LABEL
    if [[ -z "$LABEL" ]]; then
        if [[ -n "$ACC_FILE" ]]; then
            LABEL="accession_batch_$(date +%Y%m%d)"
        else
            LABEL="${ACCESSIONS[0]}"
        fi
    fi
    SAFE_NAME=$(echo "$LABEL" | tr ' ' '_' | tr -cd '[:alnum:]_-' | tr 'A-Z' 'a-z')

    # levels/source filters don't apply to exact-accession downloads
    ASSEMBLY_LEVELS="n/a (exact accessions)"
    ASSEMBLY_SOURCE="n/a (exact accessions)"

else
    # ---------------------------
    # 2a. Organism name input
    # ---------------------------
    read -rp "Organism name (e.g. 'Morganella morganii'): " TAXON
    if [[ -z "$TAXON" ]]; then
        echo "[ERROR] Organism name cannot be empty."
        exit 1
    fi

    # safe name for directory/file naming
    SAFE_NAME=$(echo "$TAXON" | tr ' ' '_' | tr -cd '[:alnum:]_-' | tr 'A-Z' 'a-z')

    # -------------------------------
    # 3. Assembly levels
    # -------------------------------
    echo ""
    echo "Assembly levels:"
    echo "  [1] Complete only"
    echo "  [2] Complete + Chromosome"
    echo "  [3] Complete + Chromosome + Scaffold  (recommended)"
    echo "  [4] Scaffold only"
    echo "  [5] All  (complete, chromosome, scaffold, contig)"
    read -rp "  Choice [1-5, default=3]: " LEVEL_CHOICE

    case "${LEVEL_CHOICE:-3}" in
        1) ASSEMBLY_LEVELS="complete" ;;
        2) ASSEMBLY_LEVELS="complete,chromosome" ;;
        3) ASSEMBLY_LEVELS="complete,chromosome,scaffold" ;;
        4) ASSEMBLY_LEVELS="scaffold" ;;
        5) ASSEMBLY_LEVELS="complete,chromosome,scaffold,contig" ;;
        *) echo "[WARN] Invalid — defaulting to option 3."
           ASSEMBLY_LEVELS="complete,chromosome,scaffold" ;;
    esac

    # -------------------------------
    # 4. Genome source
    # -------------------------------
    echo ""
    echo "Genome source:"
    echo "  [1] RefSeq only        (recommended — higher quality)"
    echo "  [2] GenBank only"
    echo "  [3] RefSeq + GenBank   (maximum coverage)"
    read -rp "  Choice [1-3, default=1]: " SRC_CHOICE

    case "${SRC_CHOICE:-1}" in
        1) ASSEMBLY_SOURCE="RefSeq" ;;
        2) ASSEMBLY_SOURCE="GenBank" ;;
        3) ASSEMBLY_SOURCE="RefSeq,GenBank" ;;
        *) echo "[WARN] Invalid — defaulting to RefSeq."
           ASSEMBLY_SOURCE="RefSeq" ;;
    esac
fi

# -------------------------------
# 5. Output directory
# -------------------------------
# Default is always /data/<organism_or_label> — the mounted volume
DEFAULT_OUTDIR="/data/${SAFE_NAME}"
echo ""
read -rp "Output directory [default: $DEFAULT_OUTDIR]: " CUSTOM_OUTDIR
OUTDIR="${CUSTOM_OUTDIR:-$DEFAULT_OUTDIR}"

# -------------------------------
# 6. Confirm
# -------------------------------
echo ""
echo "┌─────────────────────────────────────────────────┐"
echo "│                Download Summary                  │"
if [[ "$MODE_CHOICE" == "2" ]]; then
    printf "│  Mode     : %-35s│\n" "Accession"
    if [[ -n "$ACC_FILE" ]]; then
        printf "│  Source   : %-35s│\n" "file: $ACC_FILE"
    else
        printf "│  Accessions: %-34s│\n" "${ACCESSIONS[*]}"
    fi
    printf "│  Label    : %-35s│\n" "$LABEL"
else
    printf "│  Mode     : %-35s│\n" "Organism name"
    printf "│  Organism : %-35s│\n" "$TAXON"
    printf "│  Levels   : %-35s│\n" "$ASSEMBLY_LEVELS"
    printf "│  Source   : %-35s│\n" "$ASSEMBLY_SOURCE"
fi
printf "│  Output   : %-35s│\n" "$OUTDIR"
echo "└─────────────────────────────────────────────────┘"
echo ""
read -rp "Proceed? [Y/n]: " CONFIRM
if [[ "${CONFIRM,,}" == "n" ]]; then
    echo "Aborted."
    exit 0
fi

# -------------------------------
# 7. Setup directories & log
# -------------------------------
# Create output dir and set ownership for peter
sudo mkdir -p "$OUTDIR"
sudo chown -R peter:peter "$OUTDIR"
chmod -R 755 "$OUTDIR"

LOG="${OUTDIR}/download_$(date +%Y%m%d_%H%M%S).log"

{
echo "========================================"
echo " NCBI Genome Download Log"
if [[ "$MODE_CHOICE" == "2" ]]; then
    echo " Mode     : Accession"
    if [[ -n "$ACC_FILE" ]]; then
        echo " Source   : file: $ACC_FILE"
    else
        echo " Accessions: ${ACCESSIONS[*]}"
    fi
    echo " Label    : $LABEL"
else
    echo " Mode     : Organism name"
    echo " Organism : $TAXON"
    echo " Levels   : $ASSEMBLY_LEVELS"
    echo " Source   : $ASSEMBLY_SOURCE"
fi
echo " Date     : $(date)"
echo "========================================"
} | tee "$LOG"

# -------------------------------
# 8. Download
# -------------------------------
echo "" | tee -a "$LOG"
echo "[1/4] Downloading from NCBI..." | tee -a "$LOG"

if [[ "$MODE_CHOICE" == "2" ]]; then
    if [[ -n "$ACC_FILE" ]]; then
        datasets download genome accession \
            --inputfile "$ACC_FILE" \
            --include genome,seq-report \
            --filename "${OUTDIR}/${SAFE_NAME}.zip" \
            2>&1 | tee -a "$LOG"
    else
        datasets download genome accession "${ACCESSIONS[@]}" \
            --include genome,seq-report \
            --filename "${OUTDIR}/${SAFE_NAME}.zip" \
            2>&1 | tee -a "$LOG"
    fi
else
    datasets download genome taxon "$TAXON" \
        --assembly-level  "$ASSEMBLY_LEVELS" \
        --assembly-source "$ASSEMBLY_SOURCE" \
        --include genome,seq-report \
        --filename "${OUTDIR}/${SAFE_NAME}.zip" \
        2>&1 | tee -a "$LOG"
fi

# -------------------------------
# 9. Unzip
# -------------------------------
echo "" | tee -a "$LOG"
echo "[2/4] Unzipping..." | tee -a "$LOG"

unzip -q "${OUTDIR}/${SAFE_NAME}.zip" -d "${OUTDIR}/ncbi_dataset"
echo "      Done." | tee -a "$LOG"

# -------------------------------
# 10. Collect FASTAs into flat dir
# -------------------------------
echo "" | tee -a "$LOG"
echo "[3/4] Collecting FASTA files..." | tee -a "$LOG"

FASTA_DIR="${OUTDIR}/fasta_all"
mkdir -p "$FASTA_DIR"

find "${OUTDIR}/ncbi_dataset" -name "*.fna" | while read -r f; do
    accession=$(basename "$(dirname "$f")")
    cp "$f" "${FASTA_DIR}/${accession}.fna"
done

TOTAL=$(find "$FASTA_DIR" -name "*.fna" | wc -l)
echo "      FASTA files collected: $TOTAL" | tee -a "$LOG"

# -------------------------------
# 11. Metadata TSV
# -------------------------------
echo "" | tee -a "$LOG"
echo "[4/4] Generating metadata TSV..." | tee -a "$LOG"

JSONL="${OUTDIR}/ncbi_dataset/ncbi_dataset/data/assembly_data_report.jsonl"

if [[ ! -f "$JSONL" ]]; then
    echo "[WARN] assembly_data_report.jsonl not found. Skipping metadata." | tee -a "$LOG"
else
    # fields passed as single string — backslash continuation breaks --fields in v18
    dataformat tsv genome \
        --inputfile "$JSONL" \
        --fields accession,organism-name,assminfo-level,assminfo-status,assmstats-contig-n50,assmstats-scaffold-n50,assmstats-total-sequence-len,assmstats-gc-percent,assmstats-number-of-contigs,source_database,assminfo-biosample-collection-date,assminfo-biosample-isolation-source,assminfo-biosample-geo-loc-name,assminfo-biosample-host \
        > "${OUTDIR}/assembly_summary.tsv"

    ROWS=$(wc -l < "${OUTDIR}/assembly_summary.tsv")
    echo "      Metadata rows (incl. header): $ROWS" | tee -a "$LOG"

    echo "" | tee -a "$LOG"
    echo "=== Assembly Level Breakdown ===" | tee -a "$LOG"
    awk -F"\t" 'NR>1 {print $3}' "${OUTDIR}/assembly_summary.tsv" \
        | sort | uniq -c | sort -rn | tee -a "$LOG"
fi

# -------------------------------
# Done
# -------------------------------
echo "" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"
echo " Download complete"                       | tee -a "$LOG"
echo " Total genomes  : $TOTAL"                | tee -a "$LOG"
echo " FASTA dir      : $FASTA_DIR"            | tee -a "$LOG"
echo " Metadata       : ${OUTDIR}/assembly_summary.tsv" | tee -a "$LOG"
echo " Log            : $LOG"                  | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"
echo ""