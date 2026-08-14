    %% 
    clc;
    clear;
    close all;
    close all force;
    
    %% ================== PARAMETRO EDITABLE ==================
    X_NORM_CM = 45; % <-- MODIFICAR AQUI cuando sea necesario
    
    %% ================== FUNCIONES ==================
    normalizeTime = @(t) 100*((t - t(1)) - min(t - t(1)))/(max(t - t(1)) - min(t - t(1)));
    normalizeDisp = @(d) d - d(1);
    
    %% ================== SELECCION DE CARPETAS ==================
    folder_X_ap  = uigetdir(pwd,'Selecciona carpeta: X APOYO');
    folder_X_bal = uigetdir(pwd,'Selecciona carpeta: X BALANCEO');
    folder_Y_ap  = uigetdir(pwd,'Selecciona carpeta: Y APOYO');
    folder_Y_bal = uigetdir(pwd,'Selecciona carpeta: Y BALANCEO');
    
    files_X_ap  = dir(fullfile(folder_X_ap, '*.csv'));
    files_X_bal = dir(fullfile(folder_X_bal,'*.csv'));
    files_Y_ap  = dir(fullfile(folder_Y_ap, '*.csv'));
    files_Y_bal = dir(fullfile(folder_Y_bal,'*.csv'));
    
    files1 = [files_X_ap;  files_X_bal];   % para compatibilidad con colors/info1
    files2 = [files_Y_ap;  files_Y_bal];   % para compatibilidad con colors/info2
    
    %% ===== CALCULO DE TIEMPOS PROMEDIO =====
    tiempos_X = [];
    N = 100;
    
    X_apoyo_all = [];
    X_bal_all   = [];
    Y_apoyo_all = [];
    Y_bal_all   = [];
    
    for k = 1:length(files_X_ap)
        data = readmatrix(fullfile(folder_X_ap, files_X_ap(k).name));
        t = data(:,1);
        if max(t) > 100, t = t/1000; end
        tiempos_X(end+1) = t(end) - t(1);
    end
    for k = 1:length(files_X_bal)
        data = readmatrix(fullfile(folder_X_bal, files_X_bal(k).name));
        t = data(:,1);
        if max(t) > 100, t = t/1000; end
        tiempos_X(end+1) = t(end) - t(1);
    end
    
    tiempos_Y = [];
    for k = 1:length(files_Y_ap)
        data = readmatrix(fullfile(folder_Y_ap, files_Y_ap(k).name));
        t = data(:,1);
        if max(t) > 100, t = t/1000; end
        tiempos_Y(end+1) = t(end) - t(1);
    end
    for k = 1:length(files_Y_bal)
        data = readmatrix(fullfile(folder_Y_bal, files_Y_bal(k).name));
        t = data(:,1);
        if max(t) > 100, t = t/1000; end
        tiempos_Y(end+1) = t(end) - t(1);
    end
    
    % Tiempos reales por fase (cada carpeta es su propia fase)
    T_apoyo_X = mean(tiempos_X(1:length(files_X_ap)));
    T_bal_X   = mean(tiempos_X(length(files_X_ap)+1:end));
    Tprom_X   = T_apoyo_X + T_bal_X;
    
    T_apoyo_Y = mean(tiempos_Y(1:length(files_Y_ap)));
    T_bal_Y   = mean(tiempos_Y(length(files_Y_ap)+1:end));
    Tprom_Y   = T_apoyo_Y + T_bal_Y;
    
    fprintf('Tiempo promedio X → Apoyo: %.3f s | Balanceo: %.3f s | Total: %.3f s\n', T_apoyo_X, T_bal_X, Tprom_X);
    fprintf('Tiempo promedio Y → Apoyo: %.3f s | Balanceo: %.3f s | Total: %.3f s\n', T_apoyo_Y, T_bal_Y, Tprom_Y);
    
    %% ================== CARPETA 1 (X) ==================
    fig1 = uifigure('Name','Desplazamiento X','Position',[100 100 1000 600]);
    layout1 = uigridlayout(fig1,[2 1]);
    layout1.RowHeight = {'4x','1x'};
    layout1.ColumnWidth = {'1x'};
    
    %% ===== DASHBOARD 2x2 =====
    figDashboard = uifigure('Name','Analisis Global X-Y','Position',[50 50 1200 800]);
    layoutD = uigridlayout(figDashboard,[2 4]);
    layoutD.RowHeight   = {'1x','1x'};
    layoutD.ColumnWidth = {'1x','1x','1x','1x'};
    
    axReal_X_ap  = axes(layoutD); title(axReal_X_ap, 'X Apoyo — tiempo real');
    hold(axReal_X_ap,'on');  grid(axReal_X_ap,'on');
    xlabel(axReal_X_ap,'Tiempo (s)'); ylabel(axReal_X_ap,'cm');
    
    axReal_X_bal = axes(layoutD); title(axReal_X_bal,'X Balanceo — tiempo real');
    hold(axReal_X_bal,'on'); grid(axReal_X_bal,'on');
    xlabel(axReal_X_bal,'Tiempo (s)'); ylabel(axReal_X_bal,'cm');
    
    axReal_Y_ap  = axes(layoutD); title(axReal_Y_ap, 'Y Apoyo — tiempo real');
    hold(axReal_Y_ap,'on');  grid(axReal_Y_ap,'on');
    xlabel(axReal_Y_ap,'Tiempo (s)'); ylabel(axReal_Y_ap,'cm');
    
    axReal_Y_bal = axes(layoutD); title(axReal_Y_bal,'Y Balanceo — tiempo real');
    hold(axReal_Y_bal,'on'); grid(axReal_Y_bal,'on');
    xlabel(axReal_Y_bal,'Tiempo (s)'); ylabel(axReal_Y_bal,'cm');
    
    axNorm_X_ap  = axes(layoutD); title(axNorm_X_ap, 'X Apoyo — tiempo promedio');
    hold(axNorm_X_ap,'on');  grid(axNorm_X_ap,'on');
    xlabel(axNorm_X_ap,'Tiempo (s)'); ylabel(axNorm_X_ap,'cm');
    
    axNorm_X_bal = axes(layoutD); title(axNorm_X_bal,'X Balanceo — tiempo promedio');
    hold(axNorm_X_bal,'on'); grid(axNorm_X_bal,'on');
    xlabel(axNorm_X_bal,'Tiempo (s)'); ylabel(axNorm_X_bal,'cm');
    
    axNorm_Y_ap  = axes(layoutD); title(axNorm_Y_ap, 'Y Apoyo — tiempo promedio');
    hold(axNorm_Y_ap,'on');  grid(axNorm_Y_ap,'on');
    xlabel(axNorm_Y_ap,'Tiempo (s)'); ylabel(axNorm_Y_ap,'cm');
    
    axNorm_Y_bal = axes(layoutD); title(axNorm_Y_bal,'Y Balanceo — tiempo promedio');
    hold(axNorm_Y_bal,'on'); grid(axNorm_Y_bal,'on');
    xlabel(axNorm_Y_bal,'Tiempo (s)'); ylabel(axNorm_Y_bal,'cm');
    
    axReal_X = axReal_X_ap;
    axReal_Y = axReal_Y_ap;
    axNorm_X = axNorm_X_ap;
    axNorm_Y = axNorm_Y_ap;
    %% ===== SEÑALES EN TIEMPO REAL =====
    ax1 = axes(layout1);
    hold(ax1,'on');
    colors = lines(length(files1));
    info1 = cell(length(files1),3);
    
    %% ===== VENTANA COMBINADA 2x4 =====
    % Fila 1 (normalizacion): X Apoyo real | X Balanceo real | Y Apoyo | Y Balanceo
    % Fila 2 (control):       X Apoyo ctrl | X Balanceo ctrl | Y Apoyo ctrl | Y Balanceo ctrl
    figCombinada = uifigure('Name','Normalizacion por Fase y Curvas de Control','Position',[100 50 1600 900]);
    layoutComb = uigridlayout(figCombinada,[2 4]);
    layoutComb.RowHeight   = {'1x','1x'};
    layoutComb.ColumnWidth = {'1x','1x','1x','1x'};
    
    % --- Fila 1: igual que figFases ---
    ax_X_apoyo = axes(layoutComb);
    title(ax_X_apoyo, sprintf('X - Apoyo (promedio real cm)'));
    hold(ax_X_apoyo,'on'); grid(ax_X_apoyo,'on');
    
    ax_X_bal = axes(layoutComb);
    title(ax_X_bal, sprintf('X - Balanceo (promedio real cm)'));
    hold(ax_X_bal,'on'); grid(ax_X_bal,'on');
    
    ax_Y_apoyo = axes(layoutComb);
    title(ax_Y_apoyo,'Y - Apoyo (-5 a 5 cm)');
    hold(ax_Y_apoyo,'on'); grid(ax_Y_apoyo,'on');
    
    ax_Y_bal = axes(layoutComb)
    title(ax_Y_bal,'Y - Balanceo (-8 a 8 cm)');
    hold(ax_Y_bal,'on'); grid(ax_Y_bal,'on');
    
    % --- Fila 2: igual que figControl ---
    axC_X_ap = axes(layoutComb);
    title(axC_X_ap, sprintf('X Apoyo (0 a %g cm)',X_NORM_CM));
    hold(axC_X_ap,'on'); grid(axC_X_ap,'on');
    
    axC_X_bal = axes(layoutComb);
    title(axC_X_bal, sprintf('X Balanceo (0 a %g cm)',X_NORM_CM));
    hold(axC_X_bal,'on'); grid(axC_X_bal,'on');
    
    axC_Y_ap = axes(layoutComb);
    title(axC_Y_ap,'Y Apoyo (Control)');
    hold(axC_Y_ap,'on'); grid(axC_Y_ap,'on');
    
    axC_Y_bal = axes(layoutComb);
    title(axC_Y_bal,'Y Balanceo (Control)');
    hold(axC_Y_bal,'on'); grid(axC_Y_bal,'on');
    
    %% ===== LOOP CARPETA X =====
    all_X_folders = {folder_X_ap, folder_X_bal};
    all_X_files   = {files_X_ap,  files_X_bal};
    colors = lines(length(files1));
    info1  = cell(length(files1), 3);
    kk = 0;
    
    for fi = 1:2
        for k = 1:length(all_X_files{fi})
            kk = kk + 1;
            data   = readmatrix(fullfile(all_X_folders{fi}, all_X_files{fi}(k).name));
            tiempo = data(:,1);
            dispX  = data(:,2);
    
            if max(tiempo) > 100, tiempo = tiempo/1000; end
    
            dispXNorm = normalizeDisp(dispX);
    
            % Tiempo real para dashboard
            if fi == 1
                plot(axReal_X_ap,  tiempo,  dispXNorm, 'LineWidth',1);
                plot(axNorm_X_ap,  linspace(0, T_apoyo_X, length(dispXNorm)), dispXNorm, 'Color',colors(kk,:),'LineWidth',1.5);
            else
                plot(axReal_X_bal, tiempo,  dispXNorm, 'LineWidth',1);
                plot(axNorm_X_bal, linspace(0, T_bal_X,   length(dispXNorm)), dispXNorm, 'Color',colors(kk,:),'LineWidth',1.5);
            end
    
            t_common = linspace(0,1,N);
    
            if fi == 1  % APOYO: normaliza 0-60%
                tiempoNorm = linspace(0, 60, length(dispXNorm));
                plot(ax1, tiempoNorm, dispXNorm, 'DisplayName', all_X_files{fi}(k).name, ...
                    'Color',colors(kk,:),'LineWidth',1.5);
    
                t_ap_norm   = linspace(0,1,length(dispXNorm));
                x_ap_interp = interp1(t_ap_norm, dispXNorm, t_common,'pchip');
                X_apoyo_all = [X_apoyo_all; x_ap_interp];
    
                t_ap = linspace(0, T_apoyo_X, length(dispXNorm));
                plot(ax_X_apoyo, t_ap, dispXNorm, 'Color',[colors(kk,:) 0.4],'LineWidth',0.8);
    
                minAp  = 0;
                maxAp  = dispXNorm(end);
                plot(ax1,0,  minAp,'o','Color',colors(kk,:),'MarkerFaceColor','w','MarkerSize',6);
                text(ax1,1,  minAp, sprintf('%.2f',minAp),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
                plot(ax1,60, maxAp,'o','Color',colors(kk,:),'MarkerFaceColor',colors(kk,:),'MarkerSize',6);
                text(ax1,61, maxAp, sprintf('%.2f',maxAp),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
    
                info1{kk,1} = all_X_files{fi}(k).name;
                info1{kk,2} = sprintf('%.2f', maxAp - minAp);
                info1{kk,3} = '';
    
            else  % BALANCEO: normaliza 60-100%
                tiempoNorm = linspace(60, 100, length(dispXNorm));
                plot(ax1, tiempoNorm, dispXNorm, 'DisplayName', all_X_files{fi}(k).name, ...
                    'Color',colors(kk,:),'LineWidth',1.5);
    
                t_bal_norm   = linspace(0,1,length(dispXNorm));
                x_bal_interp = interp1(t_bal_norm, dispXNorm, t_common,'pchip');
                X_bal_all    = [X_bal_all; x_bal_interp];
    
                t_bal = linspace(T_apoyo_X, Tprom_X, length(dispXNorm));
                plot(ax_X_bal, t_bal, dispXNorm, 'Color',[colors(kk,:) 0.4],'LineWidth',0.8);
    
                minBal = dispXNorm(1);
                maxBal = max(dispXNorm);
                plot(ax1,60,  minBal,'o','Color',colors(kk,:),'MarkerFaceColor','w','MarkerSize',6);
                text(ax1,61,  minBal, sprintf('%.2f',minBal),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
                plot(ax1,100, maxBal,'o','Color',colors(kk,:),'MarkerFaceColor',colors(kk,:),'MarkerSize',6);
                text(ax1,101, maxBal, sprintf('%.2f',maxBal),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
    
                info1{kk,1} = all_X_files{fi}(k).name;
                info1{kk,2} = '';
                info1{kk,3} = sprintf('%.2f', maxBal - minBal);
            end
        end
    end
    
    xline(ax1,60,'--k','LineWidth',1,'Label','60%','LabelHorizontalAlignment','center');
    xlabel(ax1,'Ciclo de marcha (%)');
    ylabel(ax1,'Desplazamiento X (cm)');
    title(ax1,'Desplazamiento X RODILLA vs ciclo de marcha');
    legend(ax1,'show','Location','northeastoutside','FontSize',10,'Box','on');
    grid(ax1,'on');
    
    t1 = uitable(layout1,'Data',info1,...
        'ColumnName',{'Archivo','Δ Apoyo (cm)','Δ Balanceo (cm)'},...
        'ColumnWidth','auto','RowName',[]);
    
    %% ================== CARPETA 2 (Y) ==================
    fig2 = uifigure('Name','Desplazamiento Y','Position',[1200 100 1000 600]);
    layout2 = uigridlayout(fig2,[2 1]);
    layout2.RowHeight = {'4x','1x'};
    layout2.ColumnWidth = {'1x'};
    
    ax2 = axes(layout2);
    hold(ax2,'on');
    colors = lines(length(files2));
    info2 = cell(length(files2),3);
    
   all_Y_folders = {folder_Y_ap, folder_Y_bal};
    all_Y_files   = {files_Y_ap,  files_Y_bal};
    colors = lines(length(files2));
    info2  = cell(length(files2), 3);
    kk = 0;
    
    for fi = 1:2
        for k = 1:length(all_Y_files{fi})
            kk = kk + 1;
            data   = readmatrix(fullfile(all_Y_folders{fi}, all_Y_files{fi}(k).name));
            tiempo = data(:,1);
            dispY  = data(:,2);
    
            if max(tiempo) > 100, tiempo = tiempo/1000; end
    
            dispYNorm = normalizeDisp(dispY);
    
            if isempty(dispYNorm) || all(isnan(dispYNorm))
                warning('Archivo %s sin datos válidos', all_Y_files{fi}(k).name);
                continue
            end
    
            if fi == 1
                plot(axReal_Y_ap,  tiempo,  dispYNorm, 'LineWidth',1);
                plot(axNorm_Y_ap,  linspace(0, T_apoyo_Y, length(dispYNorm)), dispYNorm, 'Color',colors(kk,:),'LineWidth',1.5);
            else
                plot(axReal_Y_bal, tiempo,  dispYNorm, 'LineWidth',1);
                plot(axNorm_Y_bal, linspace(0, T_bal_Y,   length(dispYNorm)), dispYNorm, 'Color',colors(kk,:),'LineWidth',1.5);
            end
    
            t_common = linspace(0,1,N);
    
            if fi == 1  % APOYO
                tiempoNorm = linspace(0, 60, length(dispYNorm));
                plot(ax2, tiempoNorm, dispYNorm, 'DisplayName', all_Y_files{fi}(k).name, ...
                    'Color',colors(kk,:),'LineWidth',1.5);
    
                t_ap_norm   = linspace(0,1,length(dispYNorm));
                y_ap_interp = interp1(t_ap_norm, dispYNorm, t_common,'pchip');
                Y_apoyo_all = [Y_apoyo_all; y_ap_interp];
    
                t_ap = linspace(0, T_apoyo_Y, length(dispYNorm));
                plot(ax_Y_apoyo, t_ap, dispYNorm, 'Color',colors(kk,:),'LineWidth',0.8);
    
                maxAp = max(dispYNorm); minAp = min(dispYNorm);
                idxMaxAp = find(dispYNorm==maxAp,1); idxMinAp = find(dispYNorm==minAp,1);
                plot(ax2,tiempoNorm(idxMaxAp),maxAp,'o','Color',colors(kk,:),'MarkerFaceColor',colors(kk,:),'MarkerSize',6);
                text(ax2,tiempoNorm(idxMaxAp)+1,maxAp,sprintf('%.2f',maxAp),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
                plot(ax2,tiempoNorm(idxMinAp),minAp,'o','Color',colors(kk,:),'MarkerFaceColor','w','MarkerSize',6);
                text(ax2,tiempoNorm(idxMinAp)+1,minAp,sprintf('%.2f',minAp),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
    
                info2{kk,1} = all_Y_files{fi}(k).name;
                info2{kk,2} = sprintf('%.2f', maxAp - minAp);
                info2{kk,3} = '';
    
            else  % BALANCEO
                tiempoNorm = linspace(60, 100, length(dispYNorm));
                plot(ax2, tiempoNorm, dispYNorm, 'DisplayName', all_Y_files{fi}(k).name, ...
                    'Color',colors(kk,:),'LineWidth',1.5);
    
                t_bal_norm   = linspace(0,1,length(dispYNorm));
                y_bal_interp = interp1(t_bal_norm, dispYNorm, t_common,'pchip');
                Y_bal_all    = [Y_bal_all; y_bal_interp];
    
                t_bal = linspace(T_apoyo_Y, Tprom_Y, length(dispYNorm));
                plot(ax_Y_bal, t_bal, dispYNorm, 'Color',colors(kk,:),'LineWidth',0.8);
    
                maxBal = max(dispYNorm); minBal = min(dispYNorm);
                idxMaxBal = find(dispYNorm==maxBal,1); idxMinBal = find(dispYNorm==minBal,1);
                plot(ax2,tiempoNorm(idxMaxBal),maxBal,'o','Color',colors(kk,:),'MarkerFaceColor',colors(kk,:),'MarkerSize',6);
                text(ax2,tiempoNorm(idxMaxBal)+1,maxBal,sprintf('%.2f',maxBal),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
                plot(ax2,tiempoNorm(idxMinBal),minBal,'o','Color',colors(kk,:),'MarkerFaceColor','w','MarkerSize',6);
                text(ax2,tiempoNorm(idxMinBal)+1,minBal,sprintf('%.2f',minBal),'Color',colors(kk,:),'FontSize',9,'FontWeight','bold');
    
                info2{kk,1} = all_Y_files{fi}(k).name;
                info2{kk,2} = '';
                info2{kk,3} = sprintf('%.2f', maxBal - minBal);
            end
        end
    end
        
    xline(ax2,60,'--k','LineWidth',1,'Label','60%','LabelHorizontalAlignment','center');
    xlabel(ax2,'Ciclo de marcha (%)');
    ylabel(ax2,'Desplazamiento Y (cm)');
    title(ax2,'Desplazamiento Y RODILLA vs ciclo de marcha');
    legend(ax2,'show','Location','northeastoutside','FontSize',10,'Box','on');
    grid(ax2,'on');
    
    t2 = uitable(layout2,'Data',info2,...
        'ColumnName',{'Archivo','Δ Apoyo (cm)','Δ Balanceo (cm)'},...
        'ColumnWidth','auto','RowName',[]);
    
    %% ===== PROMEDIOS (sobre datos reales) =====
    mean_X_ap  = mean(X_apoyo_all,1);
    std_X_ap   = std(X_apoyo_all, 0,1);
    
    mean_X_bal = mean(X_bal_all,1);
    std_X_bal  = std(X_bal_all,  0,1);
    
    mean_Y_ap  = mean(Y_apoyo_all,1);
    std_Y_ap   = std(Y_apoyo_all, 0,1);
    
    mean_Y_bal = mean(Y_bal_all,1);
    std_Y_bal  = std(Y_bal_all,  0,1);
    
    t_apoyo    = linspace(0, T_apoyo_X, N);
    t_bal      = linspace(T_apoyo_X, Tprom_X, N);
    
    t_apoyo_Yv = linspace(0, T_apoyo_Y, N);
    t_bal_Yv   = linspace(T_apoyo_Y, Tprom_Y, N);
    
    %% ===== NORMALIZAR PROMEDIO X A X_NORM_CM =====

    % --- APOYO ---
    resp_ap = questdlg( ...
        'APOYO: ¿Cómo procesar el desplazamiento X?', ...
        'Normalización X — Apoyo', ...
        'Normalizar (ingresar cm)', ...
        'Usar valores reales', ...
        'Normalizar (ingresar cm)');
    
    if strcmp(resp_ap, 'Normalizar (ingresar cm)')
        NORMALIZAR_X_AP = true;
        val = inputdlg('Ingresa el valor de normalización para X APOYO (cm):', ...
                       'Valor normalización — Apoyo', 1, {num2str(X_NORM_CM)});
        if isempty(val)
            error('No se ingresó valor para normalización de Apoyo.');
        end
        X_NORM_AP = str2double(val{1});
    else
        NORMALIZAR_X_AP = false;
        X_NORM_AP = NaN;
    end
    
    minXap = min(mean_X_ap); maxXap = max(mean_X_ap);
    if NORMALIZAR_X_AP && (maxXap ~= minXap)
        mean_X_ap_norm = (mean_X_ap - minXap)/(maxXap - minXap) * X_NORM_AP;
        std_X_ap_norm  = std_X_ap  / (maxXap - minXap) * X_NORM_AP;
    else
        mean_X_ap_norm = mean_X_ap;
        std_X_ap_norm  = std_X_ap;
    end
    
    % --- BALANCEO ---
    resp_bal = questdlg( ...
        'BALANCEO: ¿Cómo procesar el desplazamiento X?', ...
        'Normalización X — Balanceo', ...
        'Normalizar (ingresar cm)', ...
        'Usar valores reales', ...
        'Normalizar (ingresar cm)');
    
    if strcmp(resp_bal, 'Normalizar (ingresar cm)')
        NORMALIZAR_X_BAL = true;
        val = inputdlg('Ingresa el valor de normalización para X BALANCEO (cm):', ...
                       'Valor normalización — Balanceo', 1, {num2str(X_NORM_CM)});
        if isempty(val)
            error('No se ingresó valor para normalización de Balanceo.');
        end
        X_NORM_BAL = str2double(val{1});
    else
        NORMALIZAR_X_BAL = false;
        X_NORM_BAL = NaN;
    end
    
    minXbal = min(mean_X_bal); maxXbal = max(mean_X_bal);
    if NORMALIZAR_X_BAL && (maxXbal ~= minXbal)
        mean_X_bal_norm = (mean_X_bal - minXbal)/(maxXbal - minXbal) * X_NORM_BAL;
        std_X_bal_norm  = std_X_bal  / (maxXbal - minXbal) * X_NORM_BAL;
    else
        mean_X_bal_norm = mean_X_bal;
        std_X_bal_norm  = std_X_bal;
    end
    
    % --- Actualizar títulos según decisión ---
    if NORMALIZAR_X_AP
        title(axC_X_ap, sprintf('X Apoyo (0 a %g cm — normalizado)', X_NORM_AP));
    else
        title(axC_X_ap, 'X Apoyo (valores reales medidos)');
    end
    
    if NORMALIZAR_X_BAL
        title(axC_X_bal, sprintf('X Balanceo (0 a %g cm — normalizado)', X_NORM_BAL));
    else
        title(axC_X_bal, 'X Balanceo (valores reales medidos)');
    end
    %% ===== FILA 1 — igual que figFases original =====
    % X Apoyo → PROMEDIO REAL + SD (NO normalizado, ese va en control)
    fill(ax_X_apoyo, ...
        [t_apoyo fliplr(t_apoyo)], ...
        [mean_X_ap+std_X_ap fliplr(mean_X_ap-std_X_ap)], ...
        'b','FaceAlpha',0.2,'EdgeColor','none');
    plot(ax_X_apoyo, t_apoyo, mean_X_ap, 'b','LineWidth',3);
    
    % X Balanceo → PROMEDIO REAL + SD
    fill(ax_X_bal, ...
        [t_bal fliplr(t_bal)], ...
        [mean_X_bal+std_X_bal fliplr(mean_X_bal-std_X_bal)], ...
        'r','FaceAlpha',0.2,'EdgeColor','none');
    plot(ax_X_bal, t_bal, mean_X_bal, 'r','LineWidth',3);
    
    % Y Apoyo (sin cambios)
    fill(ax_Y_apoyo, ...
        [t_apoyo_Yv fliplr(t_apoyo_Yv)], ...
        [mean_Y_ap+std_Y_ap fliplr(mean_Y_ap-std_Y_ap)], ...
        'b','FaceAlpha',0.2,'EdgeColor','none');
    plot(ax_Y_apoyo, t_apoyo_Yv, mean_Y_ap, 'b','LineWidth',3);
    
    % Y Balanceo (sin cambios)
    fill(ax_Y_bal, ...
        [t_bal_Yv fliplr(t_bal_Yv)], ...
        [mean_Y_bal+std_Y_bal fliplr(mean_Y_bal-std_Y_bal)], ...
        'r','FaceAlpha',0.2,'EdgeColor','none');
    plot(ax_Y_bal, t_bal_Yv, mean_Y_bal, 'r','LineWidth',3);
    % Valores por defecto para RMSE (por si el usuario eligió "Usar valores reales")
if ~exist('X_NORM_AP',  'var') || isnan(X_NORM_AP),  X_NORM_AP  = maxXap  - minXap;  end
if ~exist('X_NORM_BAL', 'var') || isnan(X_NORM_BAL), X_NORM_BAL = maxXbal - minXbal; end
    %% ===== RMSE =====
    X_apoyo_norm_all = zeros(size(X_apoyo_all));
    X_bal_norm_all   = zeros(size(X_bal_all));
    
    for i = 1:size(X_apoyo_all,1)
        if maxXap ~= minXap
            X_apoyo_norm_all(i,:) = (X_apoyo_all(i,:) - minXap)/(maxXap - minXap) * X_NORM_AP;
        end
    end
    for i = 1:size(X_bal_all,1)
        if maxXbal ~= minXbal
            X_bal_norm_all(i,:)   = (X_bal_all(i,:) - minXbal)/(maxXbal - minXbal) * X_NORM_BAL;
        end
    end
    
    rmse_X_ap  = sqrt(mean((X_apoyo_norm_all - mean_X_ap_norm).^2,'all'));
    rmse_X_bal = sqrt(mean((X_bal_norm_all   - mean_X_bal_norm).^2,'all'));
    rmse_Y_ap  = sqrt(mean((Y_apoyo_all - mean_Y_ap).^2,'all'));
    rmse_Y_bal = sqrt(mean((Y_bal_all   - mean_Y_bal).^2,'all'));
    
    text(ax_X_apoyo, 0.02, 0.98, sprintf('RMSE = %.2f', rmse_X_ap), ...
        'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top',...
        'FontSize',11,'FontWeight','bold','Color','b','BackgroundColor','w','Margin',2);
    text(ax_X_bal, 0.02, 0.98, sprintf('RMSE = %.2f', rmse_X_bal), ...
        'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top',...
        'FontSize',11,'FontWeight','bold','Color','r','BackgroundColor','w','Margin',2);
    text(ax_Y_apoyo, 0.02, 0.98, sprintf('RMSE = %.2f', rmse_Y_ap), ...
        'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top',...
        'FontSize',11,'FontWeight','bold','Color','b','BackgroundColor','w','Margin',2);
    text(ax_Y_bal, 0.02, 0.98, sprintf('RMSE = %.2f', rmse_Y_bal), ...
        'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top',...
        'FontSize',11,'FontWeight','bold','Color','r','BackgroundColor','w','Margin',2);
    
    %% ===== RESOLUCIONES =====
    dt    = 0.01;
    res_X = 0.0125;
    res_Y = 0.00625;
    
    %% ===== TIEMPOS DISCRETOS =====
    t_apoyo_X_ctrl = 0:dt:T_apoyo_X;
    t_bal_X_ctrl   = T_apoyo_X:dt:Tprom_X;
    
    t_apoyo_Y_ctrl = 0:dt:T_apoyo_Y;
    t_bal_Y_ctrl   = T_apoyo_Y:dt:Tprom_Y;
    
    %% ===== INTERPOLAR =====
    mean_X_ap_ctrl  = interp1(t_apoyo, mean_X_ap_norm,  t_apoyo_X_ctrl, 'pchip');
    std_X_ap_ctrl   = interp1(t_apoyo, std_X_ap_norm,   t_apoyo_X_ctrl, 'pchip');
    
    mean_X_bal_ctrl = interp1(t_bal,   mean_X_bal_norm, t_bal_X_ctrl,   'pchip');
    std_X_bal_ctrl  = interp1(t_bal,   std_X_bal_norm,  t_bal_X_ctrl,   'pchip');
    
    mean_Y_ap_ctrl  = interp1(t_apoyo_Yv, mean_Y_ap, t_apoyo_Y_ctrl, 'pchip');
    std_Y_ap_ctrl   = interp1(t_apoyo_Yv, std_Y_ap,  t_apoyo_Y_ctrl, 'pchip');
    
    mean_Y_bal_ctrl = interp1(t_bal_Yv,   mean_Y_bal, t_bal_Y_ctrl,  'pchip');
    std_Y_bal_ctrl  = interp1(t_bal_Yv,   std_Y_bal,  t_bal_Y_ctrl,  'pchip');
    
    %% ===== CUANTIZAR =====
    mean_X_ap_renorm  = round(mean_X_ap_ctrl  / res_X) * res_X;
    mean_X_bal_renorm = round(mean_X_bal_ctrl / res_X) * res_X;
    
    mean_Y_ap_renorm  = round(mean_Y_ap_ctrl  / res_Y) * res_Y;
    mean_Y_bal_renorm = round(mean_Y_bal_ctrl / res_Y) * res_Y;
    
    %% ===== FILA 2 — igual que figControl original =====
    
    % X Apoyo
    fill(axC_X_ap, ...
        [t_apoyo_X_ctrl fliplr(t_apoyo_X_ctrl)], ...
        [mean_X_ap_renorm + std_X_ap_ctrl, fliplr(mean_X_ap_renorm - std_X_ap_ctrl)], ...
        'b','FaceAlpha',0.2,'EdgeColor','none','DisplayName','SD');
    plot(axC_X_ap, t_apoyo, mean_X_ap_norm,'b','LineWidth',2,'DisplayName','Promedio original norm.');
    plot(axC_X_ap, t_apoyo_X_ctrl, mean_X_ap_renorm,'k--','LineWidth',2,'DisplayName','Promedio discretizado');
    
    % X Balanceo
    fill(axC_X_bal, ...
        [t_bal_X_ctrl fliplr(t_bal_X_ctrl)], ...
        [mean_X_bal_renorm + std_X_bal_ctrl, fliplr(mean_X_bal_renorm - std_X_bal_ctrl)], ...
        'r','FaceAlpha',0.2,'EdgeColor','none','DisplayName','SD');
    plot(axC_X_bal, t_bal, mean_X_bal_norm,'r','LineWidth',2,'DisplayName','Promedio original norm.');
    plot(axC_X_bal, t_bal_X_ctrl, mean_X_bal_renorm,'k--','LineWidth',2,'DisplayName','Promedio discretizado');
    
    % Y Apoyo
    fill(axC_Y_ap, ...
        [t_apoyo_Y_ctrl fliplr(t_apoyo_Y_ctrl)], ...
        [mean_Y_ap_renorm + std_Y_ap_ctrl, fliplr(mean_Y_ap_renorm - std_Y_ap_ctrl)], ...
        'b','FaceAlpha',0.2,'EdgeColor','none','DisplayName','SD');
    plot(axC_Y_ap, t_apoyo_Yv, mean_Y_ap,'b','LineWidth',2,'DisplayName','Promedio original');
    plot(axC_Y_ap, t_apoyo_Y_ctrl, mean_Y_ap_renorm,'k--','LineWidth',2,'DisplayName','Promedio discretizado');
    
    % Y Balanceo
    fill(axC_Y_bal, ...
        [t_bal_Y_ctrl fliplr(t_bal_Y_ctrl)], ...
        [mean_Y_bal_renorm + std_Y_bal_ctrl, fliplr(mean_Y_bal_renorm - std_Y_bal_ctrl)], ...
        'r','FaceAlpha',0.2,'EdgeColor','none','DisplayName','SD');
    plot(axC_Y_bal, t_bal_Yv, mean_Y_bal,'r','LineWidth',2,'DisplayName','Promedio original');
    plot(axC_Y_bal, t_bal_Y_ctrl, mean_Y_bal_renorm,'k--','LineWidth',2,'DisplayName','Promedio discretizado');
    
    legend(axC_X_ap, 'Location','northeast','FontSize',10);
    legend(axC_X_bal,'Location','northeast','FontSize',10);
    legend(axC_Y_ap, 'Location','northeast','FontSize',10);
    legend(axC_Y_bal,'Location','northeast','FontSize',10);
    
    %% ===== LABELS CONTROL =====
    xlabel(axC_X_ap,'Tiempo (s)');  ylabel(axC_X_ap,'cm');
    xlabel(axC_X_bal,'Tiempo (s)'); ylabel(axC_X_bal,'cm');
    xlabel(axC_Y_ap,'Tiempo (s)');  ylabel(axC_Y_ap,'cm');
    xlabel(axC_Y_bal,'Tiempo (s)'); ylabel(axC_Y_bal,'cm');
    
    movegui(figCombinada,'center');
    
    %% ===== AJUSTES VISUALES =====
    xlabel(axReal_X,'Tiempo (s)'); ylabel(axReal_X,'cm');
    xlabel(axReal_Y,'Tiempo (s)'); ylabel(axReal_Y,'cm');
    xlabel(axNorm_X,'Tiempo promedio (s)'); ylabel(axNorm_X,'cm');
    xlabel(axNorm_Y,'Tiempo promedio (s)'); ylabel(axNorm_Y,'cm');
    
    ylim(ax_X_apoyo,'auto');
    ylim(ax_X_bal,  'auto');
    ylim(ax_Y_apoyo,'auto');
    ylim(ax_Y_bal,  'auto');
    
    ylim(axC_X_ap,  [min(mean_X_ap_renorm)-10,  max(mean_X_ap_renorm)+10]);
    ylim(axC_X_bal, [min(mean_X_bal_renorm)-10, max(mean_X_bal_renorm)+10]);
    ylim(axC_Y_ap,  [min(mean_Y_ap_renorm)-2,   max(mean_Y_ap_renorm)+2]);
    ylim(axC_Y_bal, [min(mean_Y_bal_renorm)-3,  max(mean_Y_bal_renorm)+3]);
    
    xlabel(ax_X_apoyo,'Tiempo promedio apoyo (s)');
    xlabel(ax_X_bal,  'Tiempo promedio balanceo (s)');
    xlabel(ax_Y_apoyo,'Tiempo promedio apoyo (s)');
    xlabel(ax_Y_bal,  'Tiempo promedio balanceo (s)');
    
    ylabel(ax_X_apoyo,'cm'); ylabel(ax_X_bal,'cm');
    ylabel(ax_Y_apoyo,'cm'); ylabel(ax_Y_bal,'cm');
    
    xline(ax_X_apoyo, T_apoyo_X, '--r','LineWidth',1);
    xline(ax_X_bal,   T_apoyo_X, '--r','LineWidth',1);
    xline(ax_X_bal,   Tprom_X,   '--b','LineWidth',1);
    
    xline(ax_Y_apoyo, T_apoyo_Y, '--r','LineWidth',1);
    xline(ax_Y_bal,   T_apoyo_Y, '--r','LineWidth',1);
    xline(ax_Y_bal,   Tprom_Y,   '--b','LineWidth',1);
    
    set([ax_X_apoyo, ax_X_bal, ax_Y_apoyo, ax_Y_bal],'TickDir','out','Box','off');
    
    xt = xticks(ax_X_apoyo); xticks(ax_X_apoyo, unique([xt T_apoyo_X]));
    xt = xticks(ax_X_bal);   xticks(ax_X_bal,   unique([xt T_apoyo_X Tprom_X]));
    xt = xticks(ax_Y_apoyo); xticks(ax_Y_apoyo, unique([xt T_apoyo_Y]));
    xt = xticks(ax_Y_bal);   xticks(ax_Y_bal,   unique([xt T_apoyo_Y Tprom_Y]));
    
    xlabel(axNorm_Y,'Tiempo promedio (s)');
    ylabel(axNorm_Y,'Desplazamiento Y (cm)');
    title(axNorm_Y,'Y normalizado en tiempo (sin escalar amplitud)');
    
    %% ================== EXPORTAR CSV CONTROL ==================
    save_folder = uigetdir(pwd,'Selecciona carpeta para guardar CSV');
    if save_folder == 0
        error('No se seleccionó carpeta de guardado');
    end
    
    fid = fopen(fullfile(save_folder,'X_Apoyo.csv'),'w');
    if fid == -1, error('No se pudo crear X_Apoyo.csv'); end
    fprintf(fid,'Tiempo_s;Posicion_cm\n');
    for k = 1:length(t_apoyo_X_ctrl)
        fprintf(fid,'%.3f;%.4f\n', t_apoyo_X_ctrl(k), mean_X_ap_renorm(k));
    end
    fclose(fid);
    
    fid = fopen(fullfile(save_folder,'X_Balanceo.csv'),'w');
    if fid == -1, error('No se pudo crear X_Balanceo.csv'); end
    fprintf(fid,'Tiempo_s;Posicion_cm\n');
    for k = 1:length(t_bal_X_ctrl)
        fprintf(fid,'%.3f;%.4f\n', t_bal_X_ctrl(k), mean_X_bal_renorm(k));
    end
    fclose(fid);
    
    fid = fopen(fullfile(save_folder,'Y_Apoyo.csv'),'w');
    if fid == -1, error('No se pudo crear Y_Apoyo.csv'); end
    fprintf(fid,'Tiempo_s;Posicion_cm\n');
    for k = 1:length(t_apoyo_Y_ctrl)
        fprintf(fid,'%.3f;%.4f\n', t_apoyo_Y_ctrl(k), mean_Y_ap_renorm(k));
    end
    fclose(fid);
    
    fid = fopen(fullfile(save_folder,'Y_Balanceo.csv'),'w');
    if fid == -1, error('No se pudo crear Y_Balanceo.csv'); end
    fprintf(fid,'Tiempo_s;Posicion_cm\n');
    for k = 1:length(t_bal_Y_ctrl)
        fprintf(fid,'%.3f;%.4f\n', t_bal_Y_ctrl(k), mean_Y_bal_renorm(k));
    end
    fclose(fid);
    
    fprintf('\n✔ CSV exportados correctamente:\n');
    fprintf('X Apoyo\nX Balanceo\nY Apoyo\nY Balanceo\n');
    fprintf('Normalización X: 0 a %g cm\n', X_NORM_CM);
    fprintf('Resolución temporal: %.3f s\n', dt);
    fprintf('Resolución X: %.5f mm\n', res_X);
    fprintf('Resolución Y: %.5f mm\n', res_Y);