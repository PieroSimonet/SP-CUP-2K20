clear all
close all
clc

n_var = 3;      % numero di variabili da inserire nella ricerca
rows(3) = 0;

value = 3;%abs(round(3*randn));
if value==0
    value = 1;
end
for i=1:3
    rows(i) = value;       % dimensione di ogni vettore
end

if n_var>=1
    data_type{1,1} = "spazio";
    data_type{1,2} = rows(1);
end

if n_var>=2
    data_type{2,1} = "velocità";
    data_type{2,2} = rows(2);
end

if n_var==3
    data_type{3,1} = "accelerazione";
    data_type{3,2} = rows(3);
end

%% Variabili ricerca picchi

% degree -> grado polyfit (sopra al 3 genera warning)
degree = 3;
% gap -> massima percentuale di variazione accettabile
gap = 0.5;
% num -> numero di elementi da inserire nel polyfit
num = 10;
% gap_sva -> massima pendenza retta di regressione per identificare il
gap_kalman = 0.3;

% Devono essere definiti perchè funzionano sia da input sia da output
Pn_2{n_var} = [];
varp = Pn_2;
var2 = Pn_2;
for i=1:n_var
    % Pn_2 -> precisione Kalman (inizializzazione)
    Pn_2{i} = 10*eye(rows(i));
    % varp_error -> variazione percentuale errori rispetto alla stima
    varp{i} = [0; zeros(rows(i), 1)];
    % var2_error -> varianza media errori rispetto alla stima
    var2{i} = zeros(rows(i),1);
end

% numero di cicli di Kalman in questa particolare configurazione
n_cycle_kalman = 0;

%% Creazione vettori di test

F = 10;         % Frequenza di campionamento
T = 1/F;        % Tempo fra un campione e l'altro
N = 100;         % numero di campioni
t_sup = (0:N-1)/F;  % vettore dei tempi

t{3} = [];
for i=1:3
    t{i} = t_sup;
end

s0 = 5*randn(rows(1),1);     % spazio iniziale
v0 = 5*randn(rows(2),1);     % velocità iniziale
a0 = 5*randn(rows(3),1);     % accelerazione iniziale

% a -> accelerazione
% v -> velocità
% s -> spazio

%% Errori strumentali e noise
% Errori strumentali
rs = 0.8;
rv = 0.8;
ra = 0.8;
r = [rs, rv, ra];
Rn{3} = [];

for i=1:n_var
    Rn{i} = r(i)*eye(rows(i));
end

%Noise misura
sigmas = 0.5;
sigmav = 0.5;
sigmaa = 0.5;

n{3} = [];
n{1} = sigmas*randn(rows(1),N);
n{2} = sigmav*randn(rows(2),N);
n{3} = sigmaa*randn(rows(3),N);

% Spazio costante
    %y{3} = zeros(rows(3),N) + n{3};
    %y{2} = zeros(rows(2),N) + n{2};
    %y{1} = s0 + n{1};

% Velocità costante
    %y{3} = zeros(rows(3),N) + n{3};
    %y{2} = v0 + n{2};
    %y{1} = v0*t{1}+ n{3};
    
% Accelerazione costante;
    y{3} = a0 + n{3};
    y{2} = a0*t{2} + n{2};
    y{1} = s0 + v0*t{1} + 0.5*a0*t{1}.^2 + n{1};
    
% Accelerazione variabile
    %y{3} = a0*t{3}+ n{3};
    %y{2} = v0 + 0.5*a0*t{2}.^2 + n{2};
    %y{1} = s0 + v0*t{1} + (1/6)*a0*t{1}.^2+ n{1};
   
%% Valore di amplificazione (picchi)

% amps_peak -> ampiezza picchi anomali
amp_peaks = 1.5;

%% Ricerca anomalia - inizializzazioni vettori
% vettori dei valori e dei tempi
y1{n_var} = [];
t1{n_var} = [];

% when -> elementi in cui inseriamo l'anomalia
when{n_var} = [];

% detection -> vettore che indica se il punto e' anomalia o no
detection = when;

% forest -> vettore di elementi da inserire nella foresta
v_error = when;

% calc -> vettore dei valori calcolati
calc = when;

%% Ricerca anomalia

for i=1:N
    
    % Inserimento come se fossero sequenziali
    for k=1:n_var
        y1{k} = [y1{k} y{k}(:,i)];
        t1{k} = [t1{k} t{k}(i)];
    end
  
    % Aggiunta di anomalie manualmente
    if randn(1,1)>1
        sensor = round((n_var-1)*rand+1);
        y1{sensor}(:,i) = (y1{sensor}(:,i)).*(amp_peaks+0.1.*randn(size(y1{sensor}(:,i))));
        when{sensor} = [when{sensor} i];
    end
    
    % Calcoli e acquisizione valori
    [anomaly, y_calc, variation, varp, var2, Pn_2, n_cycle_kalman] = find_peaks(t1, y1, data_type, degree, num, gap, gap_kalman, varp, var2, Pn_2, Rn, n_cycle_kalman);
    
    for k=1:n_var
        detection{k} = [detection{k} anomaly{k}];
        calc{k} = [calc{k} y_calc{k}];
        v_error{k} = [v_error{k} variation{k}];
    end
end

manual{n_var} = [];
detected = manual;

for i=1:n_var
    type_of_data = data_type{i};
    manual{i} = when{i};
    detected{i} = find(detection{i});
end

%% Plot

on = true;

if on
    for k = 1:n_var
        for j=1:rows(k)
            figure ((k-1)*n_var+j)
            plot(calc{k}(j,:),'-b');
            hold on
            plot(y1{k}(j,:),'-k')
            title(data_type{k,1})
            plot(when{k}, y{k}(j,when{k}), '+g')    

            %figure (k+j)
            %plot(v_error{j}(k,:))
            %title(data_type{j,1})
        end
    end
end