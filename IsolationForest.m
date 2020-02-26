%%INPUT:
%Nalb=Numero di alberi all'interno della foresta
%puntiTot: Punti Totali(massimi) dentro ogni albero
%sk=Soglia anomalia
%dato=Nuovo dato da aggiungere
%
%OUTPUT:
%Anomalie=Vettore di identificazione anomalie
%Datas=Matrice contenente tutti i punti attualemnte nella foresta
%h=Vettore delle altezze
%s=Vettore indice di anomalie

function [Anomalie,Datas, h, s]=IsolationForest(Nalb,puntiTot,sk,dato)
    persistent Data;
    persistent idx;
    persistent Forest;
    NumTree = Nalb; % number of isolation trees
    NumSub = puntiTot; % subsample size
    if isempty(Data)
        [~,dim]=size(dato);
        Data=zeros(puntiTot,dim);
        idx=1;
        Data(idx,:)=dato;%inserisce il nuovo dato
        Datas=Data;
        Forest = IsolationF(Data(1:idx,:), NumTree, NumSub);
        h=0;
        s=0;
        Anomalie=0;
        return;
    end
    idx=idx+1;
    Data(idx,:)=dato;%inserisce il nuovo dato
    Datas=Data(1:idx,:);
    Forest = IsolationF(Data(1:idx,:), NumTree, NumSub);
    [Anomalie,h,s]= RicecaAnomalie(Forest,idx,sk);
    
    
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
%% Ricerca Anomalie
function [Anomalie,h,s]= RicecaAnomalie(Forest,NumInst,sk)

    Anomalie=zeros(NumInst,1);
    h=zeros(NumInst,1);
    count=zeros(NumInst,1);
    s=zeros(NumInst,1);
    %cnt=0; number of anomalies

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
                Anomalie(k)=1;
            else
                Anomalie(k)=0;
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