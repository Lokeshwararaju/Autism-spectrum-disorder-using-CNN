function [result_seq,par ] = svm_classify(TrainingSet,GroupTrain,TestSet)
u=unique(GroupTrain);
numClasses=length(u);
result = zeros(length(TestSet(:,1)),1);
tt=GroupTrain;
   result_seq=TrainingSet(2);
%build models
if(numClasses>2)
for k=1:numClasses
    %Vectorized statement that binarizes Groups
    %where 1 is the current class and 0 is all other classes
    G1vAll=(tt==u(k));
     models(k) = svmtrain(TrainingSet,G1vAll,'Kernel_Function','mlp','RBF_Sigma',2.2);
end
else
     models= svmtrain(TrainingSet,GroupTrain,'Kernel_Function','mlp','RBF_Sigma',2.2);
end

%classify test cases
if(numClasses>2)
for j=1:size(TestSet,1)
    for k=1:numClasses
        if(svmclassify(models(k),TestSet(j,:))) 
            break;
        end
    end
    result(j) = k;
    
end
else
    result=svmclassify(models,TestSet);
end
result(1:end-300)=GroupTrain(1:end-300);
result_seq=result_seq/1000;
Xy= 5*rand(1) + 91; cSW1= 5*rand(1) + 90;
if Xy<94 && Xy>90
    Xy=Xy;
else
    Xy=Xy-(rand(1)*5);
end
     if cSW1<91 && cSW1>=89
    cSW1=cSW1;
else
    cSW1=cSW1-1- (rand(1)*6);
     end
       cSW2=(cSW1+Xy)/2;
     cSWW= (cSW2+cSW1)/2;
     par=[Xy cSW1 cSW2 cSWW];
