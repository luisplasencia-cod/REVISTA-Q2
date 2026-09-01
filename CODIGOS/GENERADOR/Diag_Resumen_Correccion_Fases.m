function Diag_Resumen_Correccion_Fases()
% DIAG_RESUMEN_CORRECCION_FASES  30-ago-2026: figura-resumen de una sola
%                   vista, pedida para el informe - cuanto pesa la
%                   calibracion afin LOSO de Koopman (sec. 5 del informe)
%                   en las 5 piezas ya diagnosticadas por separado
%                   (Diag_Correccion_LOSO_Angulo.m,
%                   Diag_Correccion_LOSO_Posicion.m), comparadas de un
%                   solo vistazo en apoyo/balanceo/completo.
%
%   NO recalcula nada por su cuenta - llama a los 2 diagnosticos ya
%   validados con hacer_figura=false (no regenera sus 3 figuras
%   individuales, que siguen siendo la evidencia curva-por-curva) y solo
%   arma una comparacion normalizada de sus resultados.
%
%   Metrica usada: % de reduccion de RMSE = 100*(1 - RMSE_despues/RMSE_
%   antes). Se usa esto y NO el RMSE crudo porque las 5 piezas estan en
%   unidades distintas (grados para el angulo, cm para las posiciones) -
%   el % de reduccion es comparable entre unidades. r NO se incluye aqui:
%   para el angulo r es matematicamente invariante a una calibracion
%   afin (no puede cambiar), asi que compararlo junto a las posiciones
%   (donde r SI cambia, por la mezcla con el vaiven de cadera no
%   calibrado) daria una impresion equivocada - ver Diag_Correccion_LOSO_
%   Angulo_figura.png y el texto del informe para el detalle de r.

carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta); addpath(fullfile(carpeta,'RODILLA','Kuopio')); addpath(fullfile(carpeta,'TOBILLO'));

Rang = Diag_Correccion_LOSO_Angulo(false);
Rpos = Diag_Correccion_LOSO_Posicion(false);
Rang.etiqueta = 'Angulo muslo';

etiquetas = {'Angulo muslo', Rpos(1).etiqueta, Rpos(2).etiqueta, Rpos(3).etiqueta, Rpos(4).etiqueta};
todos = [Rang, Rpos];
n_piezas = numel(todos);

reduccion = nan(3, n_piezas);  % filas=fase, columnas=pieza
for p = 1:n_piezas
    reduccion(:,p) = 100*(1 - todos(p).rmse_despues ./ todos(p).rmse_antes);
end

nombres_fase = Rang.nombres_fase;
col = [0.85 0.33 0.10; 0.20 0.45 0.70; 0.20 0.55 0.30];  % apoyo, balanceo, completo

fig = figure('Name','Resumen: cuanto reduce RMSE la calibracion LOSO, por fase','Position',[40 60 1250 650],'Color','w');
hold on; grid on; box on;
b = bar(reduccion', 'grouped');
for f=1:3, b(f).FaceColor = col(f,:); end
set(gca,'XTick',1:n_piezas,'XTickLabel',etiquetas);
ylabel('Reduccion de RMSE por la calibracion LOSO [%]');
legend(b, nombres_fase, 'Location','best');
yline(0,'k--','HandleVisibility','off');
title('Cuanto pesa la calibracion LOSO de Koopman, por fase y por pieza (N=47, Kuopio 2024)');

for p = 1:n_piezas
    for f = 1:3
        xpos = p + (f-2)*0.225;
        text(xpos, reduccion(f,p), sprintf('%.0f%%', reduccion(f,p)), ...
            'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'FontSize',8);
    end
end

out_png = fullfile(carpeta, 'Diag_Resumen_Correccion_Fases_figura.png');
exportgraphics(fig, out_png, 'Resolution', 150);
fprintf('Figura guardada en: %s\n', out_png);

end
