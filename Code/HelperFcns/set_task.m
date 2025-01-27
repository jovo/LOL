function task = set_task(task)
% sets up all metadata associated with the input task
%
% INPUT: task (struct or char): a structure containing various task settings
% OUTPUT: task:   update task structure

if isstruct(task)
    name=task.name;
else
    name=task;
end
    % change settings for certain cases
if strfind(name,'DRL')
    task.QDA_model=0;
elseif strcmp(name,'IPMN-HvL') || strcmp(name,'IPMN-HvML') || strcmp(name,'IPMN-HMvL') || strcmp(name,'IPMNvsAll') || strcmp(name,'MCNvsAll') || strcmp(name,'SCAvsAll')
    task.simulation=0;
    task.ntrials=1000;                        % # of trials
elseif strcmp(name,'colon')
    task.simulation=0;
elseif strcmp(name,'prostate')
    task.simulation=0;
elseif strfind(name,'xor')
    task.QDA_model=0;
elseif strcmp(name,'parallel cigars')
    task.ntrain=50;
elseif strcmp(name,'rotated cigars')
    task.ntrain=50;
elseif strcmp(name,'semisup cigars')
    task.ntrain = 500;
    task.percent_unlabeled=0.9;
elseif strcmp(name,'semisup rotated cigars')
    task.ntrain = 500;
    task.percent_unlabeled=0.9;
elseif strcmp(name,'amen')==1
    task.simulation = 0;
    task.ntrain=5112;
    task.ntest=569;
    if ~isfield(task,'ks'), task.ks=unique(round(logspace(0,2.9,30))); end
    if ~isfield(task,'algs'), task.algs={'LDA','SLOL','LOL','RF'}; end
% elseif strfind(name,'toeplitz, D')>0 
%     Dind=strfind(task.name,'D');
%     task.D=str2double(task.name(Dind+2:end));
% elseif strfind(name,'wra, D')==1 
%     Dind=strfind(task.name,'D');
%     task.D=str2double(task.name(Dind+2:end));
%     task.name='wra';
end


if strfind(name,', D=')>0 
    Dind=strfind(task.name,', D=');
    task.D=str2double(task.name(Dind+4:end));
end

% default settings
if ~isfield(task,'name'),       task.name=name;     end                         % name of task
if ~isfield(task,'simulation'), task.simulation=1;  end                    % is this a simulation
if ~isfield(task,'QDA_model'),  task.QDA_model=1;   end                   % does this simulation satisfy the QDA model
if ~isfield(task,'ks'),         task.ks=1:100;      end                          % list of dimensions to embed into
if ~isfield(task,'Kmax'),       task.Kmax=max(task.ks); end                          % list of dimensions to embed into
if ~isfield(task,'Nks'),        task.Nks=length(task.ks); end                          % list of dimensions to embed into
if ~isfield(task,'algs'),       task.algs={'LOL';'ROAD'};  end % which algorithms to use
if ~isfield(task,'savestuff'),  task.savestuff=1;   end                       % flag whether to save data & figures
if ~isfield(task,'ntrials'),    task.ntrials = 5;   end                   % # of trials
if ~isfield(task,'ntrain'),     task.ntrain  = 50;  end                  % # of training samples
if ~isfield(task,'ntest'),      task.ntest   = 500; end                     % # of test samples
if ~isfield(task,'percent_unlabeled'),      task.percent_unlabeled = 0; end                     % # of test samples

if task.simulation==0
    task.QDA_model=0;
end

task.Nalgs=length(task.algs);           % # of algorithms to use
task.n=sum(task.ntrain)+task.ntest;     % # of total samples
task=orderfields(task);                 % sort fields
if isfield(task,'types'), [~, ~, task.types] = parse_algs(task.types); end % sort types
