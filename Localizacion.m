%LOCALIZACIÓN
%Este código es un prototipo para la comparación de una señal captada
%por un arreglo de dos micrófonos. Realizando una correlación entre las dos
%señales puede determinar si el objetivo pasó por un lado A o por un lado
%B.


%% Grabación 1
recObj = audiorecorder(48000, 16,1);
disp('Comienzo Grabación.')
recordblocking(recObj, 9);
disp('Fin Grabación.');
M = getaudiodata(recObj);
M = audioread(''); %señal de prueba.
%% Grabación 2
recObj2 = audiorecorder(48000, 16,1);
disp('Comienzo Grabación.')
recordblocking(recObj2, 9);
disp('Fin Grabación.');
N = getaudiodata(recObj2);
N = audioread(''); %señal de prueba.

[Correla_MN,Lagg] = xcorr(M,N,'coeff');
[~,pos] = max(Correla_MN);
if Lagg(pos) > 0
    disp('La lancha cruzó por el lado A')
elseif Legg(pos) < 0
    disp('La lancha cruzó por el lado B')
end




