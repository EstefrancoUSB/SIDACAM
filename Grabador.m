% GRABADOR.
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este c�digo se encarga de la captaci�n de la se�al an�loga del hidr�fono
%y la convierte en se�al digital para su manipulaci�n en el c�digo. Se
%aplica posteriormente el banco de filtros para determinar los umbrales de
%la lancha y ser comparados con la firma ac�stica (documento que es
%previamente cargado). Luego de la comparaci�n se llama a la funci�n
%EstimacionVerde o EstimacionAmarilla seg�n sea el caso.
%


%% Cargo Variables
Frec_Muestreo = 48000;
Dim_fft = 4096;   % Minima longitud de ventana para optima resolucion de la FFT.
Step = 50;       %Delta del banco de filtros, desviaci�n est�ndar

n_bits = 16;      % tama�o de la muestra en bits
seg = 1;          % duracion de la grabacion en segundos
n_canales = 1;    % numero de canal (mono)

% Se carga la base de datos con las firmas ac�sticas
load Firma_B
load Firma_A

%% Grabaci�n
Indicator = 1;
recObj = audiorecorder(Frec_Muestreo, n_bits, n_canales);

while Indicator < 2
    disp('Comienzo Grabaci�n.')
    recordblocking(recObj, seg);
    disp('Fin Grabaci�n.');
    Captacion_Blanco = getaudiodata(recObj);
   
    %% Firma ac�stica
    N_Frec = length(Firma_B);
    Max_Bandas_dB=zeros(1,N_Frec);
    Frec_Corte1 = 300;
    for i=1:N_Frec
        % Dise�o Filtro Pasa-Banda
        Orden_Filtro = 8;
        Frec_Corte2 = Frec_Corte1 + Step;
        Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,...
            Frec_Corte1,Frec_Corte2,Frec_Muestreo);
        Filtro = design(Param_Filtro,'butter');
        % PSD
        S_Blanco_Filtrada = filter(Filtro,Captacion_Blanco);
        [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada, hamming(Dim_fft),[], [], Frec_Muestreo);
        pxxdB = 10*log10(pxx);
        % M�ximos
        [Max_Bandas_dB(i),posicion] = max(pxxdB);
        Frec_Corte1 = Frec_Corte2;
    end
    
    % Comparaci�n con promedio.
    Promedio = sum(Max_Bandas_dB)/N_Frec;
    Comparacion_Prom = zeros(1,N_Frec);
    Firma_Grabacion = zeros(1,N_Frec);
    
    for i=1:N_Frec
        Comparacion_Prom(i) = Max_Bandas_dB(i)/Promedio;    %Se normaliza la Firma ac�stica
        Firma_Grabacion(i) = 1./(Comparacion_Prom(i))^100;  %Se aplica una operaci�n 
                                                           %matem�tica sobre la firma ac�stica
    end
    
    %% Correlacion entre la firma de se�al grabada y la firma ac�stica del blanco en la
                                                                                %Database
    [Correlacion_B,Lag_B] = xcorr(Firma_Grabacion,Firma_B,'coeff');
    [Correlacion_A,Lag_A] = xcorr(Firma_Grabacion,Firma_A,'coeff');
    Maximo_Corr_B = max(Correlacion_B);
    Maximo_Corr_A = max(Correlacion_A);
    [~,pos] = find(Correlacion_B == Maximo_Corr_B);
    Valor_B = Correlacion_B(pos);
    [~,pos] = find(Correlacion_A == Maximo_Corr_A);
    Valor_A = Correlacion_A(pos);
    
    
    %% Definici�n del rango de Confianza
    if Valor_B > 0.8
        disp('Posible Detecci�n Lancha Verde.')
        EstimacionVerde(Captacion_Blanco)
    elseif Valor_A >= 0.7
        disp('Posible Detecci�n Lancha Amarilla')
        EstimacionAmarilla(Captacion_Blanco)
    end
    disp('--------------')
    Indicator = 1;
end


