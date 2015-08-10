




function compute_results(xFilename,yFilename)

  Y = dlmread(sprintf(yFilename),' ');
  Y = Y(2:size(Y,1),2:size(Y,2));
  Ysum = sum(Y,1);
  Y = Y(:,Ysum>2);

  isTest = '0';
  suffix = 'val';
  svmCList = {'0.01'};

  res = zeros(size(svmCList,2),2);
  for svmCIndex = 1:length(svmCList)
    svmC = svmCList{svmCIndex};
    [auc,accuracy] = compute_performance(xFilename,yFilename,svmC,isTest,suffix,Y);
    res(svmCIndex,1:2) = [auc,accuracy];
    res
  end

  [~,I] = sortrows(res,[-1,-2]);
  bestSVMC = svmCList{I(1)};
  
  fileID = fopen('../Results/results','a');
  fprintf(fileID, '%s %s %.4f %.4f\n',xFilename,yFilename,res(1),res(2));
  fclose(fileID);

end


%%
% 
% xFilename:            input feature
% yFilename:            output multiple label, label is either 0 or 1
% svmC:                 svm slack parameter
% isTest:               select a small port of data for sanity check if isTest=True  
%
function [auc,accuracy] = compute_performance(xFilename,yFilename,svmC,isTest,suffix,Y)

  Ypred = zeros(size(Y));

  for labelIndex = 1:size(Y,2)
    for foldIndex = 1:5
      % processing
      outputFilename = sprintf('../Results/%s_%s/%s_%s_l%d_f%d_c%s_t%s_%s',...
      regexprep(xFilename,'.*/',''),...
      regexprep(yFilename,'.*/',''),...
      regexprep(xFilename,'.*/',''),...
      regexprep(yFilename,'.*/',''),...
      labelIndex,foldIndex,svmC,isTest,suffix);
      
      res = dlmread(outputFilename);
      Ypred(res(:,1),labelIndex) = res(:,2);
    end
  end

  accuracy = 1-sum(sum(xor(Y,(Ypred>0.5))))/size(Y,1)/size(Y,2);
  [X,Y,T,auc] = perfcurve(reshape(Y,size(Y,1)*size(Y,2),1),reshape(Ypred,size(Y,1)*size(Y,2),1),1);

  
  
end
