% VALORES FIRMA AC�STICA.
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%Este c�digo reconoce los valores m�ximos por cada banco de filtro aplicado
%a la se�al, a �stos se les aplica una PSD para luego relacionar
%valores y llegar a parametrizar la firma ac�stica.
%
%% Determinaci�n de m�ximos.
Dim_fft = 4096; % Minima longitud de ventana para optima resolucion en fft                                
N_Frec = 35;  
Frec_Corte1 = 300;
Step = 50;  %Delta del banco de filtros, desviaci�n est�ndar
Firma_B = zeros(1,N_Frec);
Max_Bandas_dB = zeros(1,N_Frec);
Frec_Max_B =zeros(1,N_Frec);

[S_Blanco, Frec_Muestreo] = audioread('R2-INT1.wav');  
[S_R_Fondo, ~] = audioread('RUIDO DE FONDO RECOR.wav');


%% Llenado del vector de m�ximos.
for i=1:N_Frec
% Dise�o Filtro Pasa-Banda
Orden_Filtro = 8;        
Frec_Corte2 = Frec_Corte1 + Step;   
Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,...
    Frec_Muestreo);
Filtro = design(Param_Filtro,'butter');
% Densidad Espectral de Potencia (Welch)
S_Blanco_Filtrada = filter(Filtro,S_Blanco);
[pxx,Frecuencias]=pwelch(S_Blanco_Filtrada, hamming(Dim_fft),[], [], Frec_Muestreo);
pxxdB = 10*log10(pxx);
% Extracci�n del Valor M�ximo
[Max_Bandas_dB(i),posicion] = max(pxxdB);
Frec_Max_B(i) = Frecuencias(posicion);
Frec_Corte1 = Frec_Corte2;
end 

%% Normalizaci�n y Par�metrizaci�n de la firma ac�stica
Promedio = sum(Max_Bandas_dB)/N_Frec;
Comparacion_Prom = zeros(1,N_Frec);
Comparacion_Log = zeros(1,N_Frec);

for i=1:N_Frec
    Comparacion_Prom(i) = Max_Bandas_dB(i)/Promedio;          
    Firma_B(i) =1./(Comparacion_Prom(i))^100;    
    Comparacion_Log(i) = log10(Comparacion_Prom(i));     
end
    
MaximosYSusFrecuencias_B = [Frec_Max_B',Max_Bandas_dB',Comparacion_Prom',Firma_B',...
    Comparacion_Log'];

%Guardar variables de la Firma Ac�stica
save('Firma_B','Firma_B')
save ('MaximosYSusFrecuencias_B','MaximosYSusFrecuencias_B')
filename = 'MaximosYSusFrecuencias_B.xlsx';
xlswrite(filename,MaximosYSusFrecuencias_B)
