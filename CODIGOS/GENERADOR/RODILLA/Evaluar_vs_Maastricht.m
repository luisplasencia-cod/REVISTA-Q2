function Evaluar_vs_Maastricht(antro_in)
% EVALUAR_VS_MAASTRICHT  24-ago-2026: comparacion DECISIVA para elegir el
%                   mejor modelo de RODILLA - flexion de rodilla (angulo
%                   articular relativo, NATIVO de cada modelo, sin
%                   derivar nada) contra el promedio REAL de un subgrupo
%                   de 246 sujetos (Maastricht, OSF t72cw, hombres 18-29
%                   anios, velocidad comoda) - dataset con antropometria
%                   documentada (sexo/talla/peso/long.pierna) por sujeto.
%
% Fuente: docs OSF https://osf.io/t72cw/ (CC BY, Normative 3D gait data of
% healthy subjects walking at three different speeds on an instrumented
% treadmill in virtual reality). Hoja 'Rotation_RKneeFlex_comf' del
% archivo 05_AgeGenderGroup_comf.xlsx: media+DE de flexion de rodilla
% derecha, %ciclo 1-100, por grupo de edad/sexo.
%
% BUG REAL CORREGIDO 26-ago-2026 (encontrado al investigar por que Zhao/
% Yun daban r negativo, a pedido del usuario): Zhao2026_Core.m modela
% izquierda (Ec.1) y derecha (Ec.2, +j*pi de desfase por armonico) como
% formulas DISTINTAS - el paper confirma a texto completo (PLOS ONE,
% 10.1371/journal.pone.0338041) que el ciclo arranca en contacto de talon
% (misma convencion que el proyecto, 0=heel strike), asi que NO es un
% problema de direccion del tiempo. El problema real: esta funcion llamaba
% a Zhao2026_Core SIN especificar 'lado' -> usaba el default 'izquierda',
% comparado contra un dataset que es EXPLICITAMENTE 'RKneeFlex' (rodilla
% DERECHA). Corregido a lado='derecha', consistente con el default de
% Cargar_Ferber2024_Core.m ('R') y con que Yun2014_Wrapper.m solo expone
% canales R_ en todo el proyecto. Efecto: Zhao pasa de r=-0.296 a
% r=+0.982 - deja de estar descartado por esta prueba (ver CIERRE_RODILLA.md
% para el efecto en la decision de modelo ganador). Yun no tiene este bug
% (su wrapper ya expone solo R_, ver Obtener_Angulos_Candidato.m) - su r
% negativo es un defecto de forma real, no de lado.

addpath(fullfile(fileparts(mfilename('fullpath')), '..'));
if nargin < 1 || isempty(antro_in)
    antro_in = struct('talla_m', 1.71, 'masa_kg', 68, 'sexo', 'M');
end
antro = Estimar_Antropometria_Core(antro_in);
tempo0 = Temporizacion_Core(antro, 'Koopman');

% --- Referencia real: hombres 18-29 anios, Maastricht ---
f = fullfile(fileparts(mfilename('fullpath')), 'Maastricht', '05_AgeGenderGroup_comf.xlsx');
C = readcell(f, 'Sheet','Rotation_RKneeFlex_comf');
nums = cellfun(@(x) isnumeric(x) && ~isempty(x) && ~any(ismissing(x)), C(:,2));
idx = find(nums);
pct_M = cell2mat(C(idx,2)).';
mean_M = cell2mat(C(idx,3)).';   % MEN mean
sd_M   = cell2mat(C(idx,4)).';   % MEN SD

% --- Candidatos: flexion de rodilla NATIVA (relativa, no absoluta) ---
K = Koopman2014_Core(tempo0.velocidad_ms*3.6, antro.talla_m);
fk_K = K.rodilla_flexext.angulo_deg; pct_K = linspace(0,100,numel(fk_K));

Z = Zhao2026_Core(antro.long_muslo_m+antro.long_tibia_m, 1/tempo0.tiempo_ciclo_s, struct('lado','derecha'));
fk_Z = rad2deg(Z.phi_rodilla_rad); pct_Z = linspace(0,100,numel(fk_Z));

% NOTA 26-ago-2026: MISMO bug que Zhao (ver arriba), encontrado en la
% misma investigacion. Yun2014_Wrapper.m calcula AMBOS lados (R_ y L_),
% pero esta comparacion tomaba R_knee_flexion sin mas - contra Maastricht
% (RKneeFlex, rodilla derecha) eso da r=-0.332. Con L_knee_flexion sube a
% r=+0.955. Como con Zhao, esto NO se probo/aplico en Control_Luis ni
% Winter (lado no documentado en esos datasets, y ahi L SI empeora el
% ajuste para Yun - ver CIERRE_RODILLA.md #1-bis) - el cambio se limita a
% esta comparacion, donde el lado del dataset real esta confirmado.
Y = Yun2014_Wrapper(vector14_desde_antropometria(antro));
fk_Y = Y.L_knee_flexion.mean; pct_Y = linspace(0,100,numel(fk_Y));

nombres = {'Koopman','Zhao','Yun'};
pcts = {pct_K, pct_Z, pct_Y};
fks  = {fk_K, fk_Z, fk_Y};
col = {[0.85 0.33 0.10],[0.47 0.67 0.19],[0.30 0.55 0.75]};

fprintf('=== Flexion de rodilla vs Maastricht real (hombres 18-29, n subset de 246) ===\n');
fprintf('%-12s %8s %8s\n','Modelo','r','RMSE(deg)');
r_all = zeros(1,3); rmse_all = zeros(1,3);
for i=1:3
    fi = interp1(pcts{i}, fks{i}, pct_M, 'pchip');
    r_all(i) = corr(mean_M(:), fi(:));
    rmse_all(i) = sqrt(mean((mean_M(:)-fi(:)).^2));
    fprintf('%-12s %8.3f %8.2f\n', nombres{i}, r_all(i), rmse_all(i));
end

fig = figure('Name','Rodilla (flexion) vs Maastricht real','Position',[80 80 950 550],'Color','w');
hold on; grid on; box on;
fill([pct_M, fliplr(pct_M)], [mean_M+sd_M, fliplr(mean_M-sd_M)], [0.85 0.85 0.85], 'EdgeColor','none', 'FaceAlpha',0.6, 'DisplayName','\pm1 SD real');
plot(pct_M, mean_M, 'k-', 'LineWidth',3, 'DisplayName', sprintf('REAL Maastricht (hombres 18-29, %s)', 'n=subset'));
for i=1:3
    plot(pcts{i}, fks{i}, '-', 'Color',col{i}, 'LineWidth',2, 'DisplayName', sprintf('%s (r=%.2f, RMSE=%.1f)', nombres{i}, r_all(i), rmse_all(i)));
end
xlabel('% ciclo de marcha'); ylabel('Flexion de rodilla [deg]');
title('Flexion de rodilla: real (Maastricht, n=246 subset) vs modelos');
legend('Location','best');

out_png = fullfile(fileparts(mfilename('fullpath')), 'Evaluar_vs_Maastricht_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('\nFigura guardada en: %s\n', out_png);

end

function p14 = vector14_desde_antropometria(antro)
if ~isfield(antro,'edad_anios') || isempty(antro.edad_anios), antro.edad_anios = 25; end
if ~isfield(antro,'sexo'), antro.sexo = 'M'; end
sexo01 = double(upper(antro.sexo(1)) == 'M');
p14 = [antro.edad_anios, antro.talla_m*100, antro.masa_kg, sexo01, ...
       antro.long_muslo_m*100, antro.long_tibia_m*100, ...
       32.8, 29.7, 25.5, 10, antro.long_pie_m*100, 7.30, 7.10, 9.80];
end
