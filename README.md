#  Air Quality Prediction Using PySpark and Machine Learning  
## A Distributed Time-Series Forecasting Pipeline for Environmental Pollution Analysis

---

##  Project Overview

This project develops a scalable machine learning pipeline using **Apache Spark (PySpark)** to predict Carbon Monoxide (`CO_GT`) concentration from environmental sensor measurements and temporal features.

The workflow includes:

- Distributed data preprocessing
- Anomaly and missing-value handling
- Time-series feature engineering
- Cyclical temporal encoding
- Lag-feature generation
- Chronological train/test evaluation
- Hyperparameter tuning
- Model comparison using Spark MLlib

Two regression models were implemented and evaluated:

- Linear Regression
- Random Forest Regression

The project demonstrates how Big Data technologies and machine learning can be combined to perform large-scale environmental analytics and short-term air quality prediction.

---

##  Technologies Used

- Python
- PySpark
- Apache Spark
- Spark MLlib
- Google Colab
- Machine Learning
- Time-Series Forecasting

---

##  Dataset

The project uses the **UCI Air Quality Dataset**, containing hourly air pollution sensor measurements collected from an Italian city.

### Features include:

- Carbon Monoxide (CO)
- Nitrogen Oxides (NOx)
- Benzene concentration
- Temperature
- Relative Humidity
- Absolute Humidity
- Temporal information (hour, month, weekday)

Dataset source:

- UCI Machine Learning Repository
- GitHub-hosted CSV dataset

---

##  Project Pipeline

### 1️⃣ Data Loading and Distributed Processing
- Dataset ingestion using PySpark
- Distributed processing with Apache Spark

### 2️⃣ Data Cleaning
- Removal of corrupted columns
- Handling sensor anomalies (`-200` values)
- Numeric type conversion
- Missing value treatment

### 3️⃣ Time-Series Feature Engineering
- Datetime parsing
- Hour / Month / DayOfWeek extraction
- Cyclical encoding using sine/cosine transformations
- Lag feature generation (`CO_GT_Lag1`, `CO_GT_Lag2`)

### 4️⃣ Machine Learning Pipeline
- Feature vector assembly
- Standardization
- Chronological train/test split
- Spark ML Pipelines

### 5️⃣ Model Training
- Linear Regression
- Random Forest Regression
- Hyperparameter tuning

### 6️⃣ Evaluation
Models were evaluated using:
- RMSE (Root Mean Squared Error)
- R² Score

---

##  Final Results

### Linear Regression
- R² ≈ 0.87
- Strong predictive consistency
- Excellent performance for short-term pollution prediction

### Random Forest Regression
- Improved performance after hyperparameter tuning
- Effective nonlinear modeling of pollution dynamics

---

##  Key Features

✅ Distributed preprocessing with Spark  
✅ Time-series aware evaluation  
✅ Leakage-free chronological split  
✅ Cyclical temporal encoding  
✅ Lag-based temporal memory features  
✅ Hyperparameter tuning  
✅ Spark ML Pipelines  
✅ Advanced feature engineering  

---

##  Key Concepts Demonstrated

- Big Data processing with Apache Spark
- Distributed machine learning
- Time-series forecasting
- Feature engineering
- Sensor anomaly handling
- Model evaluation and optimization
- Environmental analytics

---

##  Future Improvements

Potential future enhancements include:

- Forward-fill temporal imputation
- Fully causal forecasting architecture
- Deep learning approaches (LSTM / GRU)
- Real-time streaming analytics using Spark Streaming
- Multi-step future forecasting
- Advanced temporal resampling

---

##  Author

**Alireza Shahidini**  
Master’s Student in Artificial Intelligence  
University of Bologna

---

##  License

This project was developed for academic and educational purposes.
