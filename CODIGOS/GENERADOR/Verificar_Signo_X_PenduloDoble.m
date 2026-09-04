function Verificar_Signo_X_PenduloDoble()
% VERIFICAR_SIGNO_X_PENDULODOBLE  Verificacion empirica (02-sep-2026,
%   mismo metodo que el G7 original de Cadena_Cinematica_Core.m):
%   compara la correlacion angulo-vs-X y angulo-vs-Y del pipeline NUEVO
%   (Generar_Trayectoria.m, Koopman+pendulo doble+correccion hibrida)
%   contra REFERENCIAS/Control_apoyo_Luis_V4.csv real, para decidir si
%   hace falta invertir X (o Y) antes de escribir el CSV.
%
%   NO SE ASUME que la inversion de G7 (verificada sobre una formula de
%   rotacion PURA alrededor de un tobillo fijo, sin avance de cadera
%   mezclado) se traspasa igual a este pipeline nuevo (que suma el avance
%   de cadera, siempre creciente, DENTRO de la misma coordenada X) - se
%   verifica de nuevo, contra el mismo dato real, con el mismo metodo.
% ==========================================================================
carpeta = fileparts(mfilename('fullpath'));
addpath(carpeta);

ruta_csv_real = 'C:\articuloq2\REFERENCIAS\Control_apoyo_Luis_V4.csv';
M = readmatrix(ruta_csv_real, 'Delimiter', ';', 'NumHeaderLines', 1);
M = M(~any(isnan(M(:,1:4)), 2), :);
x_real = M(:,2); y_real = M(:,3); ang_real = M(:,4);
dang_real = ang_real - ang_real(1);
dx_real = x_real - x_real(1);
dy_real = y_real - y_real(1);

r = Generar_Trayectoria(struct('talla_m',1.73,'masa_kg',70,'sexo','M'));

dang_gen = r.apoyo.angulo_deg(:) - r.apoyo.angulo_deg(1);
dx_gen = r.apoyo.x_cm(:);  % ya normalizado a 0 en la 1ra muestra
dy_gen = r.apoyo.y_cm(:);

corr_x_real = corr_manual(dang_real, dx_real);
corr_x_gen  = corr_manual(dang_gen, dx_gen);
corr_y_real = corr_manual(dang_real, dy_real);
corr_y_gen  = corr_manual(dang_gen, dy_gen);

fprintf('=== Verificar_Signo_X_PenduloDoble ===\n');
fprintf('N filas reales usadas: %d\n', numel(x_real));
fprintf('corr(ang,X): real=%.4f  generado(nuevo pipeline, sin invertir)=%.4f  %s\n', ...
    corr_x_real, corr_x_gen, cmp_signo(corr_x_real, corr_x_gen));
fprintf('corr(ang,Y): real=%.4f  generado(nuevo pipeline, sin invertir)=%.4f  %s\n', ...
    corr_y_real, corr_y_gen, cmp_signo(corr_y_real, corr_y_gen));

fprintf('\nRango real:      X=[%.2f, %.2f] cm (avance neto=%.2f)\n', min(dx_real), max(dx_real), dx_real(end));
fprintf('Rango generado:  X=[%.2f, %.2f] cm (avance neto=%.2f)\n', min(dx_gen), max(dx_gen), dx_gen(end));

end

function s = cmp_signo(a, b)
if sign(a) == sign(b)
    s = '-> MISMO SIGNO (no invertir)';
else
    s = '-> SIGNO OPUESTO (invertir)';
end
end

function c = corr_manual(a, b)
a = a(:); b = b(:);
c = sum((a-mean(a)).*(b-mean(b))) / sqrt(sum((a-mean(a)).^2)*sum((b-mean(b)).^2));
end
