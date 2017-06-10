% VALORES FIRMA ACÚSTICA.

%Este código reconoce los valores máximos por cada banco de filtro aplicado
%a la señal, a éstos se les aplica una PSD para luego relacionar
%valores y llegar a parametrizar la firma acústica.

%
%% Determinación de máximos.
Dimension_fft = 2048*2;
N_Frecuencias = 35;  
Frec_Corte1 = 300;
Firma_B = zeros(1,N_Frecuencias);
Maximo_Bandas_dB = zeros(1,N_Frecuencias);
Frecuencia_Maximos_B =zeros(1,N_Frecuencias);
[Senal_Blanco, Frecuencia_Muestreo] = audioread('R2-INT1.wav');  
[Senal_Ruido_Fondo, ~] = audioread('RUIDO DE FONDO RECOR.wav');
[pxx,~]=pwelch(Senal_Blanco, hamming(Dimension_fft),[], [], Frecuencia_Muestreo);
[pxx2,Frecuencias]=pwelch(Senal_Ruido_Fondo, hamming(Dimension_fft),[], [], Frecuencia_Muestreo);

% plot(f,10*log10(pxx),'r',f,10*log10(pxx2))
% xlim([300,5000])

%% Llenado del vector de máximos.
for i=1:N_Frecuencias
% Diseño Filtro Pasa-Banda
Orden_Filtro = 8;        
Frec_Corte2 = Frec_Corte1 + 40;   
Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
Filtro = design(Parametros_Filtro,'butter');
Senal_Blanco_Filtrada = filter(Filtro,Senal_Blanco);
% PSD
[pxx,Frecuencias]=pwelch(Senal_Blanco_Filtrada, hamming(Dimension_fft),[], [], Frecuencia_Muestreo);
pxxdB = 10*log10(pxx);
% Máximos
[Maximo_Bandas_dB(i),posicion] = max(pxxdB);
Frecuencia_Maximos_B(i) = Frecuencias(posicion);
Frec_Corte1 = Frec_Corte2;
end 

%% Parámetros firma acústica
Promedio = sum(Maximo_Bandas_dB)/N_Frecuencias;
Comparacion_Prom = zeros(1,N_Frecuencias);
Comparacion_Log = zeros(1,N_Frecuencias);

for i=1:N_Frecuencias
    Comparacion_Prom(i) = Maximo_Bandas_dB(i)/Promedio;          
    Firma_B(i) =1./(Comparacion_Prom(i))^100;    
    Comparacion_Log(i) = log10(Comparacion_Prom(i));     
end
    
MaximosYSusFrecuencias_B = [Frecuencia_Maximos_B',Maximo_Bandas_dB',Comparacion_Prom',Firma_B',Comparacion_Log'];
save('Firma_B','Firma_B')
save ('MaximosYSusFrecuencias_B','MaximosYSusFrecuencias_B')
filename = 'MaximosYSusFrecuencias_B.xlsx';
xlswrite(filename,MaximosYSusFrecuencias_B)
