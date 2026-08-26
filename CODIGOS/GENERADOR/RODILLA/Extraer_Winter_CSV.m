function T = Extraer_Winter_CSV()
% EXTRAER_WINTER_CSV  Extrae cadera/rodilla/tobillo (X,Y crudo, cm) de la
%                   hoja A1.Raw_Coordinate de Winter_Appendix_data.xlsx
%                   (Winter, "Biomechanics and Motor Control of Human
%                   Movement" - Tabla A.1, sujeto unico clasico del libro,
%                   digitalizada y compartida por terceros - ver
%                   dustynrobots.com/academia/research/winters-gait-data-in-excel-form).
%                   24-ago-2026, pedido del usuario: usar como referencia
%                   real ADICIONAL para elegir el mejor modelo de RODILLA,
%                   sin gastar Kuopio ni Camargo (reservadas).
%
% ADVERTENCIA DECLARADA: es UN sujeto (n=1), el mismo "sujeto de
% referencia" citado en decenas de libros/software de biomecanica desde
% los 90s - muy usado pedagogicamente pero NO es una base de datos
% poblacional. Sirve como chequeo rapido de forma/orden de magnitud, no
% como sustituto de Kuopio/Camargo para la validacion final con N sujetos.
%
% SALIDA: tabla T con .frame, .t_s, .cadera_x_cm/.cadera_y_cm,
%   .rodilla_x_cm/.rodilla_y_cm, .tobillo_x_cm/.tobillo_y_cm
%   (avanza CONTINUO en X - es posicion real de laboratorio, no relativa
%   a ningun pivote - mismo patron ya usado hoy)

f = fullfile(fileparts(mfilename('fullpath')), 'Winter_Appendix_data.xlsx');
C = readcell(f, 'Sheet', 'A1.Raw_Coordinate');

nums = cellfun(@(x) isnumeric(x) && ~isempty(x) && ~any(ismissing(x)), C(:,1));
idx = find(nums);
M = cell2mat(C(idx, 1:12));  % FRAME,TIME,RIBx,RIBy,HIPx,HIPy,KNEEx,KNEEy,FIBULAx,FIBULAy,ANKLEx,ANKLEy

T = struct();
T.frame = M(:,1);
T.t_s   = M(:,2);
T.cadera_x_cm  = M(:,5);
T.cadera_y_cm  = M(:,6);
T.rodilla_x_cm = M(:,7);
T.rodilla_y_cm = M(:,8);
T.tobillo_x_cm = M(:,11);  % columna "RIGHT ANKLE", no FIBULA (9-10)
T.tobillo_y_cm = M(:,12);

fprintf('Winter A1: %d frames, t=0..%.3fs (dt~%.4fs, ~%.1fHz)\n', ...
    numel(T.frame), T.t_s(end), median(diff(T.t_s)), 1/median(diff(T.t_s)));
fprintf('rango X: cadera %.1f->%.1f, rodilla %.1f->%.1f, tobillo %.1f->%.1f\n', ...
    T.cadera_x_cm(1), T.cadera_x_cm(end), T.rodilla_x_cm(1), T.rodilla_x_cm(end), T.tobillo_x_cm(1), T.tobillo_x_cm(end));

out_csv = fullfile(fileparts(mfilename('fullpath')), 'Winter_Cadera_Rodilla_Tobillo.csv');
Tt = table(T.frame, T.t_s, T.cadera_x_cm, T.cadera_y_cm, T.rodilla_x_cm, T.rodilla_y_cm, T.tobillo_x_cm, T.tobillo_y_cm, ...
    'VariableNames', {'frame','t_s','cadera_x_cm','cadera_y_cm','rodilla_x_cm','rodilla_y_cm','tobillo_x_cm','tobillo_y_cm'});
writetable(Tt, out_csv);
fprintf('CSV escrito: %s\n', out_csv);

end
