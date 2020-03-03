%%INPUT:
%numTree:(number) Number of trees inside the forest 
%maxPoint: (number) Maximum points inside every tree of the forest 
%sk: (numeber) Anomaly threshold 
%type:(string) Type of the new element 
%newEl:(number vector) New point of the forest 
%
%OUTPUT:
%last: (bool) 1 if newEl is abnormal, 0 otherwise
%Abnormal:(bool) 1 if there are abnormalities, 0 otherwise
%posOfAnomaly:(number vector) index of abnormal points
%h:(numeber vector) Average height of each point in the forest
%s:(numeber vector) Anomaly score of each point in the forest

function [last,Abnormal,posOfAnomaly, h, s]=IsolationForest(numTree,maxPoint,sk,type, newEl)
    
    persistent Data;
    NumTree = numTree; % number of isolation trees
    NumSub = maxPoint; % subsample size
    
    if isempty(Data) %first access
       Data.(type).idx=1;
       idx=Data.(type).idx;
       [~,dim]=size(newEl);
       Data.(type).dati=zeros(maxPoint,dim);
       Data.(type).dati(idx,:)=newEl;%insertion of the new point
       Data.(type).forest=IsolationF(Data.(type).dati(idx,:), NumTree, NumSub);
       h=0;
       s=0;
       Abnormalities=0;
       last=Abnormalities(idx);
       Abnormal=any(Abnormalities);
       posOfAnomaly=find(Abnormalities==1);
       return
       
    else
        
       campi=fields(Data);
       foundIt=0;
       for tmp=1:length(campi)
           if campi{tmp}==type
               foundIt=1;
           end
       end
       
       if foundIt==0 %new type
           Data.(type).idx=1;
           idx=Data.(type).idx;
           [~,dim]=size(newEl);
           Data.(type).dati=zeros(maxPoint,dim);
           Data.(type).dati(idx,:)=newEl;
           Data.(type).forest=IsolationF(Data.(type).dati(idx,:), NumTree, NumSub);
           h=0;
           s=0;
           Abnormalities=0;
           last=Abnormalities(idx);
           Abnormal=any(Abnormalities);
           posOfAnomaly=find(Abnormalities==1);
           return 
           
       else    %type already in the Data
           
           Data.(type).idx=Data.(type).idx+1;
           idx=Data.(type).idx;
           Data.(type).dati(idx,:)=newEl;    %Insertion of the new point
           Data.(type).forest = IsolationF(Data.(type).dati(1:idx,:), NumTree, NumSub);
           [Abnormalities,h,s]= AnomaliesFinder(Data.(type).forest,idx,sk);
           last=Abnormalities(idx);
           Abnormal=any(Abnormalities);
           posOfAnomaly=find(Abnormalities==1);
           
       end
    end    
end
%% Isolation Forest
function Forest = IsolationF(Data, NumTree, NumSub)
 
    Forest.HeightLimit = ceil(log2(NumSub));%Set Height limit
    [NumInst, DimInst] = size(Data);
    if NumSub>NumInst
        NumSub=NumInst;
    end
    Forest.Trees = cell(NumTree, 1);%Creation of empty trees
%Forest Properties
    Forest.NumTree = NumTree;
    Forest.NumSub = NumSub;
    Forest.NumDim = DimInst;
    Forest.c = 2 * (log(NumSub - 1) + 0.5772156649) - 2 * (NumSub - 1) / NumSub;

    for i = 1:NumTree
    
        if NumSub < NumInst % Random selection of sub-data
            [~, SubRand] = sort(rand(1, NumInst));
            IndexSub = SubRand(1:NumSub);
        else
            IndexSub = 1:NumInst;
        end
        Datas=Data(IndexSub,:);
    %Tree Creation
        Forest.Trees{i} = IsolationTree(Datas, 0,Forest.HeightLimit,IndexSub);
    %SubData,Current Height ,Height Limit, Index of SubData
    end
end
%% Isolation Tree
function Tree = IsolationTree(Data,CurrHeight, HeightLimit,idx)
    %SubData,Current Height ,Height Limit, Index of SubData

    Tree.Height = CurrHeight;
    [NumInst,NumDim] = size(Data);
    %if the points of Data are all equal they are considered as one point
    if NumInst>0
        temp=Data;
        temp=temp-temp(1,:);%temp is a matrix
        temp=any(temp);%temp is a vector of 1-0
        temp=any(temp);%temp is a scalar
    else
        temp=0;
    end
    if CurrHeight >= HeightLimit || NumInst <= 1 ||temp==0%External node
        Tree.NodeStatus = 0;
        Tree.SplitAttribute = [];
        Tree.SplitPoint = [];
        Tree.LeftChild = [];
        Tree.RightChild = [];
        Tree.Size = NumInst;
        Tree.Val=idx;
        return;

    else%internal node
        Tree.NodeStatus = 1;
        % Random selection of attribute(Column)
        [~, rindex] = max(rand(1,NumDim));
        Tree.SplitAttribute = rindex;
        CurtData = Data(:, Tree.SplitAttribute);
        %Random Selection of Value(Row)
        Tree.SplitPoint = min(CurtData) + (max(CurtData) - min(CurtData)) * rand(1);

        %Data Split
        i=CurtData>=Tree.SplitPoint;
        DataR=Data(i,:);
        idxR=idx(i);
        DataL=Data(not(i),:);
        idxL=idx(not(i));
        %Creation of Right and Left Childs
        Tree.LeftChild = IsolationTree(DataL, CurrHeight + 1,HeightLimit,idxL);
        Tree.RightChild = IsolationTree(DataR, CurrHeight + 1,HeightLimit,idxR);
        Tree.size = [];
        Tree.Val=idx;
    end
end
%% Abnormalities Research
function [Abnormalities,h,s]= AnomaliesFinder(Forest,NumInst,sk)

    Abnormalities=zeros(NumInst,1);
    h=zeros(NumInst,1);
    count=zeros(NumInst,1);
    s=zeros(NumInst,1);
    %cnt=0; number of Abnormalities

    for i=1:Forest.NumTree
        tree=Forest.Trees{i};
        for k=1:NumInst
           Height=findH(tree,k);
           h(k,1)=h(k,1)+Height;
           if Height~=0
             count(k,1)=count(k,1)+1;%how many times the point 'i' is on the forest
           end
        end  
    end
    %%disp(count) %Show how many times the point 'i' is on the forest
    h=h./count;%medium height
        for k=1:NumInst
            s(k)=2^(-h(k)/Forest.c);
            if s(k)>sk
                %cnt=cnt+1;
                Abnormalities(k)=1;
            else
                Abnormalities(k)=0;
            end
        end
end   
function [height]= findH(tree,k)
    height=0;
    if tree.NodeStatus==0%return the height only in k is in a leaf
        if any(tree.Val==k)
            height= tree.Height;
            return;
        else
            return;
        end
    else
        height=findH(tree.LeftChild,k);
        if height~=0
            return
        end
        height=findH(tree.RightChild,k);
        return;
    end
end