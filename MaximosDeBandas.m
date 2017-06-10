% MÁXIMOS DE BANDAS.

% Este código se encarga de recibir las señales de la grabación de la lancha
% y del ruido de fondo, obtener de cada una su PSD y por medio de un banco
% de filtros llegar a obtener los umbrales de detección.

%
%% Cargo de señal y otros datos. 
Dimension_fft = 2048*2;
Frec_Corte1 = 300;
N_Frecuencias = 35;
Maximo_Bandas_dB = zeros(1,N_Frecuencias);
Frecuencia_Maximos_B = zeros(1,N_Frecuencias);
Nivel_Ruido_Vector_B = zeros(1,N_Frecuencias);
Resta_Umbrales_Vector_B = zeros(1,N_Frecuencias);
Nivel_Senal_Vector_B = zeros(1,N_Frecuencias);
[Senal_Blanco, Frecuencia_Muestreo] = audioread('R2-INT1.wav');
[Senal_Ruido_Fondo, ~] = audioread('RUIDO DE FONDO RECOR.wav');

%% Llenado del vector de máximos.
for i=1:N_Frecuencias
    % Diseño Filtro Pasa-Banda
    Orden_Filtro = 8;
    Frec_Corte2 = Frec_Corte1 + 50;
    Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
    Filtro = design(Parametros_Filtro,'butter');
    Senal_Blanco_Filtrada = filter(Filtro,Senal_Blanco);
    % PSD
    [pxx,Frecuencias]=pwelch(Senal_Blanco_Filtrada, hamming(Dimension_fft),[], [], Frecuencia_Muestreo);
    pxxdB = 10*log10(pxx);
    
    %  semilogx(Frecuencias,pxxdB)
    %  xlim([300 2500])
    
    % Máximos
    [Maximo_Bandas_dB(i),posicion] = max(pxxdB);
    Frecuencia_Maximos_B(i) = Frecuencias(posicion);
    Frec_Corte1 = Frec_Corte2;
    % hold on
end

MaximosYSusFrecuencias_B = [Maximo_Bandas_dB;Frecuencia_Maximos_B];
% semilogx(FreqDeMaxA,MaxdB,'linewidth',3)

%% Graficación

% [NL_PSD,f] = pwelch(y2,hamming(dim_fft),[],[],fs);
% [M_40M_PSD,~] = pwelch(y,hamming(dim_fft),[],[],fs);
% NL_PSD = 10*log10(abs(NL_PSD));
% M_40M_PSD = 10*log10(abs(M_40M_PSD));
% plot1=plot(f,M_40M_PSD,'b',f,NL_PSD,'r');
% set(plot1(1),'DisplayName','Señal');
% set(plot1(2),'DisplayName','Ruido Fondo');
% legend
% xlim([200 5000])
% xlabel('Frecuencia [Hz]')
% ylabel('PSD [dB/Hz]')
% title('Comparación señal de análisis con ruido de fondo.')

%% Umbrales de detección
for i=1:N_Frecuencias
    % Diseño Filtro Pasa-Banda 1
    Orden_Filtro = 8;
    Frec_Corte1 = Frecuencia_Maximos_B(i)-Frecuencias(5);
    Frec_Corte2 = Frecuencia_Maximos_B(i)+Frecuencias(5);
    Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
    Filtro = design(Parametros_Filtro,'butter');
    Ruido_Filtrado = filter(Filtro,Senal_Ruido_Fondo);
    Filtro_Senal_Blanco = filter(Filtro,Senal_Blanco);
    PSD_Ruido_Filtrado = pwelch(Ruido_Filtrado,hamming(Dimension_fft),[],[],Frecuencia_Muestreo);
    PSD_Senal_Blanco_Filtrada = pwelch(Filtro_Senal_Blanco,hamming(Dimension_fft),[],[],Frecuencia_Muestreo);
    
    Nivel_Ruido_dB = 10*log10(sum(PSD_Ruido_Filtrado(find(Frecuencias==Frec_Corte1):find(Frecuencias==Frec_Corte2))));
    Nivel_Senal_Blanco_dB = 10*log10(sum(PSD_Senal_Blanco_Filtrada(find(Frecuencias==Frec_Corte1):find(Frecuencias==Frec_Corte2))));
    Resta_Umbrales = Nivel_Senal_Blanco_dB - Nivel_Ruido_dB + 1;
    Nivel_Senal_Vector_B(i)= Nivel_Senal_Blanco_dB;
    Nivel_Ruido_Vector_B(i) = Nivel_Ruido_dB;
    Resta_Umbrales_Vector_B(i)= Resta_Umbrales;
end

save ('Frecuencia_Maximos_B','Frecuencia_Maximos_B')
save('Nivel_Ruido_Vector_B','Nivel_Ruido_Vector_B');
save('Resta_Umbrales_Vector_B','Resta_Umbrales_Vector_B');
save('Nivel_Senal_Vector_B','Nivel_Senal_Vector_B');
save ('MaximosYSusFrecuencias_B','MaximosYSusFrecuencias_B')
save('Frecuencias','Frecuencias')

