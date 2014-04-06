function [Yhat, eta, Proj] = mLOL_train_and_predict(Xtrain, Ytrain, Xtest, varargin)
% trains and predicts Low-rank Optimal projection LDA
% 
% INPUT
%   Xtrain in R^{D x ntrain}: training predictor matrix
%   Ytrain in {0,1}^n: training predictee vector
%   Xtest in R^{D x ntest}: test predictor matrix
%   varargin has 2 options
%       option 1) input only dimension and estimate parameters
%           k in Z: # of dimensions of projection matrix
%       option 2) 
%           delta in R^D: difference of means
%           V in R^{d x D}: projection matrix

if nargin == 5
    Proj = mLOL_train(Xtrain,Ytrain,varargin{1},varargin{2});
else
    Proj = mLOL_train(Xtrain,Ytrain,varargin{1});
end
Xtilde=Proj*Xtrain;
parms = mLDA_train(Xtilde,Ytrain);
[Yhat, eta] = mLDA_predict(Proj*Xtest,parms);
