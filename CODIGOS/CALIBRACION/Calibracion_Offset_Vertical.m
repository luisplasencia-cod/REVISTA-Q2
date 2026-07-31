% ===================================================
% CALIBRACION DEL OFFSET VERTICAL INICIAL
% Prueba de carga estatica conocida, barrido de offset (mm)
% ===================================================
% Protocolo asociado: docs/planificacion/plan_trabajo_5_semanas_articulo_Q2.md,
% seccion "Protocolo detallado de la prueba de calibracion del offset vertical".
%
% Este script es solo la interfaz interactiva (seleccion de carpeta y
% peso de referencia); todo el analisis estadistico vive en
% Calibracion_Offset_Core.m (regresion con IC, prueba de falta de
% ajuste, prediccion inversa con incertidumbre, diagnostico de
% residuos) para poder probarlo con datos sinteticos sin dialogos
% (ver Test_Calibracion_Offset.m).
%
% CONVENCION DE NOMBRES DE ARCHIVO (obligatoria):
%   Offset_<mm_con_signo>_<numero_de_ensayo>.txt
%   Ejemplos: Offset_+10_1.txt , Offset_-5_2.txt , Offset_0_1.txt
%
% FORMATO DE ARCHIVO ESPERADO (igual a SIMULADOR/FUERZA GRF - SIM):
%   6 columnas separadas por coma, Fz en la columna 3, ~1000 Hz.
% ===================================================

clc; clear; close all;

resp = inputdlg('Peso de la carga de referencia usada en la calibracion (kg):', ...
                 'Carga de referencia', 1, {'20'});
if isempty(resp), error('No se ingreso el peso de referencia.'); end
peso_ref_kg = str2double(resp{1});
if isnan(peso_ref_kg) || peso_ref_kg <= 0
    error('Peso de referencia invalido: "%s"', resp{1});
end

folder = uigetdir(pwd, 'Selecciona la carpeta con los .txt de la prueba de offset');
if folder == 0, error('No se selecciono carpeta'); end

save_folder = uigetdir(pwd, 'Selecciona carpeta para guardar los resultados (cancelar = no exportar)');
if isequal(save_folder, 0), save_folder = ''; end

opciones = struct('umbral_variabilidad_N', 3.0, 'guardar_en', save_folder);
% NOTA: umbral_variabilidad_N=3.0 N es un valor de partida, no calibrado -
% ajustar con el ruido real del AMTI en cuanto haya datos reales.

resultado = Calibracion_Offset_Core(folder, peso_ref_kg, opciones); %#ok<NASGU>
