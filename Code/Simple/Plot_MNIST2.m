% MNIST figure
clearvars, clc,
fpath = mfilename('fullpath');
findex=strfind(fpath,'/');
rootDir=fpath(1:findex(end-1));
p = genpath(rootDir);
gits=strfind(p,'.git');
colons=strfind(p,':');
for i=0:length(gits)-1
    endGit=find(colons>gits(end-i),1);
    p(colons(endGit-1):colons(endGit)-1)=[];
end
addpath(p);

newsim=0;
if newsim==1
    task.savestuff=1;
    task.types={'DENL'};
    [task,T,S,P,Pro,Z]= run_MNIST(rootDir,task);
else
    load([rootDir, '../Data/Results/mnist'])
end
task.savestuff=0;

%% make figure

h(6)=figure(6); clf, clear bottom
gray=0.75*[1 1 1];
colormap('bone')
Ncols=4;

width=0.18;
height=0.8;
leftside=0.1;
space=0.01;
hspace=0.05;

bottom(4)=0.01;
bottom(3)=bottom(4)+height+hspace;
bottom(2)=bottom(4)+2*(height+hspace); %1-(height+space);
bottom(1)=bottom(4)+3*(height+hspace); %1-(height+space);

right=leftside+3*(width+space)+7*space;
left2=leftside+width+hspace-0.02;         % left for 2nd column
left3=left2+(width+hspace); %+0.05;% left for 3rd column
left4=left3+(width+hspace);% left for 3rd column

dd=1;
gg=2;

lenName=length(task.name);
label_keepers=[];
for j=7:lenName-1
    label_keepers=[label_keepers, str2num(task.name(j))];
end
plot3d=false;

%% plot exemplars

group=Z.Ytrain;
training=Z.Xtrain;
un=unique(group);

clear aind im v vj
nex=9;
imj=nan(29*nex,29*3);
siz=size(imj);
for j=1:3
    aind{j}=find(group==un(j));
    for k=1:nex
        imj((k-1)*29+1:k*29,(j-1)*29+1:j*29)=[reshape(training(:,aind{j}(k)),[28 28]), zeros(28,1);zeros(1,29)];
    end
end
imj=-imj+1;
imj(end+1,:)=ones(1,87);
imj=repmat(imj,1,1,3);

imj(:,1,1:2)=0;
imj(:,28,1:2)=0;
imj([1:29:end],1:28,1:2)=0;

imj(:,29,2:3)=0;
imj(:,57,2:3)=0;
imj([1:29:end],29:57,2:3)=0;

imj(:,58,[1 3])=0;
imj(:,end,[1 3])=0;
imj([1:29:end],58:end,[1 3])=0;

% imagesc(imj)
imax=58;
imagesc(imj(end-imax:end,:,:))
colormap('bone')
subplot('Position',[leftside, bottom(end), width, height]), %width*length(bottom)+hspace*2]), %[left,bottom,width,height]

% imagesc(imj),
imagesc(imj(end-imax:end,:,:))
set(gca,'XTickLabel',[],'YTickLabel',[]);
tfs=12;
title([{'(A) Obtain'};{'Samples'}],'FontSize',tfs, 'HorizontalAlignment','center')


%% plot projections
clear aind im v vj
im1=zeros(28*4,28*4);
for j=1:4
%     aind{j}=find(group==un(j));
    for k=1:4
        v{j}{k}=reshape(Pro{j}.V(k,:),[28 28]);
    end
    m=max(v{j}{1}(:));
    if j==3, m=1; end
    vj{j}=[v{j}{1}, m*ones(28,1) v{j}{2}; m*ones(1,28*2+1); v{j}{3}, m*ones(28,1), v{j}{4}];
end

for j=4
    subplot('Position',[left2, bottom(j), width, height]),
    if j==1 % lasso
        imagesc(abs(vj{3})<1e-4), 
    elseif j==4 % lol
        imagesc(vj{1}),
    elseif j==2 % lda
        imagesc(vj{2}),
    elseif j==3 % pca
        imagesc(vj{4})
    end
    set(gca,'XTickLabel',[],'YTickLabel',[]);
end
title([{'(B) Learn'};{'Projection'}],'FontSize',tfs, 'HorizontalAlignment','center')


%% plot embeddings

ticks=-20:4:20;
ticks3=-20:0.5:20;

% si=[4 2 1 3];
for i=1
    iproj=i;
    Xtest=Pro{iproj}.V*Z.Xtest;
    Xtrain=Pro{iproj}.V*Z.Xtrain;
    
    if i==1 % lol
        si=4; 
%         tit='';
tit=[{'(C) Project'};{'Samples'}];
    elseif i==2 % lda
        si=2; 
        tit='';
        if plot3d
            set(get(gca,'xlabel'),'rotation',45);
            set(get(gca,'ylabel'),'rotation',-45);
        end

    elseif i==3 % lasso
        si=1; 
        ticks=ticks3;
    elseif i==4 % pca
        si=3;
        tit='';
    end
    
    subplot('Position',[left3 bottom(4), width, height]); hold all %[left,bottom,width,height]

    for jjj=1:length(label_keepers)
        if jjj==1
            color='b';
            marker='x';
        elseif jjj==2
            color='r';
            marker='o';
        else
            color='g';
            marker='d';
        end
        
        if plot3d==1
            plot3(Xtest(1,Z.Ytest==label_keepers(jjj)),Xtest(2,Z.Ytest==label_keepers(jjj)),Xtest(3,Z.Ytest==label_keepers(jjj)),'.',...
                'marker',marker,'markersize',4,'color',color)
            view([0.5,0.5,1])
        else
            plot(Xtest(1,Z.Ytest==label_keepers(jjj)),Xtest(2,Z.Ytest==label_keepers(jjj)),'.',...
                'marker',marker,'markersize',4,'color',color)
        end
    end
    set(gca,'xtick',ticks,'ytick',ticks,'ztick',ticks)
    title(tit,'FontSize',tfs, 'HorizontalAlignment','center'), grid off, axis('tight'), %axis('square')
    set(gca,'XtickLabel',[],'YTickLabel',[],'ZTickLabel',[]);
    
end


%% write algorithm name
% y_begin=[bottom(1), bottom(2), bottom(3), bottom(4)]+0.01;
% 
% ylab{4}=' LOL';
% ylab{2}='RR-LDA'; %[{'  LR'};{'   o'}; {'  FLD'}];
% ylab{1}='Lasso';
% ylab{3}=' PCA'; [{'eigen'};{'  o'}; {'faces'}];
% 
% % si=[4 2 1 3];
% for i=4  %[x_begin y_begin length height]
%     pos=[0.47, y_begin(i), 0.5, 0.1];
%     annotation('textbox', pos,'String', ylab{i},'EdgeColor','none','FontWeight','bold','FontName','FixedWidth'); %,'Interpreter','latex');
% end


%% plot posteriors

% clf
task.ntest=500;
task.rotate=false;
task.algs={'LOL';'ROAD'};
task.types={'NEFL';'DEFL'};
task.savestuff=1;
task.Nks=100;
tt=task;
tt.simulation=0;
tt.algs={'LOL';'ROAD'}; %add svm
tt.simulation=0;
tt.percent_unlabeled=0;
tt.types={'DENL';'NENL'};
tt.ntrials=1;
tt.savestuff=1;
tt.ntrain=300;
tt.ntest=500;
tt.Nks=100;
tt.name='MNIST(38)';

[task1, X, Y, P] = get_task(tt);
Y(Y==3)=1;
Y(Y==8)=2;
ids=378:784;

Z = parse_data(X,Y,task1.ntrain,task1.ntest,0);

[transformers, deciders] = parse_algs(task1.types);
Proj = LOL(Z.Xtrain,Z.Ytrain,transformers,task1.Kmax);
% PP{2}=Proj{1};
% PP{1}=Proj{2};
% Proj=PP;
Proj{4}=Pro{4};

numDim=2;

for i=1 %[1,2,4,3]
    if ismember(i,[1,2,4])
        Xtest=Proj{i}.V(1:numDim,:)*Z.Xtest;
        Xtrain=Proj{i}.V(1:numDim,:)*Z.Xtrain;
        [Yhat, parms, eta] = LDA_train_and_predict(Xtrain, Z.Ytrain, Xtest);
    elseif i==3 % 
        if strfind(task.name,'MNIST')
            para.K=task.Nks;
            ys=unique(Z.Ytrain);
            Z.Ytrain(Z.Ytrain==ys(1))=0;
            Z.Ytrain(Z.Ytrain==ys(2))=1;
            
            Z.Ytest(Z.Ytest==ys(1))=0;
            Z.Ytest(Z.Ytest==ys(2))=1;
            Xmean=mean(Z.Xtrain')';
            Xtrain=bsxfun(@minus,Z.Xtrain,Xmean);
            Xtest=bsxfun(@minus,Z.Xtest,Xmean);
            
            Xstd=std(Z.Xtrain,[],2);
            Xtrain=bsxfun(@rdivide,Xtrain,Xstd);
            Xtest=bsxfun(@rdivide,Xtest,Xstd);
            
            Xtrain(isnan(Xtrain))=0;
            Xtest(isnan(Xtest))=0;
            
            Z.Xtest=Xtest;
            Z.Xtrain=Xtrain;
            
            opts=struct('nlambda',task.Nks);
            fit=glmnet(Z.Xtrain',Z.Ytrain,'multinomial',opts);
            pfit=glmnetPredict(fit,Z.Xtest',fit.lambda,'response','false',fit.offset);
            siz=size(fit.beta{1});
            GLM_num=zeros(siz(2),1);
            for iii=1:length(fit.beta)
                for jjj=1:siz(2)
                    GLM_num(jjj)=GLM_num(jjj)+length(find(fit.beta{iii}(:,jjj)>0));
                end
            end
            kk=find(GLM_num==numDim,1);
            eta=pfit(:,1,kk)-0.5;
            eta(isnan(eta))=0;
            
            Z.Ytest=-Z.Ytest+2;
        else
            para.K=100;
            fit = road(Z.Xtrain', Z.Ytrain,0,0,para);
            nl=0; kk=1;
            while nl<=numDim, nl=nnz(fit.wPath(:,kk)); kk=kk+1; end
            [~,Yhat,eta] = roadPredict(Z.Xtest', fit);
            eta=eta(:,kk);
        end
    else
        if strfind(task1.name,'MNIST')
            continue
        else
            parms.del=P.del;
            parms.InvSig=pinv(P.Sigma);
            parms.mu=P.mu*P.w;
            
            parms.del=P.mu(:,1)-P.mu(:,2);
            parms.mu=P.mu*P.w;
            parms.thresh=(log(P.w(1))-log(P.w(2)))/2;
            eta = parms.del'*parms.InvSig*Z.Xtest - parms.del'*parms.InvSig*parms.mu - parms.thresh;
        end
    end
    
    
    % class 1 parms
    clear eta1 eta2
    eta1=eta(Z.Ytest==1);
    mu1=mean(eta1);
    sig1=std(eta1);
    
    % class 2 parms
    eta2=eta(Z.Ytest==2);
    mu2=mean(eta2);
    sig2=std(eta2);
    
    % get plotting bounds
    min2=mu2-3*sig2;
    max2=mu2+3*sig2;
    min1=mu1-3*sig1;
    max1=mu1+3*sig1;
    
    t=linspace(min(min2,min1),max(max2,max1),100);
    y2=normpdf(t,mu2,sig2); yy2=y2;
    y1=normpdf(t,mu1,sig1); yy1=y1;
    maxy=max(max(y2),max(y1));
    ls1='-';
    ls2='--';
    
    if i==3
        col1='c'; col2=col1;
        si=1;
        yy1=y2;
        yy2=y1;
    elseif i==2
        col1='g'; col2=col1;
        si=2;
    elseif i==1
        col1='m'; col2=col1;
        si=4;
    elseif i==4
        si=3;
        col1='m'; col2=col1;
    end
    
%     if ~(j==1)
        subplot('Position',[left4 bottom(si), width, height]) %[left,bottom,width,height]
        cla
        hold on
        plot(t,yy2,'linestyle',ls1,'color','b','linewidth',2)
        plot(t,yy1,'linestyle',ls1,'color','g','linewidth',2)
%         dashline(t,yy1,dd,gg,dd,gg,'color','g','linewidth',2)
        if i~=3
            cp=max(find(y2>y1));
            fill(t,[y1(1:cp),y2(cp+1:end)],'k','EdgeColor','k')
        elseif i==3
            yend=find(y2>y1,1)-1;
            fill(t,[y2(1:yend), y1(yend+1:end)],'k','EdgeColor','k')
        end
%         plot([t(cp),t(cp)],[0, maxy],'k')
        
        axis([min(min2,min1), max(max2,max1), 0, 1.05*maxy])
        
        set(gca,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[])
%     end
    
    if i==1, title([{'(D) Learn'};{'Classifier'}],'FontSize',tfs, 'HorizontalAlignment','center'); end
end


%% save plot

if task.savestuff==1
    clear F
    F.PaperSize=[6.5 2.5];ff=findex;
    F.fname=[rootDir, '../Figs/mnist2'];
    F.PaperPosition=[-0.5 0 F.PaperSize];
    F.png=true;
    print_fig(h(6),F)
end


