clear all
load AF_features_2categories_NA
disp('K-NN 2 categories: Normal-AF')
for i = 3:2:7
    knear_euc = fitcknn(DAT_2cat,TGnum_2cat,'NumNeighbors',i,'Standardize',1);
   label_euc = predict(knear_euc,val_DAT_2cat);
    i
    Accuracy = sum(val_TGnum_2cat==label_euc)/size(val_TGnum_2cat,1)
end

clear all
load AF_features_2categories_AO
disp('K-NN 2 categories: AF-Other')
for i = 3:2:7
    knear_euc = fitcknn(DAT_2cat,TGnum_2cat,'NumNeighbors',i,'Standardize',1);
   label_euc = predict(knear_euc,val_DAT_2cat);
    i
    Accuracy = sum(val_TGnum_2cat==label_euc)/size(val_TGnum_2cat,1)
end

clear all
load AF_features_2categories_NO
disp('K-NN 2 categories: Normal-Noisy')
for i = 3:2:7
    knear_euc = fitcknn(DAT_2cat,TGnum_2cat,'NumNeighbors',i,'Standardize',1);
   label_euc = predict(knear_euc,val_DAT_2cat);
    i
    Accuracy = sum(val_TGnum_2cat==label_euc)/size(val_TGnum_2cat,1)
end