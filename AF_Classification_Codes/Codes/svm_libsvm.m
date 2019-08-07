%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SVM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Default = Multiclass, RBF, added 10-fold cross validation

clear all
load AF_features_4categories
disp('SVM 4 categories')
svm_4cat = svmtrain(tg,DAT,'-v 10');

load AF_features_2categories_NA
disp('SVM 2 categories: Normal-AF')
DAT_2catAF = DAT_2cat;
TGnum_2catAF = TGnum_2cat;
svm_2catNA = svmtrain(TGnum_2catAF,DAT_2catAF,'-v 10');

load AF_features_2categories_AO
disp('SVM 2 categories: Normal-AO')
DAT_2catA0 = DAT_2cat;
TGnum_2catA0 = TGnum_2cat;
svm_2catAO = svmtrain(TGnum_2catA0,DAT_2catA0,'-v 10');

load AF_features_2categories_NO
disp('SVM 2 categories: Normal-NO')
DAT_2catNO = DAT_2cat;
TGnum_2catNO = TGnum_2cat;
svm_2catNO = svmtrain(TGnum_2catNO,DAT_2catNO,'-v 10');