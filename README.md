# Machine Learning Assignment 2

This repository contains the implementation and experimental results for **Machine Learning Assignment 2: Bagging, Boosting and Bias-Variance Analysis on Face Recognition** using the Olivetti Faces dataset.

## Repository Structure

```text
ML_Assignment_2/
├── ML_Assignment_2.ipynb
├── saved_split.npz
├── requirements.txt
├── environment.txt
├── reproduce.sh
├── README.md
├── .gitignore
└── figures/
    ├── tree_depth.png
    ├── bagging_diagnostics.png
    ├── q1_fix_case1.png
    ├── q1_fix_case2.png
    ├── q1_fail_case1.png
    ├── q1_fail_case2.png
    ├── boosting_diagnostics.png
    ├── hard_boost_face.png
    └── mask_response.png
```

## Dataset

The experiments use the Olivetti Faces dataset loaded through:

```python
from sklearn.datasets import fetch_olivetti_faces
```

Dataset details:

- 40 identities
- 10 images per identity
- 400 total images
- Each image is 64 x 64 pixels
- Raw flattened pixel values are used as features
- No PCA or dimensionality reduction is used

## Data Split

The same identity-wise split is used throughout the assignment:

- 6 training images per identity
- 2 validation images per identity
- 2 test images per identity

This gives:

- Training set: 240 images
- Validation set: 80 images
- Test set: 80 images

The exact indices used in the experiments are stored in:

```text
saved_split.npz
```

## Experiments Included

The notebook contains the complete implementation and outputs for:

### Q1 - Decision Tree and Bagging

- Decision Tree hyperparameter search
- Final Decision Tree evaluation
- Manual bootstrap bagging
- Ensemble sizes from 1 to 200 trees
- OOB accuracy
- Pairwise disagreement
- Vote margin
- Clean and masked test evaluation
- Example faces corrected by bagging
- Example faces misclassified by both models

### Q2 - SAMME Boosting

- One complete multiclass SAMME round on a small example
- Manual SAMME implementation
- Weak-tree depth and boosting-round selection
- Weighted training error
- Learner weight (alpha)
- Maximum sample weight
- Top-10 sample weight concentration
- Bagging versus boosting comparison
- High-weight difficult training example
- Clean and masked evaluation

### Q3 - Bias and Variance

- 30 resampled training sets
- Bias-squared and variance measurements
- Single Tree, Bagging and Boosting comparison
- Depth-wise variance analysis
- Variance reduction due to bagging
- Leaf occupancy and disagreement analysis
- Final clean/masked/bias/variance comparison

## Environment

The original experiment environment is recorded in:

```text
environment.txt
requirements.txt
```

The recorded environment uses Python 3.14.4.

## Reproduction

A runnable Ubuntu/Linux reproduction script is provided:

```bash
chmod +x reproduce.sh
./reproduce.sh
```

The script:

1. checks the required repository files,
2. creates a local `.venv` if needed,
3. installs packages from `requirements.txt`,
4. verifies the saved train/validation/test split,
5. executes the notebook into a separate reproduced notebook,
6. exports generated PNG outputs into `reproduced/figures/`.

The submitted notebook is not modified by the reproduction script.

If complete notebook execution cannot finish, the script keeps the original notebook unchanged and exports the PNG outputs already stored in the notebook.

## Figures

The `figures/` directory contains the main figures used in the experimental analysis and report.

These include:

- Decision Tree depth analysis
- Bagging OOB/disagreement/vote-margin diagnostics
- Example faces corrected by bagging
- Example faces where both models fail
- Boosting diagnostics
- High-weight boosting sample
- Clean-versus-masked response example

## Notes

- Model selection is performed using validation accuracy.
- Test accuracy is used only for final evaluation.
- All models are trained on clean images.
- The masked test set is created by setting the central 16 x 16 region of each test face to zero.
- The notebook contains the complete experiment code and recorded outputs.
