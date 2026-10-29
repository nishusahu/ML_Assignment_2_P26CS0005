#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Machine Learning Assignment 2 - Reproduction Script
# ------------------------------------------------------------
# Run from the repository root:
#   chmod +x reproduce.sh
#   ./reproduce.sh
#
# This script does not modify the submitted notebook.
# It creates all reproduced outputs inside ./reproduced/
# ------------------------------------------------------------

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

NOTEBOOK="ML_Assignment_2.ipynb"
REQ_FILE="requirements.txt"
SPLIT_FILE="saved_split.npz"

OUT_DIR="reproduced"
OUT_NOTEBOOK="$OUT_DIR/ML_Assignment_2_reproduced.ipynb"
FIG_DIR="$OUT_DIR/figures"
SUMMARY_FILE="$OUT_DIR/split_summary.txt"

echo "=============================================="
echo " Machine Learning Assignment 2 - Reproduction"
echo "=============================================="

# ---------- Required files ----------
for f in "$NOTEBOOK" "$REQ_FILE" "$SPLIT_FILE"; do
    if [[ ! -f "$f" ]]; then
        echo "ERROR: Missing required file: $f"
        exit 1
    fi
done

mkdir -p "$FIG_DIR"

# ---------- Python environment ----------
if [[ -x ".venv/bin/python" ]]; then
    PYTHON=".venv/bin/python"
    PIP=".venv/bin/pip"
    JUPYTER=".venv/bin/jupyter"
else
    if command -v python3.14 >/dev/null 2>&1; then
        BASE_PYTHON="python3.14"
    elif command -v python3 >/dev/null 2>&1; then
        BASE_PYTHON="python3"
    else
        echo "ERROR: Python 3 is not installed."
        exit 1
    fi

    echo
    echo "[1/5] Creating virtual environment..."
    "$BASE_PYTHON" -m venv .venv

    PYTHON=".venv/bin/python"
    PIP=".venv/bin/pip"
    JUPYTER=".venv/bin/jupyter"

    echo "[2/5] Installing recorded dependencies..."
    "$PIP" install --upgrade pip
    "$PIP" install -r "$REQ_FILE"
fi

# ---------- Verify saved split ----------
echo
echo "[3/5] Verifying saved train/validation/test split..."

"$PYTHON" - <<'PY' > "$SUMMARY_FILE"
import numpy as np

s = np.load("saved_split.npz")

train = s["train_idx"]
val = s["val_idx"]
test = s["test_idx"]

print("Saved split verification")
print("========================")
print(f"Train size      : {len(train)}")
print(f"Validation size : {len(val)}")
print(f"Test size       : {len(test)}")
print(f"Total           : {len(train) + len(val) + len(test)}")

all_idx = np.concatenate([train, val, test])
print(f"Unique indices  : {len(np.unique(all_idx))}")
print(f"No overlap       : {len(np.unique(all_idx)) == len(all_idx)}")

assert len(train) == 240
assert len(val) == 80
assert len(test) == 80
assert len(np.unique(all_idx)) == 400
PY

cat "$SUMMARY_FILE"

# ---------- Execute notebook into a new file ----------
echo
echo "[4/5] Executing notebook into reproduced/ ..."
echo "      Original ML_Assignment_2.ipynb is not modified."

set +e
"$JUPYTER" nbconvert \
    --to notebook \
    --execute "$NOTEBOOK" \
    --output "$(basename "$OUT_NOTEBOOK")" \
    --output-dir "$OUT_DIR" \
    --ExecutePreprocessor.timeout=-1

NB_STATUS=$?
set -e

if [[ $NB_STATUS -ne 0 ]]; then
    echo
    echo "WARNING: Full notebook execution did not complete."
    echo "The original submitted notebook has not been changed."
    echo "Figures will now be exported from the stored notebook outputs."
    SOURCE_NOTEBOOK="$NOTEBOOK"
else
    echo "Notebook execution completed successfully."
    SOURCE_NOTEBOOK="$OUT_NOTEBOOK"
fi

# ---------- Export PNG outputs ----------
echo
echo "[5/5] Exporting PNG figures from notebook outputs..."

"$PYTHON" - "$SOURCE_NOTEBOOK" "$FIG_DIR" <<'PY'
import base64
import json
import sys
from pathlib import Path

nb_path = Path(sys.argv[1])
fig_dir = Path(sys.argv[2])
fig_dir.mkdir(parents=True, exist_ok=True)

with nb_path.open("r", encoding="utf-8") as f:
    nb = json.load(f)

count = 0

for cell_no, cell in enumerate(nb.get("cells", []), start=1):
    if cell.get("cell_type") != "code":
        continue

    for out_no, output in enumerate(cell.get("outputs", []), start=1):
        data = output.get("data", {})
        png = data.get("image/png")

        if not png:
            continue

        if isinstance(png, list):
            png = "".join(png)

        count += 1
        name = f"figure_{count:02d}_cell_{cell_no:03d}.png"
        path = fig_dir / name
        path.write_bytes(base64.b64decode(png))
        print(f"Saved: {path}")

print()
print(f"Total PNG figures exported: {count}")
PY

echo
echo "=============================================="
echo " Reproduction finished"
echo "=============================================="
echo "Reproduced notebook : $OUT_NOTEBOOK"
echo "Figures             : $FIG_DIR/"
echo "Split summary       : $SUMMARY_FILE"
echo
echo "Original notebook remains unchanged."
