README

1. Feature Extraction
Before proceed to run the script, please add training2017 folder to Matlab path.
Feature extraction is done by extract_features.m to extract 12 features. *See the report for the list of features.
This script need 2 .mat files to run.
- input_data.mat contains the list of filename and label from REFERENCE.csv converted in to Matlab format.
- AF_fliplist2.cat is the list of recording that need to be inverted before feature extraction process. *See the report for detection method.

2. Extracted features
The extracted features with labels for training and validation are saved in 4 files:
- AF_features_4categories.mat: 4 categories normal, AF, other, noise
- AF_features_2categories_NA.mat: 2 categories normal, AF
- AF_features_2categories_AO.mat: 2 categories AF, other
- AF_features_2categories_NO.mat: 2 categories normal, noise

3. Classifications
The scripts for classification are as following.
3.1 Neural Networks, default hidden layer = 10 
4 categories: mlp_4categories.m
2 categories N-A: mlp_2categoriesNA.m
2 categories A-O: mlp_2categoriesAO.m
2 categories N-O: mlp_2categoriesNO.m


3.2 K-Nearest Neighbour
4 categories: knn_4categories.m
2 categories: knn_2categories.m
The results are printed to terminal.

3.3 Support Vector Machine (SVM) *Use libsvm for classification.
svm_libsvm.m
The results from 10-fold cross validation are kept in the following variables:
svm_2catAO, svm_2catNA, svm_2catNO, svm_4cat