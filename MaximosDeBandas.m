% M�XIMOS DE BANDAS.
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
% Codigo encargado de Grabar tanto la señal de la 
% lancha como del ruido de fondo, obtener de cada
% una su PSD y por medio de un banco de filtros
% llegar a obtener los umbrales de deteccion.
% 

%% Inicializacion de variables. 
Dim_fft = 4096; % Minima longitud de ventana para optima
                                  % resolucion en fft
Frec_Corte1 = 300;
N_Frec = 35;
Max_Bandas_dB = zeros(1,N_Frec); %maximo de bandas en dB.                                                               
Frec_Max_B = zeros(1,N_Frec);   %maximos de frecuencias en 
                                                 % decibeles
Nivel_Ruido_Vector_B = zeros(1,N_Frec);
Rest_Umbral_B = zeros(1,N_Frec); 
Nivel_S_B = zeros(1,N_Frec);  % Nivel senal vector B.

% Cargando señal a analizar en S_Blanco. 
[S_Blanco, Frec_Muestreo] = audioread('R2-INT1.wav');
[S_R_Fondo, ~] = audioread('RUIDO DE FONDO RECOR.wav');
% S_R_Fondo         % Señal de ruido de fondo

%% Llenado del vector de m�ximos.
for i=1:N_Frec
    
    % Dise�o Filtro Pasa-Banda
    Orden_Filtro = 8;
    Frec_Corte2 = Frec_Corte1 + 50;
    Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',...
        Orden_Filtro,Frec_Corte1,Frec_Corte2,Frec_Muestreo);
    Filtro = design(Param_Filtro,'butter');
    S_Blanco_Filtrada = filter(Filtro,S_Blanco);
    
    % PSD
    [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada,...
        hamming(Dim_fft),[], [], Frec_Muestreo);
    pxxdB = 10*log10(pxx);
    
    %  semilogx(Frecuencias,pxxdB)
    %  xlim([300 2500])
    
    % M�ximos
    [Max_Bandas_dB(i),posicion] = max(pxxdB);
    Frec_Max_B(i) = Frecuencias(posicion);
    Frec_Corte1 = Frec_Corte2;
    % hold on
end

Umbrales_B = [Max_Bandas_dB;Frec_Max_B]; % Matriz, almacena
            % las frequencies donde hay maximos y su valor.
            
% semilogx(FreqDeMaxA,MaxdB,'linewidth',3)

%% Graficaci�n

% [NL_PSD,f] = pwelch(y2,hamming(dim_fft),[],[],fs);
% [M_40M_PSD,~] = pwelch(y,hamming(dim_fft),[],[],fs);
% NL_PSD = 10*log10(abs(NL_PSD));
% M_40M_PSD = 10*log10(abs(M_40M_PSD));
% plot1=plot(f,M_40M_PSD,'b',f,NL_PSD,'r');
% set(plot1(1),'DisplayName','Se�al');
% set(plot1(2),'DisplayName','Ruido Fondo');
% legend
% xlim([200 5000])
% xlabel('Frecuencia [Hz]')
% ylabel('PSD [dB/Hz]')
% title('Comparaci�n se�al de an�lisis con ruido de fondo.')

%% Umbrales de detecci�n
for i=1:N_Frec
    % Dise�o Filtro Pasa-Banda 1
    Orden_Filtro = 8;
    Frec_Corte1 = Frec_Max_B(i)-Frecuencias(5);
    Frec_Corte2 = Frec_Max_B(i)+Frecuencias(5);
    % Diseñando el filtro pasabando
    Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',...
        Orden_Filtro,Frec_Corte1,Frec_Corte2,Frec_Muestreo);
    Filtro = design(Param_Filtro,'butter');
    % Aplicando filtros al Ruido de fondo y a la señal de blando
    R_Filt = filter(Filtro,S_R_Fondo);
    S_Blanco_Filt = filter(Filtro,S_Blanco); 
    
    % Aplicando PSD con ventaneo tipo hamming
    PSD_R_Filt = pwelch(R_Filt,...
        hamming(Dim_fft),[],[],Frec_Muestreo);
    PSD_S_Blanco_Filt = pwelch(S_Blanco_Filt,...
        hamming(Dim_fft),[],[],Frec_Muestreo);
    
    % Escalando magnitud a dB.
    Nivel_R_dB = 10*log10...
        (sum(PSD_R_Filt(find(Frecuencias==Frec_Corte1) : ...
        find(Frecuencias==Frec_Corte2))));
    Nivel_S_Blanco_dB = 10*log10...
        (sum(PSD_S_Blanco_Filt(find(Frecuencias==Frec_Corte1) : ...
        find(Frecuencias==Frec_Corte2))));
    Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_R_dB + 1;
    Nivel_S_B(i)= Nivel_S_Blanco_dB;
    Nivel_Ruido_Vector_B(i) = Nivel_R_dB;
    Rest_Umbral_B(i)= Resta_Umbrales;
end

save ('Frecuencia_Maximos_B','Frec_Max_B')
save('Nivel_Ruido_Vector_B','Nivel_Ruido_Vector_B');
save('Resta_Umbrales_Vector_B','Rest_Umbral_B');
save('Nivel_Senal_Vector_B','Nivel_S_B');
save ('MaximosYSusFrecuencias_B','Umbrales_B')
save('Frecuencias','Frecuencias')

