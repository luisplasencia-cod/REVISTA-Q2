function Diag_Ferber_Fase()
% DIAG_FERBER_FASE - diagnostico 02-sep-2026 (sesion externa de
% investigacion): confirma que Ferber 2024 es TREADMILL (README linea
% 18/48-49: "walking on a treadmill") a diferencia de Kuopio (overground,
% confirmado en su propio docstring) -- compara rangos reales de X
% global/relhip, y aisla la contribucion de la rampa de avance de cadera
% (Trayectoria_Cadera_Core) del pipeline de prediccion.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
addpath(fullfile(fileparts(mfilename('fullpath')), 'Ferber'));
carpeta = fileparts(mfilename('fullpath'));
carpeta_ferber = fullfile(carpeta, 'Ferber');
Tmeta = readtable(fullfile(carpeta_ferber, 'muestra_40.csv'));
n = 101; pct = linspace(0,100,n);
warning('off','all');

fprintf('%-8s %8s %10s %10s %10s %10s %10s\n', 'sub_id','talla', 'rangeXg', 'rangeXr', 'zancada_pred','speed_ms','T_ciclo_s');
for i = 1:min(8,height(Tmeta))
    sid = Tmeta.sub_id(i);
    talla_cm = Tmeta.Height(i);
    json_path = fullfile(carpeta_ferber, 'muestra40_raw', sprintf('%d_%s', sid, Tmeta.filename{i}));
    if ~isfile(json_path), continue; end
    S = Cargar_Ferber2024_Core(json_path);

    antro = Estimar_Antropometria_Core(struct('talla_m', talla_cm/100));
    tempo = Temporizacion_Core(antro, 'Koopman');
    zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;

    rangeXg = max(S.x_horiz_cm) - min(S.x_horiz_cm);
    rangeXr = max(S.x_horiz_relhip_cm) - min(S.x_horiz_relhip_cm);

    fprintf('%-8d %8.1f %10.2f %10.2f %10.2f %10.3f %10.3f  (REAL speed=%.3f T=%.3f)\n', ...
        sid, talla_cm, rangeXg, rangeXr, zancada_cm, tempo.velocidad_ms, tempo.tiempo_ciclo_s, S.speed_ms, S.T_ciclo_s);
end
warning('on','all');
end
