clear all
close all

sva_on = 1;

rows = 1;       % dimensione di ogni vettore

%% Variabili ricerca picchi

% degree -> grado polyfit (sopra al 3 genera warning)
degree = 2;
% gap -> massima percentuale di variazione accettabile
gap = 0.3;
% num -> numero di elementi da inserire nel polyfit
num = 15;
% gap_sva -> massima pendenza retta di regressione per identificare il
%            valore costante
gap_sva = 0.1;

% Devono essere definiti perchè funzionano sia da input sia da output

% Pn_2 -> precisione Kalman (inizializzazione)
Pn_2 = 10*eye(3*rows);
% varp_error -> variazione percentuale errori rispetto alla stima
varp_error = [0; zeros((2*sva_on + 1)*rows, 1)];
% var2_error -> varianza media errori rispetto alla stima
var2_error = zeros((2*sva_on + 1)*rows,1);

%% Creazione vettori di test

F = 10;         % Frequenza di campionamento
T = 1/F;        % Tempo fra un campione e l'altro
N = 100;         % numero di campioni
t = (0:N-1)/F;  % vettore dei tempi

s0 = 10*randn(rows,1);     % spazio iniziale
v0 = 10*randn(rows,1);     % velocità iniziale
a0 = 10*randn(rows,1);     % accelerazione iniziale

% a -> accelerazione
% v -> velocità
% s -> spazio

% Errori strumentali e noise
% Errori strumentali
rs = 0.1;
rv = 0.1;
ra = 0.1;
Rn = diag([rs*ones(1,rows) rv*ones(1,rows) ra*ones(1,rows)]);

%Noise misura
sigmas = 0.1;
sigmav = 0.1;
sigmaa = 0.1;

noises = sigmas*randn(rows,N);
noisev = sigmav*randn(rows,N);
noisea = sigmaa*randn(rows,N);

% Spazio costante
    %a = zeros(rows,N) + noisea;
    %v = zeros(rows,N) + noisev;
    %s = s0 + noises;

% Velocità costante
    %a = zeros(rows,N) + noisea;
    %v = v0 + noisev;
    %s = v0*t+ noises;
    
% Accelerazione costante;
    a = a0 + noisea;
    v = a0*t + noisev;
    s = s0 + v0*t + 0.5*a0*t.^2 + noises;
    
% Accelerazione variabile
    %a = a0*t+ noisea;
    %v = v0 + 0.5*a0*t.^2 + noisev;
    %s = s0 + v0*t + (1/6)*a0*t.^2+ noises;
    
%% Valore di amplificazione (picchi)

% amps_peak -> ampiezza picchi anomali
amp_peaks = 1.5;

%% Ricerca anomalia - inizializzazioni vettori
% vettori dei valori e dei tempi
y1 = [];
t1 = [];

% when -> elementi in cui inseriamo l'anomalia
when = [];

% detection -> vettore che indica se il punto ï¿½ anomalia o no
detection = [];

% forest -> vettore di elementi da inserire nella foresta
v_error = [];

% calc -> vettore dei valori calcolati
calc = [];

%% Ricerca anomalia

for i=1:length(t)
    
    % Inserimento come se fossero sequenziali
    if sva_on
        y1 = [y1 [s(:,i); v(:,i); a(:,i)]];
    else
        y1 = [y1 s(:,i)];
    end
    t1 = [t1 t(i)];
   
    % Aggiunta di anomalie manualmente
    if randn(1,1)>2
        now = round(rows*(1+(2*sva_on)*rand(1,1)));
        y1(now,i) = y1(now,i).*(amp_peaks+0.1.*randn(1,1));
        when = [when [now; i]];
    end
    
    % Calcoli e acquisizione valori
    if sva_on
        [anomaly, y_next, error, varp_error, var2_error, Pn_2] = find_peaks_sva(t1, y1, degree, num, gap, varp_error, var2_error, gap_sva, Pn_2, Rn);
    else
        [anomaly, y_next, error, varp_error, var2_error] = find_peaks_general(t1, y1, degree, num, gap, varp_error, var2_error);
    end
    
    detection = [detection anomaly];
    v_error = [v_error, error];
    calc = [calc, y_next];
end

when
if sva_on
    [I, J] = find(detection);
    evaluation = [I'; J'];
    evaluation
else
    find(detection)
end
