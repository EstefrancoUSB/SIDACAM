function EstimacionVerde(Captacion_Blanco)
% ESTIMACIÓN VERDE.
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%El script "Grabador" llama a esta función si la correlación de detección
%supera el 80% para lancha verde. En esta sección se cargan algunos
%archivos previamente almacenados, se aplica un banco de filtros y luego
%se comparan algunas frecuencias específicas para determinar los
%porcentajes de confianza de la detección.
%

Frec_Muestreo = 48000;                             
Dim_fft = 4096;       % Minima longitud de ventana para optima resolucion en fft 
Distancia = zeros(1,3);
Step = 50;  %Delta del banco de filtros, desviación estándar
ID = 1;             %Indice de directividad (Omnidireccional)
load Nivel_Ruido_Vector_B
load Rest_Umbral_B
load Frec_Max_B
load Frecuencias


%% Filtro aplicado a la Primera frecuencia de interés
Orden_Filtro = 8;                                                % Filter Order
[~,position]=min(abs(Frecuencias-Step));
Frec_Corte1 = Frec_Max_B(15)-Frecuencias(position);   % cutoff frequency 1
Frec_Corte2 = Frec_Max_B(15)+Frecuencias(position);   % cutoff frequency 2
Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,...
    Frec_Muestreo);
Filtro = design(Param_Filtro,'butter');
S_Blanco_Filt = filter(Filtro,Captacion_Blanco);
%Densidad Espectral de Potencia
[PSD_S_Blanco_Filt, ~] = pwelch(S_Blanco_Filt,hamming(Dim_fft),[],[],...
    Frec_Muestreo);
%PSD en dB
Nivel_S_Blanco_dB = 10*log10(sum(PSD_S_Blanco_Filt(find...
    (Frecuencias==Frec_Corte1):find(Frecuencias==Frec_Corte2))));
%Ecuación de Sonar Pasivo
Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_Ruido_Vector_B(15)+ ID;
Resta_Umbrales_Vector_Captura_B(1) = Resta_Umbrales;
%Definición del Umbral de Detección a la Primera frecuencia de interés
if Resta_Umbrales >= 31
    Distancia(1) = 1;
elseif 27 <= Resta_Umbrales && Resta_Umbrales < 31
    Distancia(1) = 2;
    else if 15 < Resta_Umbrales && Resta_Umbrales < 27
        Distancia(1) = 4;
        end
end

%% Filtro aplicado a la Segunda frecuencia de interés
Orden_Filtro = 8;                                               % Filter Order
[~,position]=min(abs(Frecuencias-Step));
Frec_Corte1 = Frec_Max_B(20)-Frecuencias(position);   % cutoff frequency 1
Frec_Corte2 = Frec_Max_B(20)+Frecuencias(position);   % cutoff frequency 2
Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,...
    Frec_Muestreo);
Filtro = design(Param_Filtro,'butter');
S_Blanco_Filt = filter(Filtro,Captacion_Blanco);
%Densidad Espectral de Potencia
[PSD_S_Blanco_Filt, ~] = pwelch(S_Blanco_Filt,hamming(Dim_fft),[],[],Frec_Muestreo);
%PSD en dB
Nivel_S_Blanco_dB = 10*log10(sum(PSD_S_Blanco_Filt(find(Frecuencias==Frec_Corte1):...
    find(Frecuencias==Frec_Corte2))));
%Ecuación de Sonar Pasivo
Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_Ruido_Vector_B(20) + ID;
Resta_Umbrales_Vector_Captura_B(2) = Resta_Umbrales;
%Definición del Umbral de Detección a la Segunda frecuencia de interés
if Resta_Umbrales >= 25
    Distancia(2) = 1;
elseif 17 <= Resta_Umbrales && Resta_Umbrales < 25
    Distancia(2) = 2;
else if 8 < Resta_Umbrales && Resta_Umbrales < 17
        Distancia(2)=4;
    end
end

%% Filtro aplicado a la Tercera frecuencia de interés
Orden_Filtro = 8;                                               % Filter Order
[~,position]=min(abs(Frecuencias-Step));
Frec_Corte1 = Frec_Max_B(25)-Frecuencias(position);   % cutoff frequency 1
Frec_Corte2 = Frec_Max_B(25)+Frecuencias(position);   % cutoff frequency 2
Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,...
    Frec_Muestreo);
Filtro = design(Param_Filtro,'butter');
S_Blanco_Filt = filter(Filtro,Captacion_Blanco);
%Densidad Espectral de Potencia
[PSD_S_Blanco_Filt, ~] = pwelch(S_Blanco_Filt,hamming(Dim_fft),[],[],Frec_Muestreo);
%PSD en dB
Nivel_S_Blanco_dB = 10*log10(sum(PSD_S_Blanco_Filt(find(Frecuencias==Frec_Corte1):...
    find(Frecuencias==Frec_Corte2))));
%Ecuación de Sonar Pasivo
Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_Ruido_Vector_B(25) + ID;
Resta_Umbrales_Vector_Captura_B(3) = Resta_Umbrales;
%Definición del Umbral de Detección a la Tercera frecuencia de interés
if Resta_Umbrales >= 37
    Distancia(3) = 1;
elseif 33 <= Resta_Umbrales && Resta_Umbrales < 37
    Distancia(3) = 2;
else if 25 < Resta_Umbrales && Resta_Umbrales < 33
        Distancia(3)=4;
    end
end

%% Análisis de detección
cont = 0;
if Resta_Umbrales_Vector_Captura_B(1) >= Rest_Umbral_B(15); 
disp('>>> Detección Freq 1')
cont = cont + 1;
end
if Resta_Umbrales_Vector_Captura_B(2) >= Rest_Umbral_B(20);
 disp('>>> Detección Freq 2')
 cont = cont + 1;
end
if Resta_Umbrales_Vector_Captura_B(3) >= Rest_Umbral_B(25);
 disp('>>> Detección Freq 3')
 cont = cont + 1;
end 
 
if cont == 1;
disp('porcentaje de detección 33,333%')
elseif cont == 2;
disp ('Porcentaje de detección 66,666%')
elseif cont == 3;
disp ('Porcentaje de detección 100%')
else
    disp('>>> No hay Detección')
end 
%Cálculo de la distancia de aproximación
Distancia = sum(Distancia)/length(Distancia);
a = ['La distancia aproximada es: ', num2str(Distancia),'m'];
disp(a)
