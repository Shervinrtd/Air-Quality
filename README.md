# Predicting Extreme Air Pollution Levels Using PySpark

**Big Data Analytics and Text Mining — Module 2 Project**
Alma Mater Studiorum — Universita di Bologna
Authors: Alireza Shahidiani · Gita Javadi

---

## Overview

This project uses **Apache Spark / PySpark** and the **Spark MLlib** distributed
machine-learning library to predict extreme air-pollution concentrations — specifically
the **99th-percentile annual concentration** — across EPA monitoring stations in the
United States.

Six regression algorithms are trained, tuned, and compared inside a fully automated
Spark ML Pipeline. The notebook is self-contained: it downloads the dataset automatically
from the EPA public archive, loads it into **HDFS** using explicit `hdfs dfs` commands,
and produces all results and visualisations without any manual steps outside the notebook.

---

## Course Requirements Satisfied

| Requirement | Value | Threshold |
|---|---|---|
| Patterns **N** | 55 969 (after cleaning) | >= 20 000 |
| Features **p** | 18 (16 numeric + 2 categorical) | >= 4 |
| Algorithms **n_A** | 6 | >= 3 |
| **N x p** | 1 007 442 | >= 1 000 000 |

---

## Dataset

| Property | Detail |
|---|---|
| Name | EPA Air Quality Annual Summary Data |
| Year | 2025 |
| Source | https://aqs.epa.gov/aqsweb/airdata/download_files.html |
| File | `annual_conc_by_monitor_2025.csv` |
| Raw rows | 59 154 |
| Raw columns | 55 |

The dataset is downloaded automatically by the first code cell of the notebook.
No manual download is needed.

---

## Feature Design & Data Leakage Rationale

**Target variable:** `99th Percentile` annual concentration.

The following columns were **excluded** because they are computed from the same annual
measurement sequence as the target and would constitute direct data leakage:

- `1st–4th Max Value`
- `50th Percentile`, `10th Percentile`, `98th Percentile`, `95th Percentile`,
  `90th Percentile`, `75th Percentile`

**Retained numeric features (p_num = 16):**

| Group | Features |
|---|---|
| Bulk distribution summaries | `Arithmetic Mean`, `Arithmetic Standard Dev` |
| Observation completeness | `Observation Count`, `Observation Percent`, `Valid Day Count`, `Required Day Count`, `Exceptional Data Count`, `Null Data Count` |
| Regulatory threshold crossings | `Primary Exceedance Count`, `Secondary Exceedance Count` |
| Geography | `Latitude`, `Longitude` |
| Station metadata | `POC`, `State Code`, `County Code`, `Site Num` |

**Categorical features (p_cat = 2):** `State Name`, `Parameter Name`
Both are OneHotEncoded into sparse binary vectors for all models.

Null values in count-type features (`Primary Exceedance Count`,
`Secondary Exceedance Count`) are imputed with `0` rather than dropped,
because a null here means zero threshold exceedances were recorded — a
meaningful zero, not missing data. Only rows where the target itself is
null or non-positive are removed.

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

All models share the same feature vector: z-scored numeric features +
OneHotEncoded categorical features. Hyperparameter tuning uses
`TrainValidationSplit` (80/20 internal split) evaluated on RMSE.

---

## Results

| Model | R2 | RMSE | MAE |
|---|---|---|---|
| **Ridge Regression (TUNED)** | **0.9986** | 24.42 | 5.49 |
| Lasso Regression | 0.9985 | 24.62 | 5.33 |
| Elastic Net (TUNED) | 0.9985 | 24.84 | 5.50 |
| OLS Linear Regression | 0.9985 | 24.96 | 5.65 |
| Gradient-Boosted Tree (TUNED) | 0.9688 | 113.58 | **4.12** |
| Random Forest | 0.6310 | 390.82 | 10.00 |

**Key insight:** Linear models dominate on R2 because `Arithmetic Mean` is a
near-perfect linear predictor of the 99th percentile within each pollutant type,
and OneHotEncoding gives each of the 406 monitored pollutants its own intercept.
GBT achieves the lowest MAE (4.12), meaning its typical per-prediction error is
actually smaller than any linear model.

---

## Project Structure

```
.
|-- air_quality.ipynb               # Main notebook (self-contained, executable as-is)
|-- annual_conc_by_monitor_2025.csv # Dataset (downloaded automatically by the notebook)
|-- Vagrantfile                     # Vagrant VM configuration (with port forwarding)
|-- bootstrap.sh                    # VM provisioning script (Hadoop + Spark + Jupyter)
|-- Vagrant_Box_setup.html          # VM setup instructions
|-- README.md                       # This file
```

---

## Required Library Versions

| Library | Minimum version |
|---|---|
| Python | 3.10 |
| Apache Spark / PySpark | 3.5.1 |
| Java (JDK) | 11 |
| Hadoop | 3.4.0 |
| pandas | 2.0 |
| matplotlib | 3.7 |
| seaborn | 0.12 |

---

## VM Hardware (Experimental Setting)

| Resource | Specification |
|---|---|
| VM type | VirtualBox (Vagrant) |
| RAM | 4 GB |
| vCPUs | 2 |
| Host OS | Windows 11 |
| Guest OS | Ubuntu 22.04 LTS |
| Hadoop | 3.4.0 (single-node pseudo-distributed) |
| Spark | 3.5.1 (local[2] mode on top of HDFS) |

---

## How to Run — Course Vagrant VM (Primary Execution Environment)

> **Why not Google Colab?**
> Google Colab does not expose a true distributed file system. It runs Spark in
> local mode and has no HDFS. Colab was used strictly for rapid syntax prototyping.
> All actual execution, data loading, and presentation are performed on the
> course-provided Vagrant VM using explicit Hadoop DFS commands, as required.

### First-time setup (run once after `vagrant up`)

After `vagrant up` completes, SSH into the VM and configure HDFS:

```bash
vagrant ssh
```

```bash
# 1. Load environment variables
source ~/.bashrc

# 2. Set up passwordless SSH to localhost (required by Hadoop)
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa 2>/dev/null || true
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh -o StrictHostKeyChecking=no localhost exit

# 3. Configure Hadoop core-site.xml
cat > $HADOOP_HOME/etc/hadoop/core-site.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

# 4. Configure Hadoop hdfs-site.xml
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/home/vagrant/hadoopdata/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/home/vagrant/hadoopdata/datanode</value>
  </property>
</configuration>
EOF

# 5. Create data directories and format the NameNode (ONCE ONLY)
mkdir -p /home/vagrant/hadoopdata/namenode
mkdir -p /home/vagrant/hadoopdata/datanode
hdfs namenode -format -force

# 6. Start HDFS
start-dfs.sh

# 7. Verify — must see NameNode and DataNode
jps

# 8. Set Jupyter to always open the project folder
jupyter notebook --generate-config
echo "c.NotebookApp.notebook_dir = '/vagrant'" >> ~/.jupyter/jupyter_notebook_config.py
```

### Every subsequent session

```bash
vagrant ssh

# Start HDFS (does not auto-start on boot)
source ~/.bashrc
start-dfs.sh

# Confirm NameNode and DataNode are running
jps

# Start Jupyter
jupyter notebook --no-browser --ip=0.0.0.0 --port=8888
```

Then open **http://localhost:8888** in your host browser, open `air_quality.ipynb`,
and run all cells. The notebook will:

1. Detect HDFS is running via `hdfs dfs -ls /`
2. Download the EPA dataset from the public archive (skipped if already present)
3. Load it into HDFS with explicit `hdfs dfs -mkdir` and `hdfs dfs -put` commands
4. Run all 6 ML models and generate all visualisations

### Forwarded ports

| Port | Service | URL |
|---|---|---|
| **8888** | Jupyter Notebook | http://localhost:8888 |
| **4040** | Spark Web UI (job monitor) | http://localhost:4040 |
| **9870** | HDFS NameNode Web UI | http://localhost:9870 |
| **8088** | YARN ResourceManager | http://localhost:8088 |
| **5910** | VNC desktop | VNC client to localhost:5910 (password: bda2024) |

---

## How to Run — Google Colab (Prototyping Only)

The notebook auto-detects Colab and switches to local mode. Add this cell at the
top of the notebook before running:

```python
!apt-get install -y openjdk-11-jdk -q
!pip install pyspark==3.5.1 -q
import os
os.environ["JAVA_HOME"] = "/usr/lib/jvm/java-11-openjdk-amd64"
```

Then run all cells. The dataset is downloaded automatically and read from the
local filesystem (no HDFS).

---

## Outputs

All plots and CSV summaries are saved to `/vagrant/results/` (VM) or
`/content/results/` (Colab).

| File | Description |
|---|---|
| `descriptive_statistics.csv` | Global summary statistics for all features |
| `pollutant_stats.csv` | Per-pollutant breakdown of the target variable |
| `model_results.csv` | R2, RMSE, MAE for all 6 models |
| `tuning_results.txt` | Best hyperparameters from TrainValidationSplit |
| `feature_importance.csv` | Random Forest feature importances |
| `eda_target_distribution.png` | Distribution of the 99th-percentile target |
| `eda_pollutant_ranking.png` | Top-20 pollutants by mean 99th-percentile |
| `eda_correlation_heatmap.png` | Feature correlation matrix |
| `plot_r2_comparison.png` | R2 bar chart — all 6 models |
| `plot_rmse_comparison.png` | RMSE bar chart — all 6 models |
| `plot_mae_comparison.png` | MAE bar chart — all 6 models |
| `plot_model_panel.png` | Combined R2 / RMSE / MAE panel (slide-ready) |
| `plot_actual_vs_predicted.png` | Actual vs predicted scatter (best model) |
| `plot_residual_distribution.png` | Residual distribution with mean and sigma |
| `plot_feature_importance.png` | Top-15 Random Forest feature importances |

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Connection refused` on port 9000 | HDFS NameNode not running | Run `start-dfs.sh` in VM terminal |
| `No module named pyspark` | PySpark not installed in Python env | Run `pip3 install pyspark==3.5.1` |
| `NotJSONError` opening notebook | UTF-8 BOM in .ipynb file (Windows encoding) | Re-save file with `[System.Text.UTF8Encoding]::new($false)` |
| Jupyter shows wrong directory | Jupyter started from wrong folder | Run `cd /vagrant` before `jupyter notebook ...` |
| `maxBins` error in tree models | More distinct category values than maxBins allows | Already fixed: `maxBins=512` |
| Negative R2 for tree models | Label-encoded high-cardinality categoricals | Already fixed: all models use OHE features |

---

## License

The EPA dataset is publicly available and freely redistributable.
Code in this repository is released under the MIT License.