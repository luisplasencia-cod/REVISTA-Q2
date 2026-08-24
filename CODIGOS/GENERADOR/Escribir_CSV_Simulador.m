function [archivo_apoyo, archivo_balanceo] = Escribir_CSV_Simulador(trayectoria, id_sujeto, carpeta_salida)
% ESCRIBIR_CSV_SIMULADOR  Escribe los dos CSV de control (apoyo y
%                          balanceo) en el formato EXACTO que ya lee el
%                          simulador, desde la salida de
%                          Generar_Trayectoria.m. E8 de
%                          plan_100_generador.md.
%
%   [archivo_apoyo, archivo_balanceo] = Escribir_CSV_Simulador(trayectoria, id_sujeto, carpeta_salida)
%
% ENTRADA
%   trayectoria      salida de Generar_Trayectoria.m (.apoyo, .balanceo)
%   id_sujeto        string/char, identificador para el nombre de archivo
%   carpeta_salida   carpeta donde escribir (debe existir)
%
% SALIDA: rutas completas de los dos archivos escritos.
%
% FORMATO (verificado contra REFERENCIAS/Control_apoyo_Luis_V4.csv real
% y Desplazamientos.m/Angulo_Control_Plataforma.m - docs/algoritmo/
% contrato_generador.md):
%   Separador   : ;
%   Encabezado  : Tiempo_sagital_<fase>;Posicion_cm_X_<fase>;Posicion_cm_Y_<fase>;Angulo_sagital_<fase>;;;
%   dt          : 0.01 s (remuestreo)
%   Resol. X    : 0.0125 cm (cuantizado)
%   Resol. Y    : 0.00625 cm (cuantizado)
%   Resol. ang. : 0.009 deg (cuantizado)
%
% Precision de escritura: fija en 3 decimales (tiempo) y 4 decimales
% (X/Y/angulo). ACLARACION HONESTA (23-ago-2026, verificado byte a byte
% contra el archivo real): el CSV real (Control_apoyo_Luis_V4.csv) NO
% usa un formato de decimales fijo - imprime "0" en vez de "0.0000" y
% el angulo con 3 decimales en vez de 4 (probablemente exportado con
% un formato tipo %g o editado a mano, no con el patron fijo
% '%.3f;%.4f' que SI usan Desplazamientos.m/Angulo_Control_Plataforma.m
% para otros archivos de la carpeta). Esta funcion usa formato FIJO
% (numericamente equivalente al parsear, no byte-identico en su
% representacion de texto) - decision declarada, no una discrepancia
% oculta: lo que importa para que el simulador funcione es el valor
% numerico tras el parseo, no el conteo de digitos en el texto.
% ==========================================================================

if nargin < 3
    error('Se requieren trayectoria, id_sujeto y carpeta_salida.');
end
if ~isfolder(carpeta_salida)
    error('La carpeta de salida no existe: %s', carpeta_salida);
end

RES_X   = 0.0125;
RES_Y   = 0.00625;
RES_ANG = 0.009;
DT      = 0.01;

archivo_apoyo    = fullfile(carpeta_salida, sprintf('Control_apoyo_%s.csv', id_sujeto));
archivo_balanceo = fullfile(carpeta_salida, sprintf('Control_balanceo_%s.csv', id_sujeto));

escribir_fase(archivo_apoyo,    trayectoria.apoyo,    'apoyo',    DT, RES_X, RES_Y, RES_ANG);
escribir_fase(archivo_balanceo, trayectoria.balanceo, 'balanceo', DT, RES_X, RES_Y, RES_ANG);

end

% ==========================================================================
function escribir_fase(archivo, fase, nombre_fase, dt, res_x, res_y, res_ang)

t_fin = fase.t_s(end);
t_ctrl = 0:dt:t_fin;

x_ctrl   = interp1(fase.t_s, fase.x_cm,       t_ctrl, 'pchip');
y_ctrl   = interp1(fase.t_s, fase.y_cm,       t_ctrl, 'pchip');
ang_ctrl = interp1(fase.t_s, fase.angulo_deg, t_ctrl, 'pchip');

x_q   = round(x_ctrl   / res_x)   * res_x;
y_q   = round(y_ctrl   / res_y)   * res_y;
ang_q = round(ang_ctrl / res_ang) * res_ang;

fid = fopen(archivo, 'w');
if fid == -1, error('No se pudo crear %s', archivo); end
% Encabezado verificado byte a byte contra REFERENCIAS/Control_apoyo_
% Luis_V4.csv y Control_balanceo_Luis_V4.csv reales (23-ago-2026): el
% archivo de APOYO real trae "Angulo_sagital apoyo" con ESPACIO, no
% guion bajo (inconsistencia real del archivo original, no un error de
% este escritor) - se replica tal cual para mantener compatibilidad
% byte a byte, no se "corrige" una inconsistencia que ya existe en el
% dato real que el simulador consume hoy.
if strcmpi(nombre_fase, 'apoyo')
    fprintf(fid, 'Tiempo_sagital_apoyo;Posicion_cm_X_apoyo;Posicion_cm_Y_apoyo;Angulo_sagital apoyo;;;\n');
else
    fprintf(fid, 'Tiempo_sagital_balanceo;Posicion_cm_X_balanceo;Posicion_cm_Y_balanceo;Angulo_sagital_balanceo;;;\n');
end
for k = 1:numel(t_ctrl)
    fprintf(fid, '%.3f;%.4f;%.4f;%.4f;;;\n', t_ctrl(k), x_q(k), y_q(k), ang_q(k));
end
fclose(fid);

end
