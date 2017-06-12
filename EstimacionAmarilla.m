function EstimacionAmarilla(Captacion_Blanco)
% ESTIMACI�N AMARILLA.
% ---------------------------------------------------------------
% Luis Alberto Tafur Jimenez, decano.ingenierias@usbmed.edu.co
% Luis Esteban Gomez, estebang90@gmail.com
% David Perez Zapata, b_hh@hotmail.es
%
%El script "Grabador" llama a esta funci�n si la correlaci�n de detecci�n
%supera el 70% para lancha amarilla. En esta secci�n se cargan algunos
%archivos previamente almacenados, se aplica un banco de filtros y luego
%se comparan algunas frecuencias espec�ficas para determinar los
%porcentajes de confianza de la detecci�n.
%

Frec_Muestreo = 48000;                             
Dim_fft = 4096;        % Minima longitud de ventana para optima resolucion en fft 
Distancia = zeros(1,3);
Step = 50; %Delta del banco de filtros, desviaci�n est�ndar
ID = 1;             %Indice de directividad (Omnidireccional)
load Nivel_Ruido_Vector_A
load Rest_Umbral_A
load Frec_Max_A
load Frecuencias

%% Filtro aplicado a la Primera frecuencia de inter�s
Orden_Filtro = 8;         % Filter Order
[~,position]=min(abs(Frecuencias-Step));
Frec_Corte1 = Frecuencia_Maximos_A(8)-Frecuencias(position);   % cutoff frequency 1
Frec_Corte2 = Frecuencia_Maximos_A(8)+Frecuencias(position);   % cutoff frequency 2
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
%Ecuaci�n de Sonar Pasivo
Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_Ruido_Vector_A(8)+ ID;
Resta_Umbrales_Vector_Captura_A(1) = Resta_Umbrales;
%Definici�n del Umbral de Detecci�n a la Primera frecuencia de inter�s
if Resta_Umbrales >= 8.5
    Distancia(1) = 1;
elseif 6 <= Resta_Umbrales && Resta_Umbrales < 8.5
    Distancia(1) = 2;
    else if 4 < Resta_Umbrales && Resta_Umbrales < 6
        Distancia(1) = 4;
        end
end

%% Filtro aplicado a la Segunda frecuencia de inter�s
Orden_Filtro = 8;         % Filter Order
[~,position]=min(abs(Frecuencias-Step));
Frec_Corte1 = Frecuencia_Maximos_A(12)-Frecuencias(position);   % cutoff frequency 1
Frec_Corte2 = Frecuencia_Maximos_A(12)+Frecuencias(position);   % cutoff frequency 2
Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,...
    Frec_Muestreo);
Filtro = design(Param_Filtro,'butter');
S_Blanco_Filt = filter(Filtro,Captacion_Blanco);
%Densidad Espectral de Potencia
[PSD_S_Blanco_Filt, ~] = pwelch(S_Blanco_Filt,hamming(Dim_fft),[],[],Frec_Muestreo);
%PSD en dB
Nivel_S_Blanco_dB = 10*log10(sum(PSD_S_Blanco_Filt(find(Frecuencias==Frec_Corte1):...
    find(Frecuencias==Frec_Corte2))));
%Ecuaci�n de Sonar Pasivo
Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_Ruido_Vector_A(12) + ID;
Resta_Umbrales_Vector_Captura_A(2) = Resta_Umbrales;
%Definici�n del Umbral de Detecci�n a la Segunda frecuencia de inter�s
if Resta_Umbrales >= 7
    Distancia(2) = 1;
elseif 4 <= Resta_Umbrales && Resta_Umbrales < 7
    Distancia(2) = 2;
else if 2 < Resta_Umbrales && Resta_Umbrales < 4
        Distancia(2)=4;
    end
end

%% Filtro aplicado a la Tercera frecuencia de inter�s
Orden_Filtro = 8;         % Filter Order
[~,position]=min(abs(Frecuencias-Step));
Frec_Corte1 = Frecuencia_Maximos_B(24)-Frecuencias(position);   % cutoff frequency 1
Frec_Corte2 = Frecuencia_Maximos_B(24)+Frecuencias(position);   % cutoff frequency 2
Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,...
    Frec_Muestreo);
Filtro = design(Param_Filtro,'butter');
S_Blanco_Filt = filter(Filtro,Captacion_Blanco);
%Densidad Espectral de Potencia
[PSD_S_Blanco_Filt, ~] = pwelch(S_Blanco_Filt,hamming(Dim_fft),[],[],Frec_Muestreo);
%PSD en dB
Nivel_S_Blanco_dB = 10*log10(sum(PSD_S_Blanco_Filt(find(Frecuencias==Frec_Corte1):...
    find(Frecuencias==Frec_Corte2))));
%Ecuaci�n de Sonar Pasivo
Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_Ruido_Vector_B(24) + ID;
Resta_Umbrales_Vector_Captura_A(3) = Resta_Umbrales;
%Definici�n del Umbral de Detecci�n a la Tercera frecuencia de inter�s
if Resta_Umbrales >= 19.5
    Distancia(3) = 1;
elseif 17 <= Resta_Umbrales && Resta_Umbrales < 19.5
    Distancia(3) = 2;
else if 13 < Resta_Umbrales && Resta_Umbrales < 17
        Distancia(3)=4;
    end
end

%% An�lisis de detecci�n
cont = 0;
if Resta_Umbrales_Vector_Captura_A(1) >= Resta_Umbrales_Vector_A(8); 
disp('>>> Detecci�n Freq 1')
cont = cont + 1;
end
if Resta_Umbrales_Vector_Captura_A(2) >= Resta_Umbrales_Vector_A(12);
 disp('>>> Detecci�n Freq 2')
 cont = cont + 1;
end
if Resta_Umbrales_Vector_Captura_A(3) >= Resta_Umbrales_Vector_A(24);
 disp('>>> Detecci�n Freq 3')
 cont = cont + 1;
end 
 
if cont == 1;
disp('porcentaje de detecci�n 33,333%')
elseif cont == 2;
disp ('Porcentaje de detecci�n 66,666%')
elseif cont == 3;
disp ('Porcentaje de detecci�n 100%')
else
    disp('>>> No hay Detecci�n')
end 
%C�lculo de la distancia de aproximaci�n
Distancia = sum(Distancia)/length(Distancia);
a = ['La distancia aproximada es: ', num2str(Distancia),'m'];
disp(a)
