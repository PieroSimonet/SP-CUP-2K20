%% Check for grafics clean
%if exist('tmp','var')
%    for i=1:tmp-1
%        clf(figure (i));
%    end
%else
%    close all
%end
%% Start of Main
addpath('./Find_peaks/');
addpath('./Tree/');
addpath('./Tree/Utils/');

clear all;

run InizializeNameOfFiles.m;

%% Inizializzazione variabili sistema

[numForest, numElementForest, degree, num, gap, gap_k, ~] = OptimizeParameter();
bagFile = bagManager(file1);
anomaly = AnomalyDetection();
kalman_ok = zeros(2,4);
treesManager = TreesManager();
treesManager = treesManager.SetNameMap(CreateTreeMap());

%% Vettori per i test

see = {};
test = 0;
j = 1;

%% Main

% Esistenza dati successivi
while not(bagFile.LastTimeDone())    
    % Estrazione dati
        % data - {i,1}: valori misurati
        %        {i,2}: vettore dei tempi
        %        {i,3}: tipologia dato
        data = bagFile.getData();
        
        kalman_ok = multi_kalman_ok(data, num, kalman_ok);
        
    % Controllo tutti i sensori
        % se in bagFile ci sono piu' sensori da controllare che quelli
        % principali sostituire n_sensor con il numero di sensori principali e
        % RICORDARSI DI INSERIRE QUELLI PRINCIPALI IN CIMA
        [n_sensor, ~] = size(data);
    
    for i=1:n_sensor
        %% Picchi e dati per IsolationForest
            % Picchi
            if not(isempty(data{i,1}))
                [already_analyzed, anomaly_out, index_out, variation, y_calc, data_type, kalman_ok] = FindPeaksWrapper(data{i,2}, data{i,1}, data{i,3}(1), degree, num, gap, gap_k, kalman_ok);
                n_analysed(j,i) = length(anomaly_out{1}) - already_analyzed;
            else
                already_analyzed = true;
            end
        
        if not(already_analyzed)
            
            [rows_data, ~] = size(data_type);
            
            for k=1:rows_data
            % Foresta
                [ ~, forest_anomaly, position_anomaly, ~, s] = IsolationForest( numForest, numElementForest, numElementForest, 0.7, data_type{k,1}, (variation{k})');
            
            % Aggiornamento riscontro picchi
                anomaly = anomaly.update(anomaly_out{k}, index_out(k), forest_anomaly, position_anomaly, data_type{k,1});
            
            % Per ogni elemento in output dalla funzione di ricerca picchi
                see = update(see, anomaly_out{k}, variation{k}, y_calc{k}, data_type{k}(1));
            end
            
            tmp = plot_all(see, data);
            
        end
    end
    
    j = j+1;
    
    %% ANALISI ALBERI DI CHECK
    if ~isempty(anomaly.peaks)
        % anomaly_out{1}(end) -> in cui da un vettore che non ho analizzato lo da tutto 
       %treesManager.PushData(data);
       %treesManager.SearchTree(@peaksWrapper);
    end
    
    if ~isempty(anomaly.forest)
       %treesManager.PushData(data);
       % treesManager.SearchTree();
    end
    
    % reset picchi
    %anomaly = anomaly.reset();
    
    % Per ora segna solo la differenza di tempo tra la chiamata e la
    % precendete
    [numForest, numElementForest, degree, num, gap, gap_k, diffTime] = OptimizeParameter();
    
    % output funzione di ottimizzazione parametri
    new_values(j-1,:) = [numForest, numElementForest, degree, num, gap, gap_k, diffTime];
    
    bagFile = bagFile.updateTime(diffTime);
    
end

% numero elementi analizzati ad ogni ciclo per ogni sensore
n_analysed
% valore sensori
new_values


sum(new_values(:,7))
%% Plot e controlli

function tmp = plot_all(see,data)
    % on - attivazione plot (disattivare per vedere prestazioni generali)
        on = false;

    if on
        % tmp - variabile di supporto per  i grafici
            tmp = 1;

        [rows_see, ~] = size(see);
        for k = 1:rows_see
            for i=1:rows_see
                if data{i,3} == see{k,4}
                    measure = data{i,1};
                end
            end
            [rows, ~] = size(see{k,2});
            for j=1:rows
                % Visualizzazione previsioni
                figure (tmp)
                plot(see{k,3}(j,:),'-b'); % blu predetto
                hold on
                plot(measure(j,:),'-k'); % nero misurato
                plot(find(see{k,1}), see{k,3}(j,find(see{k,1})), '+r') % punti anomalia
                tmp = tmp+1;
                title(see{k,4}(1));
                % Visualizzazione errori
                %figure (a)
                %plot(see{k,2}(j,:))
                %title(data_type{k,1})
                %tmp = tmp+1;
            end
        end
    else
        tmp = 0;
    end
end

% update - funzione di supporto per la visualizzazione dei dati
function see_new = update(see, anomaly, variation, y_calc, data_type)
    
    [rows, ~] = size(see);
    
    index = 0;
    for i= 1:rows
       if data_type == see{i,4} 
            index = i;
       end
    end
    
    if index==0
        index = rows+1;
        see{index,1} = anomaly;
        see{index,2} = variation;
        see{index,3} = y_calc;
        see{index,4} = data_type;
    else
        see{index,1} = [see{index,1} anomaly];
        see{index,2} = [see{index,2} variation];
        see{index,3} = [see{index,3} y_calc];
    end
    
    see_new = see;
    
end


function anom = peaksWrapper(node)

    t = node.t;
    y = node.data;
    typ = node.name;
    [~, anom, ~, ~, ~, ~, ~] = FindPeaksWrapper(t,y,typ,0,0,0,0,0);

end
