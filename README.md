# Predicting Extreme Air Pollution Levels Using PySpark

**Big Data Analytics and Text Mining — Module 2 Project**  
Alma Mater Studiorum — Università di Bologna  
Authors: Alireza Shahidiani · Gita Javadi

---

## Overview

This project uses **Apache Spark / PySpark** and the **Spark MLlib** distributed machine-learning library to predict extreme air-pollution concentrations — specifically the **99th-percentile annual concentration** — across EPA monitoring stations in the United States.

Six regression algorithms are trained, tuned, and compared inside a fully automated Spark ML Pipeline. The notebook is self-contained: it downloads the dataset automatically from the EPA public archive, loads it into HDFS (on the course VM) or reads it locally (on Google Colab), and produces all results and visualisations without any manual steps.

---

## Course Requirements Satisfied

| Requirement | Value | Threshold |
|---|---|---|
| Patterns **N** | 55 969 (after cleaning) | ≥ 20 000 ✓ |
| Features **p** | 18 (16 numeric + 2 categorical) | ≥ 4 ✓ |
| Algorithms **n_A** | 6 | ≥ 3 ✓ |
| **N × p** | 1 007 442 | ≥ 1 000 000 ✓ |

---

## Dataset

| Property | Detail |
|---|---|
| Name | EPA Air Quality Annual Summary Data |
| Year | 2025 |
| Source | [EPA AQS Data Download](https://aqs.epa.gov/aqsweb/airdata/download_files.html) |
| File | `annual_conc_by_monitor_2025.csv` |
| Raw rows | 59 154 |
| Raw columns | 55 |

The dataset is downloaded automatically by the first code cell of the notebook. No manual download is needed.

---

## Feature Design & Data Leakage Rationale

**Target variable:** `99th Percentile` annual concentration.

The following columns were **excluded** because they are computed from the same annual measurement sequence as the target and would constitute direct data leakage:

- `1st Max Value`, `2nd Max Value`, `3rd Max Value`, `4th Max Value`
- `50th Percentile`, `10th Percentile`, `98th Percentile`, `95th Percentile`, `90th Percentile`, `75th Percentile`

**Retained numeric features (p_num = 16):**

| Group | Features |
|---|---|
| Bulk distribution summaries | `Arithmetic Mean`, `Arithmetic Standard Dev` |
| Observation completeness | `Observation Count`, `Observation Percent`, `Valid Day Count`, `Required Day Count`, `Exceptional Data Count`, `Null Data Count` |
| Regulatory threshold crossings | `Primary Exceedance Count`, `Secondary Exceedance Count` |
| Geography | `Latitude`, `Longitude` |
| Station metadata | `POC`, `State Code`, `County Code`, `Site Num` |

**Categorical features (p_cat = 2):** `State Name`, `Parameter Name`  
Both are OneHotEncoded into sparse binary vectors.

Null values in count-type features are imputed with `0` (not dropped), because a null `Primary Exceedance Count` means zero threshold exceedances were recorded — a meaningful zero, not a missing value.

---

## Algorithms

| # | Algorithm | Hyperparameter Tuning |
|---|---|---|
| 1 | OLS Linear Regression | — |
| 2 | Ridge Regression (L2) | `regParam` via TrainValidationSplit |
| 3 | Lasso Regression (L1) | fixed (`elasticNetParam=1.0, regParam=0.05`) |
| 4 | Elastic Net (L1 + L2) | `regParam` + `elasticNetParam` via TrainValidationSplit |
| 5 | Random Forest Regressor | fixed (`numTrees=100, maxDepth=10`) |
| 6 | Gradient-Boosted Tree Regressor | `maxDepth` + `maxIter` via TrainValidationSplit |

Hyperparameter tuning uses `TrainValidationSplit` (80/20 internal split) evaluated on RMSE. All models share the same feature vector: z-scored numeric features + OneHotEncoded categorical features.

---

## Results

| Model | R² | RMSE | MAE |
|---|---|---|---|
| **Ridge Regression (TUNED)** | **0.9986** | 24.42 | 5.49 |
| Lasso Regression | 0.9985 | 24.62 | 5.33 |
| Elastic Net (TUNED) | 0.9985 | 24.84 | 5.50 |
| OLS Linear Regression | 0.9985 | 24.96 | 5.65 |
| Gradient-Boosted Tree (TUNED) | 0.9688 | 113.58 | **4.12** |
| Random Forest | 0.6310 | 390.82 | 10.00 |

**Key insight:** Linear models dominate on R² because `Arithmetic Mean` is a near-perfect linear predictor of the 99th percentile within each pollutant type, and OneHotEncoding gives each of the 406 monitored pollutants its own intercept. GBT achieves the lowest MAE (4.12), meaning its typical per-prediction error is actually smaller than any linear model's.

---

## Project Structure

```
.
├── air_quality.ipynb              # Main notebook (self-contained, executable as-is)
├── annual_conc_by_monitor_2025.csv # Dataset (downloaded automatically by the notebook)
├── Vagrantfile                    # Vagrant VM configuration
├── bootstrap.sh                   # VM provisioning script
├── Vagrant_Box_setup.html         # VM setup instructions
└── README.md                      # This file
```

---

## Requirements

### Library versions

| Library | Minimum version |
|---|---|
| Python | 3.10 |
| Apache Spark / PySpark | 3.5.0 |
| Java (JDK) | 11 |
| pandas | 2.0 |
| matplotlib | 3.7 |
| seaborn | 0.12 |

### Installing PySpark (Google Colab only)

```python
!apt-get install -y openjdk-11-jdk -q
!pip install pyspark==3.5.0 -q
import os
os.environ["JAVA_HOME"] = "/usr/lib/jvm/java-11-openjdk-amd64"
```

No installation is needed on the course-provided Vagrant VM — all dependencies are pre-installed.

---

## How to Run

### Option A — Course Vagrant VM (primary execution environment)

> Google Colab does **not** expose a true distributed file system. It runs Spark in local mode and has no HDFS. Colab was used strictly for rapid syntax prototyping. **All actual execution, data loading, and presentation are performed on the course-provided Vagrant VM** using explicit Hadoop DFS commands.

**Step 1 — Start the VM**
```bash
vagrant up
vagrant ssh
```

**Step 2 — Start Jupyter** (the Vagrantfile forwards port 8888 to the host)
```bash
jupyter notebook --no-browser --ip=0.0.0.0 --port=8888
```

**Step 3 — Open in your host browser**
```
http://localhost:8888
```

**Step 4 — Open `air_quality.ipynb` and run all cells**

The first code cell (`## 0 · Dataset Download into HDFS`) automatically:
1. Downloads `annual_conc_by_monitor_2025.zip` from the EPA archive
2. Extracts the CSV
3. Runs `hdfs dfs -mkdir -p /datasets` and `hdfs dfs -put` to load the data into HDFS
4. Skips all of the above if the file already exists in HDFS

No manual `hdfs` commands are needed.

---

### Option B — Google Colab

The notebook detects the environment automatically (`shutil.which("hdfs")`). When HDFS is not found it switches to local Spark mode and reads the CSV directly from the local filesystem.

**Step 1 — Install dependencies** (add a new cell at the top and run it once per session)
```python
!apt-get install -y openjdk-11-jdk -q
!pip install pyspark==3.5.0 -q
import os
os.environ["JAVA_HOME"] = "/usr/lib/jvm/java-11-openjdk-amd64"
```

**Step 2 — Upload the notebook**
- Go to [colab.research.google.com](https://colab.research.google.com)
- **File → Upload notebook** → select `air_quality.ipynb`

**Step 3 — Runtime → Restart session → Run all**

The dataset is downloaded automatically. All other cells run without modification.

---

## VM Hardware (Experimental Setting)

| Resource | Specification |
|---|---|
| VM type | VirtualBox (Vagrant) |
| RAM | 4 GB |
| vCPUs | 2 |
| Host OS | Windows 11 |
| Guest OS | Ubuntu 22.04 |
| Hadoop | 3.x (single-node pseudo-distributed) |
| Spark mode | `local[2]` on HDFS |

---

## Outputs

All plots and CSV summaries are saved to `/vagrant/results/` (VM) or `/content/results/` (Colab).

| File | Description |
|---|---|
| `descriptive_statistics.csv` | Global summary statistics for all features |
| `pollutant_stats.csv` | Per-pollutant breakdown of the target variable |
| `model_results.csv` | R², RMSE, MAE for all 6 models |
| `tuning_results.txt` | Best hyperparameters selected by TrainValidationSplit |
| `feature_importance.csv` | Random Forest feature importances |
| `eda_target_distribution.png` | Distribution of the 99th-percentile target |
| `eda_pollutant_ranking.png` | Top-20 pollutants by mean 99th-percentile |
| `eda_correlation_heatmap.png` | Feature correlation matrix |
| `plot_r2_comparison.png` | R² bar chart (all models) |
| `plot_rmse_comparison.png` | RMSE bar chart (all models) |
| `plot_mae_comparison.png` | MAE bar chart (all models) |
| `plot_model_panel.png` | Combined R² / RMSE / MAE panel (slide-ready) |
| `plot_actual_vs_predicted.png` | Actual vs predicted scatter (best model) |
| `plot_residual_distribution.png` | Residual distribution with mean and σ |
| `plot_feature_importance.png` | Top-15 Random Forest feature importances |

---

## License

The EPA dataset is publicly available and freely redistributable.  
Code in this repository is released under the MIT License.
