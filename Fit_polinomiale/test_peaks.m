clear all
close all
clc

%% Costruzione funzione di test

Fc = 1000;
N = 500;
t = (1:N)/Fc;

% Sinusoide
    f = 50;
    A = 5;
    %y = A*sin(2*pi*f.*t);

% Retta
    m = 5;
    q = 2;
    %y = m.*t + q;

% Parabola
    a = 5;
    b = 7;
    c = -3;
    %y = a.*(t.*t) + b.*t + c;

% Retta tridimensionale
    m1 = 50*rand(3,1);
    q1 = 10*rand(3,1);
    y = m1*t + q1;

%% Errore nella misura

sigma = 0.1;
[rows, columns] = size(y);
noise = sigma*randn(rows,length(t));

% Aggiunta dell'errore/anomalia sull'ultimo punto   
y = y + noise;

%% Variabili ricerca picchi

degree = 3; %<- genera messaggi di warning sopra il grado 3, non genera errori nei calcoli per�
gap = 0.2;
num = 20; %<- tenere genralmente sopra il 10

% amps_peak -> ampiezza picchi anomali
amp_peaks = 1.5;

%% Ricerca anomalia - inizializzazioni vettori
% Non necessita del controllo sul numero di elementi inseriti

% vettori dei valori e dei tempi
y1 = [];
t1 = [];

% when -> elementi in cui inseriamo l'anomalia
when = [];

% detection -> vettore che indica se il punto � anomalia o no
detection = [];

% forest -> vettore di elementi da inserire nella foresta
forest = [];

% var_forest -> varianza foresta
%            -> deve essere definita perch� funziona sia da input sia da output
varp_forest = [0; zeros(rows, 1)];

% sigma_forest -> elementi varp_forest in array
sigma_forest = [];

% calc -> vettore dei valori calcolati
calc = [];

%% Ricerca anomalia

figure

for i=1:length(t)
    
    % Inserimento come se fossero sequenziali
    y1 = [y1 y(:,i)];
    t1 = [t1 t(i)];
   
    % Aggiunta di anomalie manualmente
    if randn(1,1)>2.6
        y1(:,i) = y1(:,i).*(amp_peaks+0.1.*randn(rows,1));
        when = [when i];
    end
    
    % Calcoli e acquisizione valori
    [anomaly, v_forest, v_calc, varp_forest] = find_peaks(t1, y1, degree, gap, num);

    detection = anomaly;
    forest = [forest, v_forest];
    sigma_forest = [sigma_forest, varp_forest];
    calc = [calc, v_calc];
    
    
    % Inserimento del punto predetto nel grafico -> rosso
    if  not(isempty(when))&&((when(length(when))-i)==0)
        plot3(v_calc(1,:),v_calc(2,:),v_calc(3,:), '+g');
    else
        plot3(v_calc(1,:),v_calc(2,:),v_calc(3,:), '+r');
    end
    hold on
end

%% Parametri da visualizzare

when
plot3(y1(1,when),y1(2,when),y1(3,when),'+g');

% errori -> indice delle possibili anomalie
errori = find(detection)

valori = y1(:,errori);
calcoli = calc(:,errori);

%forest
variazioni = forest(:,errori);
sigma_forest(:,errori);


%% Grafici

% Grafico segnale originale -> blu
plot3(y1(1,:),y1(2,:),y1(3,:),'-b');

figure

% Grafico degli elementi da inserire nella foresta
plot(forest(1,:),'Color',[1 .5 .2]);
hold on
plot(forest(2,:),'Color',[.4 .8 0]);
hold on
plot(forest(3,:),'Color',[.8 .6 1]);
hold on
% Segnalare le anomalie nella foresta
plot(errori,forest(1,errori),'+','Color',[1 .5 .2]);
plot(errori,forest(2,errori),'+','Color',[0.4 0.8 0]);
plot(errori,forest(3,errori),'+','Color',[0.8 0.6 1]);