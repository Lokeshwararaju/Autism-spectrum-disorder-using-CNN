function [E, D,selectedColumns] = pca_mat(vectors, firstEig, lastEig, ~)
oldDimension = size (vectors, 1);

covarianceMatrix = cov(vectors', 1);
[E, D] = eig (covarianceMatrix);


eigenvalues =sort(diag(D),'descend');

if lastEig < oldDimension
  lowerLimitValue = (eigenvalues(lastEig) + eigenvalues(lastEig + 1)) / 2;
else
  lowerLimitValue = eigenvalues(oldDimension) - 1;
end
lowerColumns = diag(D) > lowerLimitValue;

if firstEig > 1
  higherLimitValue = (eigenvalues(firstEig - 1) + eigenvalues(firstEig)) / 2;
else
  higherLimitValue = eigenvalues(1) + 1;
end
higherColumns = diag(D) < higherLimitValue;

selectedColumns = lowerColumns & higherColumns;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
