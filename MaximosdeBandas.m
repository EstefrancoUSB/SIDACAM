% M?XIMOS DE BANDAS.
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
Dim_fft = 4096;  % Minima longitud de ventana para optima resolucion en fft
Frec_Corte1 = 300;
N_Frec = 35;
Step = 50 ;         %Delta del banco de filtros, desviación estándar
ID = 1;             %Indice de directividad (Omnidireccional)
Max_Bandas_dB = zeros(1,N_Frec); %maximo de bandas en dB.                                                               
Frec_Max_B = zeros(1,N_Frec);   %maximos de frecuencias en decibeles                                             
Nivel_Ruido_Vector_B = zeros(1,N_Frec);
Rest_Umbral_B = zeros(1,N_Frec); 
Nivel_S_B = zeros(1,N_Frec);  % Nivel senal vector B.

% Cargando señal a analizar en S_Blanco. 
[S_Blanco, Frec_Muestreo] = audioread('R2-INT1.wav');
[S_R_Fondo, ~] = audioread('RUIDO DE FONDO RECOR.wav');


%% Llenado del vector de m?ximos.
for i=1:N_Frec
    
    % Dise?o Filtro Pasa-Banda
    Orden_Filtro = 8;
    Frec_Corte2 = Frec_Corte1 + Step;
    Param_Filtro = fdesign.bandpass('N,F3dB1,F3dB2',...
        Orden_Filtro,Frec_Corte1,Frec_Corte2,Frec_Muestreo);
    Filtro = design(Param_Filtro,'butter');
   
    % Densidad Espectral de Potencia de la señal filtrada
     S_Blanco_Filtrada = filter(Filtro,S_Blanco);
    [pxx,Frecuencias]=pwelch(S_Blanco_Filtrada,...
        hamming(Dim_fft),[], [], Frec_Muestreo);
    pxxdB = 10*log10(pxx);
        
    % Búsqueda de los valores Máximos y su correspondiente frecuencia
    [Max_Bandas_dB(i),posicion] = max(pxxdB);
    Frec_Max_B(i) = Frecuencias(posicion);
    Frec_Corte1 = Frec_Corte2;
    
end

Max_And_Frec_B = [Max_Bandas_dB;Frec_Max_B]; % Matriz, almacena
            % las frequencies donde hay maximos y su valor.
            

%% Umbrales de detecci?n
for i=1:N_Frec
    % Dise?o Filtro Pasa-Banda 1
    Orden_Filtro = 8;
    [~,position]=min(abs(Frecuencias-Step));  % Busca la posición del vector "Frecuencias"       
                                                %mas cercana a el Step
    Frec_Corte1 = Frec_Max_B(i)-Frecuencias(position);
    Frec_Corte2 = Frec_Max_B(i)+Frecuencias(position);
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
    Nivel_R_dB = 10*log10(sum(PSD_R_Filt(find(Frecuencias==Frec_Corte1):...
        find(Frecuencias==Frec_Corte2))));
    Nivel_S_Blanco_dB = 10*log10...
        (sum(PSD_S_Blanco_Filt(find(Frecuencias==Frec_Corte1) : ...
        find(Frecuencias==Frec_Corte2))));
    
    %Aplicando Ecuación de Sonar Pasivo
    Resta_Umbrales = Nivel_S_Blanco_dB - Nivel_R_dB + ID;
    Nivel_S_B(i)= Nivel_S_Blanco_dB;
    Nivel_Ruido_Vector_B(i) = Nivel_R_dB;
    Rest_Umbral_B(i)= Resta_Umbrales;
end

save ('Frec_Max_B','Frec_Max_B')
save('Nivel_Ruido_Vector_B','Nivel_Ruido_Vector_B');
save('Rest_Umbral_B','Rest_Umbral_B');
save('Nivel_S_B','Nivel_S_B');
save ('Max_And_Frec_B','Max_And_Frec_B')
save('Frecuencias','Frecuencias')
