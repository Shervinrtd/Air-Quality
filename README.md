#  Air Pollution Prediction Using PySpark

##  Project Overview

This project implements a distributed machine learning pipeline using Apache Spark and PySpark to analyze and predict extreme air pollution levels across the United States.

The objective of the project is to predict the **99th Percentile** of air pollution measurements using environmental, geographical, and observational data collected from EPA monitoring stations.

The notebook demonstrates a complete Big Data workflow including:

- Large-scale data ingestion
- Data cleaning and preprocessing
- Feature engineering
- Categorical encoding
- Distributed machine learning with Spark MLlib
- Model evaluation and comparison
- Data visualization and interpretation

---

#  Dataset

Dataset Source:

EPA Air Quality Annual Summary Data

Official Source:
https://aqs.epa.gov/aqsweb/airdata/download_files.html

The dataset contains more than **59,000 records** and multiple environmental variables including:

- AQI
- Pollution concentration statistics
- Observation counts
- Geographic coordinates
- Environmental monitoring metadata

---

#  Project Requirements Fulfilled

This project satisfies the Big Data course requirements:

| Requirement | Status |
|---|---|
| N > 20,000 patterns | ✅ |
| p > 4 features | ✅ |
| N × p > 1,000,000 | ✅ |
| At least 3 ML algorithms | ✅ |
| Distributed processing with Spark | ✅ |
| Reproducible notebook | ✅ |

---

#  Technologies Used

- Python
- PySpark
- Apache Spark MLlib
- Pandas
- Matplotlib
- Google Colab

---

#  Machine Learning Models

The following regression models were implemented and compared:

1. **Linear Regression**
2. **Random Forest Regressor**
3. **Generalized Linear Regression (GLR)**

---

#  Target Variable

The target variable used for prediction is:

```text
99th Percentile
```

This variable represents extreme pollution concentration levels and is useful for analyzing severe air quality conditions.

---

#  Main Pipeline Steps

## 1. Data Loading
- Dataset downloaded directly from GitHub
- Loaded using PySpark

## 2. Data Cleaning
- Schema sanitization
- Null handling
- Feature selection

## 3. Feature Engineering
- Environmental statistical features
- Geographical features
- Categorical encoding using OneHotEncoder

## 4. Distributed Machine Learning
- Spark MLlib Pipelines
- Train/Test split
- Model training and evaluation

## 5. Visualization
- Actual vs Predicted values
- Feature importance
- Model comparison charts

---

#  Final Results

| Model | R² Score |
|---|---|
| Linear Regression | ~0.99 |
| Random Forest | ~0.88 |
| Generalized Linear Regression | High performance |

The results indicate strong linear relationships between environmental variables and extreme pollution concentration levels.

---

#  How to Run

1. Open the notebook in Google Colab
2. Run all cells sequentially
3. The dataset is downloaded automatically from GitHub
4. Models are trained and evaluated automatically

---

#  Repository Structure

```text
├── notebook.ipynb
├── dataset/
│   └── annual_conc_by_monitor_2025.zip
├── README.md
```

---

#  Required Library Versions

- Python 3.x
- PySpark 3.x
- Pandas
- Matplotlib

The notebook includes a dedicated section that prints the exact library versions used during execution.

---

#  Notes

- The notebook is fully self-contained and reproducible.
- The dataset is automatically downloaded from the repository.
- Apache Spark MLlib is used for distributed machine learning.
- Environmental data preprocessing and encoding are handled directly inside the notebook.

---

#  Authors
Alireza Shahidiani
Gita Javadi
Big Data Analytics Project  
University of Bologna
