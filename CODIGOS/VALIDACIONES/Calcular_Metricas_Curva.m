function metrica = calcular_metricas_curva(sim_fase, exp_fase, sd_fase, trials_fase, nombre_fase)
% Mismas formulas que calcular_estadistica()/calcular_icc31() embebidas en
% Validacion_Plataforma.m y Validacion_Fuerza.m (no se tocan esos archivos).
% Interfaz simplificada a proposito: aqui SIEMPRE se reciben vectores ya
% recortados a la fase de interes (sin el parametro idx que en los
% scripts originales se usaba con dos convenciones distintas entre
% Validacion_Plataforma.m y Validacion_Fuerza.m). trials_fase puede venir
% vacio ([]) si todavia no hay repeticiones para calcular ICC.
%
% Ver CODIGOS/VALIDACIONES/GUIA_INTERPRETACION.md para el significado de
% cada campo y los umbrales de clasificacion.

sim_fase = sim_fase(:);
exp_fase = exp_fase(:);
sd_fase  = sd_fase(:);

error_total = sim_fase - exp_fase;
error_norm  = error_total ./ sd_fase;

RMSEnorm = sqrt(mean(error_norm.^2));

ROM_sim   = max(sim_fase) - min(sim_fase);
ROM_exp   = max(exp_fase) - min(exp_fase);
delta_ROM = ROM_sim - ROM_exp;

CMC = sqrt(1 - sum((sim_fase - exp_fase).^2) / sum((exp_fase - mean(exp_fase)).^2));

xm = mean(sim_fase); ym = mean(exp_fase);
r  = sum((sim_fase - xm) .* (exp_fase - ym)) / ...
     sqrt(sum((sim_fase - xm).^2) * sum((exp_fase - ym).^2));

pct_1sd = sum(abs(error_total) <= sd_fase) / numel(sim_fase) * 100;

if ~isempty(trials_fase)
    ICC = calcular_icc31(trials_fase);
else
    ICC = NaN;
end

nivel_rmse   = clasificar_rmse(RMSEnorm);
nivel_r      = clasificar_r(abs(r));
nivel_sd     = clasificar_sd(pct_1sd);
nivel_global = max([nivel_rmse nivel_r nivel_sd]);

metrica = struct( ...
    'fase',                nombre_fase, ...
    'RMSEnorm',             RMSEnorm, ...
    'r',                    r, ...
    'pct_1sd',              pct_1sd, ...
    'ROM_sim',              ROM_sim, ...
    'ROM_exp',              ROM_exp, ...
    'delta_ROM',            delta_ROM, ...
    'CMC',                  CMC, ...
    'ICC',                  ICC, ...
    'nivel_rmse',           nivel_rmse, ...
    'nivel_r',              nivel_r, ...
    'nivel_sd',             nivel_sd, ...
    'nivel_global',         nivel_global, ...
    'clasificacion_global', texto_nivel(nivel_global), ...
    'nivel_rom',            clasificar_rom(delta_ROM), ...
    'nivel_cmc',            clasificar_cmc(CMC), ...
    'nivel_icc',            clasificar_icc(ICC));

end

% ===================================================
% FUNCIONES LOCALES (copia exacta de la logica en VALIDACIONES/*.m)
% ===================================================

function nivel = clasificar_rmse(v)
    if v < 1, nivel=1; elseif v<1.5, nivel=2; elseif v<2, nivel=3; else, nivel=4; end
end
function nivel = clasificar_r(v)
    if v>0.9, nivel=1; elseif v>0.8, nivel=2; elseif v>0.7, nivel=3; else, nivel=4; end
end
function nivel = clasificar_sd(v)
    if v>85, nivel=1; elseif v>75, nivel=2; elseif v>65, nivel=3; else, nivel=4; end
end
function nivel = clasificar_rom(v)
    if v>=-1 && v<=1, nivel=1; elseif abs(v)<=2, nivel=2;
    elseif abs(v)<=3, nivel=3; else, nivel=4; end
end
function nivel = clasificar_cmc(v)
    if v>0.95, nivel=1; elseif v>0.85, nivel=2; elseif v>0.75, nivel=3; else, nivel=4; end
end
function nivel = clasificar_icc(v)
    if isnan(v), nivel=NaN;
    elseif v>0.90, nivel=1; elseif v>0.75, nivel=2; elseif v>0.50, nivel=3; else, nivel=4; end
end
function txt = texto_nivel(n)
    switch n
        case 1, txt='Excelente';
        case 2, txt='Buena';
        case 3, txt='Aceptable';
        case 4, txt='Deficiente';
        otherwise, txt='N/A';
    end
end

function icc_val = calcular_icc31(trials)
    % ICC(3,1) - Modelo mixto dos vias, acuerdo absoluto (Koo & Li, 2016)
    [n, k]     = size(trials);
    grand_mean = mean(trials(:));
    row_means  = mean(trials, 2);
    col_means  = mean(trials, 1);
    SS_rows  = k * sum((row_means - grand_mean).^2);
    SS_cols  = n * sum((col_means  - grand_mean).^2);
    SS_total = sum((trials(:)     - grand_mean).^2);
    SS_error = SS_total - SS_rows - SS_cols;
    MS_rows  = SS_rows  / (n - 1);
    MS_error = SS_error / ((n-1)*(k-1));
    icc_val  = (MS_rows - MS_error) / (MS_rows + (k-1)*MS_error);
end
