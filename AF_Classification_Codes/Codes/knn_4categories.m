load AF_features_4categories

for i = 3:2:7
    knear_euc = fitcknn(DAT,tg_num,'NumNeighbors',i,'Standardize',1);
    label_euc = predict(knear_euc,datVal);
    i
    Accuracy = sum(tg_val_num==label_euc)/size(tg_val_num,1)
end