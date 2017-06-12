% GRABADOR.
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este código se encarga de la captación de la señal análoga del hidrófono
%y la convierte en señal digital para su manipulación en el código. Se
%aplica posteriormente el banco de filtros para determinar los umbrales de
%la lancha y ser comparados con la firma acústica (documento que es
%previamente cargado). Luego de la comparación se llama a la función
%EstimacionVerde o EstimacionAmarilla según sea el caso.
%


%% Cargo Variables
Frec_Muestreo = 48000;
Dim_fft = 4096;   % Minima longitud de ventana para optima resolucion de la FFT.
Step = 50;       %Delta del banco de filtros, desviación estándar

n_bits = 16;      % tamaño de la muestra en bits
seg = 1;          % duracion de la grabacion en segundos
n_canales = 1;    % numero de canal (mono)

% Se carga la base de datos con las firmas acústicas
load Firma_B
load Firma_A

%% Grabación
Indicator = 1;
recObj = audiorecorder(Frec_Muestreo, n_bits, n_canales);

while Indicator < 2
    disp('Comienzo Grabación.')
    recordblocking(recObj, seg);
    disp('Fin Grabación.');
    Captacion_Blanco = getaudiodata(recObj);
   
    %% Firma acústica
    N_Frec = length(Firma_B);
    Max_Bandas_dB=zeros(1,N_Frec);
    Frec_Corte1 = 300;
    for i=1:N_Frec
        % Diseño Filtro Pasa-Banda
        Orden_Filtro = 8;
        Frec_Corte2 = Frec_Corte1 + Step;
        Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,...
            Frec_Corte1,Frec_Corte2,Frec_Muestreo);
        Filtro = design(Param_Filtro,'butter');
        % PSD
        S_Blanco_Filtrada = filter(Filtro,Captacion_Blanco);
        [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada, hamming(Dim_fft),[], [], Frec_Muestreo);
        pxxdB = 10*log10(pxx);
        % Máximos
        [Max_Bandas_dB(i),posicion] = max(pxxdB);
        Frec_Corte1 = Frec_Corte2;
    end
    
    % Comparación con promedio.
    Promedio = sum(Max_Bandas_dB)/N_Frec;
    Comparacion_Prom = zeros(1,N_Frec);
    Firma_Grabacion = zeros(1,N_Frec);
    
    for i=1:N_Frec
        Comparacion_Prom(i) = Max_Bandas_dB(i)/Promedio;    %Se normaliza la Firma acústica
        Firma_Grabacion(i) = 1./(Comparacion_Prom(i))^100;  %Se aplica una operación 
                                                           %matemática sobre la firma acústica
    end
    
    %% Correlacion entre la firma de señal grabada y la firma acústica del blanco en la
                                                                                %Database
    [Correlacion_B,Lag_B] = xcorr(Firma_Grabacion,Firma_B,'coeff');
    [Correlacion_A,Lag_A] = xcorr(Firma_Grabacion,Firma_A,'coeff');
    Maximo_Corr_B = max(Correlacion_B);
    Maximo_Corr_A = max(Correlacion_A);
    [~,pos] = find(Correlacion_B == Maximo_Corr_B);
    Valor_B = Correlacion_B(pos);
    [~,pos] = find(Correlacion_A == Maximo_Corr_A);
    Valor_A = Correlacion_A(pos);
    
    
    %% Definición del rango de Confianza
    if Valor_B > 0.8
        disp('Posible Detección Lancha Verde.')
        EstimacionVerde(Captacion_Blanco)
    elseif Valor_A >= 0.7
        disp('Posible Detección Lancha Amarilla')
        EstimacionAmarilla(Captacion_Blanco)
    end
    disp('--------------')
    Indicator = 1;
end


