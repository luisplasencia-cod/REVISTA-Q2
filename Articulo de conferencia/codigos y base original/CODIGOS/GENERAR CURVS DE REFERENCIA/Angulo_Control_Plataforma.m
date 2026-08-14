    clc
clear
close all

%% ================== SELECCION CARPETA ==================

folder_plat_apoyo = uigetdir(pwd,'Selecciona carpeta: CSV PLATAFORMA APOYO');
if folder_plat_apoyo == 0, error('No se selecciono carpeta'); end

folder_plat_balanceo = uigetdir(pwd,'Selecciona carpeta: CSV PLATAFORMA BALANCEO');
if folder_plat_balanceo == 0, error('No se selecciono carpeta'); end

folder_rel_apoyo = uigetdir(pwd,'Selecciona carpeta: CSV ANGULO RELATIVO APOYO');
if folder_rel_apoyo == 0, error('No se selecciono carpeta'); end

folder_rel_balanceo = uigetdir(pwd,'Selecciona carpeta: CSV ANGULO RELATIVO BALANCEO');
if folder_rel_balanceo == 0, error('No se selecciono carpeta'); end

%% ================== CONFIGURACION ==================

fs = 120; 

sgolay_orden = 3;
sgolay_window = 9; % debe ser impar
    
x_ref = linspace(0,100,101);   % se mantiene para uso interno
x_ref_apoyo    = linspace(0,  60, 101);
x_ref_balanceo = linspace(60, 100, 101);

duraciones_apoyo = [];    matriz_plat_apoyo = [];    matriz_rel_apoyo = [];
duraciones_balanceo = []; matriz_plat_balanceo = []; matriz_rel_balanceo = [];

%% ================== FIGURA PLATAFORMA ==================
titulos = {
    'Señal cruda'
    'Señal filtrada Savitzky-Golay'
    'Normalizado 0-100%'
    'Curva promedio ± SD'
};
figure('Name','Angulo Plataforma','NumberTitle','off')
tiledlayout(2,4)

for k = 1:4
    nexttile(k)
    hold on; grid on
    title(['Apoyo - ' titulos{k}])
end
for k = 5:8
    nexttile(k)
    hold on; grid on
    title(['Balanceo - ' titulos{k-4}])

end

%% ================== FIGURA ANGULO RELATIVO ==================

figure('Name','Angulo Relativo Rodilla-Tobillo vs Plataforma','NumberTitle','off')
tiledlayout(2,4)

for k = 1:4
    nexttile(k)
    hold on; grid on
    title(['Apoyo - ' titulos{k}])
end
for k = 5:8
    nexttile(k)
    hold on; grid on
    title(['Balanceo - ' titulos{k-4}])
end

%% ================== LOOP ARCHIVOS ==================

% ========== LOOP APOYO ==========
files_plat_apoyo = dir(fullfile(folder_plat_apoyo,'*.csv'));
files_rel_apoyo  = dir(fullfile(folder_rel_apoyo, '*.csv'));

for i = 1:length(files_plat_apoyo)
    data_plat = readtable(fullfile(folder_plat_apoyo, files_plat_apoyo(i).name),'VariableNamingRule','preserve');
    t = data_plat{:,1}; t = t - t(1);
    if max(t) > 10, t = t / 1000; end
    xo=data_plat{:,6}; yo=data_plat{:,7};
    xa=data_plat{:,2}; ya=data_plat{:,3};
    xb=data_plat{:,4}; yb=data_plat{:,5};
    theta_plat_raw = atan2(yo-ya,xo-xa);
    theta_plat_raw = unwrap(theta_plat_raw);
    theta_plat_raw = rad2deg(theta_plat_raw);
    plat_f = sgolayfilt(theta_plat_raw, sgolay_orden, sgolay_window);
    t_norm = linspace(0,60,length(t));
    plat_interp = interp1(t_norm, plat_f, x_ref_apoyo,'linear');
    if any(isnan(plat_interp)), continue; end
    duraciones_apoyo  = [duraciones_apoyo;  t(end)];
    matriz_plat_apoyo = [matriz_plat_apoyo; plat_interp];
    figure(1)
    nexttile(1); plot(t,theta_plat_raw)
    nexttile(2); plot(t,plat_f)
    nexttile(3); plot(x_ref_apoyo,plat_interp)
end

for i = 1:length(files_rel_apoyo)
    data_rel = readtable(fullfile(folder_rel_apoyo, files_rel_apoyo(i).name),'VariableNamingRule','preserve');
    theta_rel_raw = data_rel{:,2};
    rel_f = sgolayfilt(theta_rel_raw, sgolay_orden, sgolay_window);
    t_norm_rel = linspace(0,60,length(theta_rel_raw));
    rel_interp = interp1(t_norm_rel, rel_f, x_ref_apoyo,'linear');
    if any(isnan(rel_interp)), continue; end
    matriz_rel_apoyo = [matriz_rel_apoyo; rel_interp];
    t_rel = data_rel{:,1}; t_rel = t_rel - t_rel(1);
    if max(t_rel) > 10, t_rel = t_rel / 1000; end
    figure(2)
    nexttile(1); plot(t_rel,theta_rel_raw)
    nexttile(2); plot(t_rel,rel_f)
    nexttile(3); plot(x_ref_apoyo,rel_interp)
end
% ========== LOOP BALANCEO ==========
files_plat_balanceo = dir(fullfile(folder_plat_balanceo,'*.csv'));
files_rel_balanceo  = dir(fullfile(folder_rel_balanceo, '*.csv'));

for i = 1:length(files_plat_balanceo)
    data_plat = readtable(fullfile(folder_plat_balanceo, files_plat_balanceo(i).name),'VariableNamingRule','preserve');
    t = data_plat{:,1}; t = t - t(1);
    if max(t) > 10, t = t / 1000; end
    xo=data_plat{:,6}; yo=data_plat{:,7};
    xa=data_plat{:,2}; ya=data_plat{:,3};
    xb=data_plat{:,4}; yb=data_plat{:,5};
    theta_plat_raw = atan2(yo-ya,xo-xa);
    theta_plat_raw = unwrap(theta_plat_raw);
    theta_plat_raw = rad2deg(theta_plat_raw);
    plat_f = sgolayfilt(theta_plat_raw, sgolay_orden, sgolay_window);
    t_norm = linspace(60,100,length(t));
    plat_interp = interp1(t_norm, plat_f, x_ref_balanceo,'linear');
    if any(isnan(plat_interp)), continue; end
    duraciones_balanceo  = [duraciones_balanceo;  t(end)];
    matriz_plat_balanceo = [matriz_plat_balanceo; plat_interp];
    figure(1)
    nexttile(5); plot(t,theta_plat_raw)
    nexttile(6); plot(t,plat_f)
    nexttile(7); plot(x_ref_balanceo,plat_interp)
end

for i = 1:length(files_rel_balanceo)
    data_rel = readtable(fullfile(folder_rel_balanceo, files_rel_balanceo(i).name),'VariableNamingRule','preserve');
    theta_rel_raw = data_rel{:,2};
    rel_f = sgolayfilt(theta_rel_raw, sgolay_orden, sgolay_window);
    t_norm_rel = linspace(60,100,length(theta_rel_raw));
    rel_interp = interp1(t_norm_rel, rel_f, x_ref_balanceo,'linear');
    if any(isnan(rel_interp)), continue; end
    matriz_rel_balanceo = [matriz_rel_balanceo; rel_interp];
    t_rel = data_rel{:,1}; t_rel = t_rel - t_rel(1);
    if max(t_rel) > 10, t_rel = t_rel / 1000; end
    figure(2)
    nexttile(5); plot(t_rel,theta_rel_raw)
    nexttile(6); plot(t_rel,rel_f)
    nexttile(7); plot(x_ref_balanceo,rel_interp)
end


duracion_promedio_apoyo    = mean(duraciones_apoyo);
duracion_promedio_balanceo = mean(duraciones_balanceo);
duracion_promedio = duracion_promedio_apoyo + duracion_promedio_balanceo;
%% ================== TIEMPO POR FASE ==================

tiempo_apoyo    = duracion_promedio_apoyo;
tiempo_balanceo = duracion_promedio_balanceo;
disp('======================')
disp('TIEMPOS POR FASE')
disp('======================')

fprintf('Duración total del ciclo: %.3f s\n', duracion_promedio)
fprintf('Fase de apoyo (0–60%%): %.3f s\n', tiempo_apoyo)
fprintf('Fase de balanceo (60–100%%): %.3f s\n', tiempo_balanceo)

disp('======================')
%% ================== PROMEDIO Y SD ==================

% --- Apoyo ---
media_plat_apoyo  = mean(matriz_plat_apoyo,1);
sd_plat_apoyo     = std(matriz_plat_apoyo,0,1);
media_rel_apoyo   = mean(matriz_rel_apoyo,1);
sd_rel_apoyo      = std(matriz_rel_apoyo,0,1);

tiempo_prom_apoyo = 0:1/fs:duracion_promedio_apoyo;
angulo_plat_tiempo_apoyo = interp1(linspace(0,100,length(media_plat_apoyo)), ...
                                    media_plat_apoyo, ...
                                    linspace(0,100,length(tiempo_prom_apoyo)),'linear');

% --- Balanceo ---
media_plat_balanceo = mean(matriz_plat_balanceo,1);
sd_plat_balanceo    = std(matriz_plat_balanceo,0,1);
media_rel_balanceo  = mean(matriz_rel_balanceo,1);
sd_rel_balanceo     = std(matriz_rel_balanceo,0,1);

tiempo_prom_balanceo = 0:1/fs:duracion_promedio_balanceo;
angulo_plat_tiempo_balanceo = interp1(linspace(0,100,length(media_plat_balanceo)), ...
                                       media_plat_balanceo, ...
                                       linspace(0,100,length(tiempo_prom_balanceo)),'linear');

%% ================== GRAFICA PROMEDIO ==================

figure(1)
nexttile(4)
yline(0,'r--','LineWidth',1.5);
fill([x_ref_apoyo fliplr(x_ref_apoyo)],[media_plat_apoyo+sd_plat_apoyo fliplr(media_plat_apoyo-sd_plat_apoyo)],[0.85 0.85 0.85],'EdgeColor','none')
hold on; plot(x_ref_apoyo,media_plat_apoyo,'k','LineWidth',2)
xlabel('% Fase apoyo'); ylabel('Angulo (deg)')
rmse_por_punto_ap  = sqrt(mean((matriz_plat_apoyo - media_plat_apoyo).^2, 1));
rmse_plat_apoyo    = mean(rmse_por_punto_ap);
text(0.02, 0.98, sprintf('RMSE = %.2f', rmse_plat_apoyo), ...
    'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top',...
    'FontSize',11,'FontWeight','bold','Color','b','BackgroundColor','w','Margin',2);

nexttile(8)
yline(0,'r--','LineWidth',1.5);
fill([x_ref_balanceo fliplr(x_ref_balanceo)],[media_plat_balanceo+sd_plat_balanceo fliplr(media_plat_balanceo-sd_plat_balanceo)],[0.85 0.85 0.85],'EdgeColor','none')
hold on; plot(x_ref_balanceo,media_plat_balanceo,'k','LineWidth',2)
xlabel('% Fase balanceo'); ylabel('Angulo (deg)')
rmse_por_punto_bal = sqrt(mean((matriz_plat_balanceo - media_plat_balanceo).^2, 1));
rmse_plat_balanceo = mean(rmse_por_punto_bal);
text(0.02, 0.98, sprintf('RMSE = %.2f', rmse_plat_balanceo), ...
    'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top',...
    'FontSize',11,'FontWeight','bold','Color','r','BackgroundColor','w','Margin',2);
figure(2)
nexttile(4)
fill([x_ref_apoyo fliplr(x_ref_apoyo)],[media_rel_apoyo+sd_rel_apoyo fliplr(media_rel_apoyo-sd_rel_apoyo)],[0.85 0.85 0.85],'EdgeColor','none')
hold on; plot(x_ref_apoyo,media_rel_apoyo,'k','LineWidth',2)
xlabel('% Fase apoyo'); ylabel('Angulo (deg)')

nexttile(8)
fill([x_ref_balanceo fliplr(x_ref_balanceo)],[media_rel_balanceo+sd_rel_balanceo fliplr(media_rel_balanceo-sd_rel_balanceo)],[0.85 0.85 0.85],'EdgeColor','none')
hold on; plot(x_ref_balanceo,media_rel_balanceo,'k','LineWidth',2)
xlabel('% Fase balanceo'); ylabel('Angulo (deg)')

%% ================== EXPORTAR BASE ==================

disp(' ')
disp('Seleccione carpeta donde se guardara la Base de Datos')

save_folder = uigetdir(pwd,'Guardar Base de Datos');

if save_folder == 0
    error('No se selecciono carpeta')
end
x_ref_rel_apoyo    = linspace(0,  60, length(media_rel_apoyo));
x_ref_rel_balanceo = linspace(60, 100, length(media_rel_balanceo));
% --- Angulo relativo ---
save(fullfile(save_folder,'BaseDatos_AnguloRelativo_Apoyo.mat'), ...
     'media_rel_apoyo','sd_rel_apoyo','x_ref_rel_apoyo','tiempo_apoyo','tiempo_balanceo','duracion_promedio')
save(fullfile(save_folder,'BaseDatos_AnguloRelativo_Balanceo.mat'), ...
     'media_rel_balanceo','sd_rel_balanceo','x_ref_rel_balanceo','tiempo_apoyo','tiempo_balanceo','duracion_promedio')

% --- Plataforma ---
save(fullfile(save_folder,'BaseDatos_Plataforma_Apoyo.mat'), ...
     'media_plat_apoyo','sd_plat_apoyo', ...
     'angulo_plat_tiempo_apoyo','tiempo_prom_apoyo', ...
     'tiempo_apoyo','tiempo_balanceo','duracion_promedio')
save(fullfile(save_folder,'BaseDatos_Plataforma_Balanceo.mat'), ...
     'media_plat_balanceo','sd_plat_balanceo', ...
     'angulo_plat_tiempo_balanceo','tiempo_prom_balanceo', ...
     'tiempo_apoyo','tiempo_balanceo','duracion_promedio')

disp('Bases de datos exportadas correctamente')

% --- CSV plataforma apoyo ---
res_tiempo = 0.01; res_angular = 0.009;
tiempo_export = 0:res_tiempo:duracion_promedio_apoyo;
angulo_export = interp1(tiempo_prom_apoyo, angulo_plat_tiempo_apoyo, tiempo_export,'linear');
angulo_export = round(angulo_export/res_angular)*res_angular;
csv_file = fullfile(save_folder,sprintf('CurvaPromedio_Plataforma_Apoyo_%.3fs_%.3fdeg.csv',res_tiempo,res_angular));
fid = fopen(csv_file,'w');
fprintf(fid,'Tiempo_s;Angulo_Plataforma_deg\n');
for k = 1:length(tiempo_export)
    fprintf(fid,'%.3f;%.4f\n',tiempo_export(k),angulo_export(k));
end
fclose(fid);

% --- CSV plataforma balanceo ---
tiempo_export = 0:res_tiempo:duracion_promedio_balanceo;
angulo_export = interp1(tiempo_prom_balanceo, angulo_plat_tiempo_balanceo, tiempo_export,'linear');
angulo_export = round(angulo_export/res_angular)*res_angular;
csv_file = fullfile(save_folder,sprintf('CurvaPromedio_Plataforma_Balanceo_%.3fs_%.3fdeg.csv',res_tiempo,res_angular));
fid = fopen(csv_file,'w');
fprintf(fid,'Tiempo_s;Angulo_Plataforma_deg\n');
for k = 1:length(tiempo_export)
    fprintf(fid,'%.3f;%.4f\n',tiempo_export(k),angulo_export(k));
end
fclose(fid);

fprintf('CSVs exportados\n')

% --- Gráfica curva promedio plataforma apoyo vs tiempo ---
figure('Name','Curva Promedio Plataforma vs Tiempo','NumberTitle','off')
tiledlayout(1,2)

nexttile(1)
h_curve = plot(tiempo_prom_apoyo, angulo_plat_tiempo_apoyo,'b','LineWidth',2); hold on
yline(0,'r--','LineWidth',1.5); grid on
xlabel('Tiempo [s]'); ylabel('Ángulo Plataforma [°]'); title('Apoyo')
[ang_max,idx_max]=max(angulo_plat_tiempo_apoyo); [ang_min,idx_min]=min(angulo_plat_tiempo_apoyo);
plot(tiempo_prom_apoyo(idx_max),ang_max,'ro','MarkerSize',8,'LineWidth',2)
plot(tiempo_prom_apoyo(idx_min),ang_min,'go','MarkerSize',8,'LineWidth',2)
text(tiempo_prom_apoyo(idx_max),ang_max+1,sprintf('%.2f°',ang_max),'Color','r','FontWeight','bold')
text(tiempo_prom_apoyo(idx_min),ang_min-2,sprintf('%.2f°',ang_min),'Color','g','FontWeight','bold')

nexttile(2)
plot(tiempo_prom_balanceo, angulo_plat_tiempo_balanceo,'b','LineWidth',2); hold on
yline(0,'r--','LineWidth',1.5); grid on
xlabel('Tiempo [s]'); ylabel('Ángulo Plataforma [°]'); title('Balanceo')
[ang_max,idx_max]=max(angulo_plat_tiempo_balanceo); [ang_min,idx_min]=min(angulo_plat_tiempo_balanceo);
plot(tiempo_prom_balanceo(idx_max),ang_max,'ro','MarkerSize',8,'LineWidth',2)
plot(tiempo_prom_balanceo(idx_min),ang_min,'go','MarkerSize',8,'LineWidth',2)
text(tiempo_prom_balanceo(idx_max),ang_max+1,sprintf('%.2f°',ang_max),'Color','r','FontWeight','bold')
text(tiempo_prom_balanceo(idx_min),ang_min-2,sprintf('%.2f°',ang_min),'Color','g','FontWeight','bold')

% --- Imprimir valores ---
disp('======================')
disp('CURVA PROMEDIO PLATAFORMA - APOYO')
disp('======================')
fprintf('Duración promedio apoyo: %.3f s\n', duracion_promedio_apoyo)
fprintf('Ángulo mínimo: %.2f °\n', min(angulo_plat_tiempo_apoyo))
fprintf('Ángulo máximo: %.2f °\n', max(angulo_plat_tiempo_apoyo))
fprintf('Rango: %.2f °\n', max(angulo_plat_tiempo_apoyo)-min(angulo_plat_tiempo_apoyo))
disp('======================')
disp('CURVA PROMEDIO PLATAFORMA - BALANCEO')
disp('======================')
fprintf('Duración promedio balanceo: %.3f s\n', duracion_promedio_balanceo)
fprintf('Ángulo mínimo: %.2f °\n', min(angulo_plat_tiempo_balanceo))
fprintf('Ángulo máximo: %.2f °\n', max(angulo_plat_tiempo_balanceo))
fprintf('Rango: %.2f °\n', max(angulo_plat_tiempo_balanceo)-min(angulo_plat_tiempo_balanceo))
disp('======================')