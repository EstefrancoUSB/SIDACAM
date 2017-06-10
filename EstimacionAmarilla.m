function EstimacionAmarilla(Captacion_Blanco)
% ESTIMACIÓN AMARILLA.

%El script "Grabador" llama a esta función si la correlación de detección
%supera el 70% para lancha amarilla. En esta sección se cargan algunos
%archivos previamente almacenados, se aplica un banco de filtros y luego
%se comparan algunas frecuencias específicas para determinar los
%porcentajes de confianza de la detección.
%

Frecuencia_Muestreo = 48000;                            
Dimension_fft = 2048*2;        
Distancia = zeros(1,3);
load Nivel_Ruido_Vector_A
load Resta_Umbrales_Vector_A
load Frecuencia_Maximos_A
load Frecuencias


%% Primer filtro
Orden_Filtro = 8;        
Frec_Corte1 = Frecuencia_Maximos_A(8)-Frecuencias(5);   
Frec_Corte2 = Frecuencia_Maximos_A(8)+Frecuencias(5);   
Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
Filtro = design(Parametros_Filtro,'butter');
Filtro_Senal_Blanco = filter(Filtro,Captacion_Blanco);
[PSD_Senal_Blanco_Filtrada, ~] = pwelch(Filtro_Senal_Blanco,hamming(Dimension_fft),[],[],Frecuencia_Muestreo);
Nivel_Senal_Blanco_dB = 10*log10(sum(PSD_Senal_Blanco_Filtrada(find(Frecuencias==Frec_Corte1):find(Frecuencias==Frec_Corte2))));
Resta_Umbrales = Nivel_Senal_Blanco_dB - Nivel_Ruido_Vector_A(8)+ 1;
Resta_Umbrales_Vector_Captura_A(1) = Resta_Umbrales;
if Resta_Umbrales >= 8.5
    Distancia(1) = 1;
elseif 6 <= Resta_Umbrales && Resta_Umbrales < 8.5
    Distancia(1) = 2;
    else if 4 < Resta_Umbrales && Resta_Umbrales < 6
        Distancia(1) = 4;
        end
end

%% Segundo Filtro
Orden_Filtro = 8;      
Frec_Corte1 = Frecuencia_Maximos_A(12)-Frecuencias(5);   
Frec_Corte2 = Frecuencia_Maximos_A(12)+Frecuencias(5);   
Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
Filtro = design(Parametros_Filtro,'butter');
Filtro_Senal_Blanco = filter(Filtro,Captacion_Blanco);
[PSD_Senal_Blanco_Filtrada, ~] = pwelch(Filtro_Senal_Blanco,hamming(Dimension_fft),[],[],Frecuencia_Muestreo);
Nivel_Senal_Blanco_dB = 10*log10(sum(PSD_Senal_Blanco_Filtrada(find(Frecuencias==Frec_Corte1):find(Frecuencias==Frec_Corte2))));
Resta_Umbrales = Nivel_Senal_Blanco_dB - Nivel_Ruido_Vector_A(12) + 1;
Resta_Umbrales_Vector_Captura_A(2) = Resta_Umbrales;
if Resta_Umbrales >= 7
    Distancia(2) = 1;
elseif 4 <= Resta_Umbrales && Resta_Umbrales < 7
    Distancia(2) = 2;
else if 2 < Resta_Umbrales && Resta_Umbrales < 4
        Distancia(2)=4;
    end
end

%% Tercer Filtro
Orden_Filtro = 8;         
Frec_Corte1 = Frecuencia_Maximos_A(24)-Frecuencias(5);  
Frec_Corte2 = Frecuencia_Maximos_A(24)+Frecuencias(5);  
Parametros_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',Orden_Filtro,Frec_Corte1,Frec_Corte2,Frecuencia_Muestreo);
Filtro = design(Parametros_Filtro,'butter');
Filtro_Senal_Blanco = filter(Filtro,Captacion_Blanco);
[PSD_Senal_Blanco_Filtrada, ~] = pwelch(Filtro_Senal_Blanco,hamming(Dimension_fft),[],[],Frecuencia_Muestreo);
Nivel_Senal_Blanco_dB = 10*log10(sum(PSD_Senal_Blanco_Filtrada(find(Frecuencias==Frec_Corte1):find(Frecuencias==Frec_Corte2))));
Resta_Umbrales = Nivel_Senal_Blanco_dB - Nivel_Ruido_Vector_A(24) + 1;
Resta_Umbrales_Vector_Captura_A(3) = Resta_Umbrales;
if Resta_Umbrales >= 19.5
    Distancia(3) = 1;
elseif 17 <= Resta_Umbrales && Resta_Umbrales < 19.5
    Distancia(3) = 2;
else if 13 < Resta_Umbrales && Resta_Umbrales < 17
        Distancia(3)=4;
    end
end

%% Análisis detección
cont = 0;
if Resta_Umbrales_Vector_Captura_A(1) >= Resta_Umbrales_Vector_A(8); 
disp('>>> Detección Freq 1')
cont = cont + 1;
end
if Resta_Umbrales_Vector_Captura_A(2) >= Resta_Umbrales_Vector_A(12);
 disp('>>> Detección Freq 2')
 cont = cont + 1;
end
if Resta_Umbrales_Vector_Captura_A(3) >= Resta_Umbrales_Vector_A(24);
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

Distancia = sum(Distancia)/length(Distancia);
a = ['La distancia aproximada es: ', num2str(Distancia),'m'];
disp(a)
