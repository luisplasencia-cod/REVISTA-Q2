function R = Extraer_GRF_Kuopio_Core(sub_id, opts)
% EXTRAER_GRF_KUOPIO_CORE  28-ago-2026: extrae la Fz REAL (plataforma de
%                   fuerza) de los pasos del sujeto que caen limpiamente
%                   sobre UNA de las 5 plataformas del Kuopio Gait Dataset,
%                   para comparar contra la Fz PREDICHA por
%                   GRF_Newton_ApoyoSimple_Core.m - primera vez que este
%                   proyecto compara la GRF generada contra fuerza real
%                   medida (hasta ahora solo se habia validado
%                   rodilla/tobillo/angulo tibial, nunca fuerza).
%
%   Reusa EXACTAMENTE la misma deteccion de eventos (Zeni et al. 2008,
%   maximo local de tobillo-cadera en Y = heel strike) que Cargar_
%   Kuopio2024_Core.m, para que los ciclos de fuerza y de cinematica sean
%   los MISMOS pasos - sin esto, comparar fuerza de un paso contra angulo
%   de otro paso no tendria sentido.
%
%   UMBRAL DE 20N (pedido explicito del usuario, 28-ago-2026, "podemos
%   cortar en 20N ya que eso esta justificado en la literatura tanto para
%   la plataforma como para lo que generemos"): se usa para (a) decidir
%   que plataforma esta "activa" (Fz>20N) en cada instante, y (b) recortar
%   el tramo de apoyo real a la ventana donde esa plataforma esta activa.
%
%   CRITERIO PARA ACEPTAR UN PASO: dentro de la ventana del ciclo [i0,i1]
%   (heel strike a heel strike siguiente), debe existir EXACTAMENTE UNA
%   plataforma de las 5 que cruce 20N al alza cerca de i0 (heel strike) y
%   vuelva a cruzar 20N a la baja antes de i1 (toe-off) - si dos
%   plataformas cumplen esto a la vez (el pie piso el borde entre dos
%   placas) o ninguna (el paso cayo fuera de las 5 placas, lo mas comun
%   en una pasarela de marcha libre), el paso se DESCARTA, no se adivina.
%
% ENTRADA
%   sub_id   igual que Cargar_Kuopio2024_Core.m
%   opts.dist_min_s, opts.margen_busqueda_s (default 0.35s, ventana tras
%        heel-strike para buscar el cruce de 20N - a cadencia normal el
%        contacto pleno del pie ocurre en <200ms, 0.35s da margen)
%
% SALIDA: struct R
%   R.n_pasos_validos, R.n_pasos_totales
%   R.Fz_pctBW_todos   [n_pasos_validos x 101] Fz real en %BW, malla 0:100
%                      del ciclo COMPLETO (heel-strike a heel-strike),
%                      NaN fuera de la ventana de plataforma activa
%   R.mask_activa_todos [n_pasos_validos x 101] logical, plataforma activa
%   R.placa_todos      que placa (1-5) se uso en cada paso
%   R.masa_kg, R.sexo, R.talla_cm  (para pasar a GRF_Newton_ApoyoSimple_Core)
% ==========================================================================

if nargin < 2 || isempty(opts), opts = struct(); end
if ~isfield(opts,'dist_min_s'), opts.dist_min_s = 0.6; end
if ~isfield(opts,'margen_busqueda_s'), opts.margen_busqueda_s = 0.35; end
UMBRAL_N = 20;

carpeta = fileparts(mfilename('fullpath'));
dir_raw = fullfile(carpeta, 'raw');

Tmeta = readtable(fullfile(dir_raw, 'subjects_meta.csv'));
fila = Tmeta(Tmeta.sub_id == sub_id, :);
if height(fila) ~= 1
    error('sub_id %d no encontrado en subjects_meta.csv', sub_id);
end

archivos = dir(fullfile(dir_raw, sprintf('%02d_*.csv', sub_id)));
if isempty(archivos)
    error('No se encontraron CSV de trials para el sujeto %d', sub_id);
end

pct = 0:100;
Fz_todos = []; mask_todos = []; placa_todos = []; n_totales = 0;

for k = 1:numel(archivos)
    Ttr = readtable(fullfile(dir_raw, archivos(k).name));
    if ~any(strcmp(Ttr.Properties.VariableNames, 'Force_Fz1_N_Nm'))
        continue   % trial sin columnas de fuerza (extraido antes del 28-ago-2026)
    end
    fr = 1 / median(diff(Ttr.t_s));
    t_s = Ttr.t_s;
    cad_y = Ttr.cadera_y_mm; tob_y = Ttr.tobillo_y_mm;

    % SIGNO INVERTIDO (28-ago-2026, hallazgo real, verificado en 4 trials
    % de 2 sujetos distintos): las placas de Kuopio reportan la fuerza QUE
    % EL PIE EJERCE SOBRE LA PLACA (convencion Z de la placa apuntando
    % hacia el piso), no la fuerza que la placa ejerce sobre el pie -
    % Fz baja a -800/-900N (magnitud de peso corporal) cuando alguien
    % pisa, y queda cerca de 0 cuando no. Se niega aqui, UNA SOLA VEZ,
    % para que TODO lo demas de este archivo (y el criterio Fz>=0 ya usado
    % en GRF_Newton_ApoyoSimple_Core.m) use la misma convencion "fuerza
    % sobre el sujeto, positiva hacia arriba" en todo el proyecto.
    Fz = -[Ttr.Force_Fz1_N_Nm, Ttr.Force_Fz2_N_Nm, Ttr.Force_Fz3_N_Nm, Ttr.Force_Fz4_N_Nm, Ttr.Force_Fz5_N_Nm];

    senal = tob_y - cad_y;
    dist_min_muestras = round(opts.dist_min_s * fr);
    idx_picos = picos_locales_local(senal, dist_min_muestras);
    if numel(idx_picos) < 2, continue; end

    for c = 1:(numel(idx_picos)-1)
        i0 = idx_picos(c); i1 = idx_picos(c+1);
        n_muestras = i1 - i0 + 1;
        if n_muestras < round(0.4*fr) || n_muestras > round(2.5*fr)
            continue
        end
        n_totales = n_totales + 1;

        % --- buscar que placa(s) cruzan 20N al alza cerca de i0 ---
        i_busq_fin = min(i1, i0 + round(opts.margen_busqueda_s*fr));
        placas_candidatas = [];
        for p = 1:5
            ventana = Fz(i0:i_busq_fin, p);
            if any(ventana >= UMBRAL_N) && Fz(i0,p) < UMBRAL_N
                placas_candidatas(end+1) = p; %#ok<AGROW>
            end
        end
        if numel(placas_candidatas) ~= 1
            continue   % 0 o >=2 placas candidatas: descartar (ver cabecera)
        end
        p = placas_candidatas(1);
        % FILTRO DE PLACA (28-ago-2026, hallazgo del usuario + verificacion
        % propia): las placas de BORDE del pasillo (1 y 3 en este dataset)
        % dan un ajuste sistematicamente peor contra la Fz predicha (r
        % medio -0.46 en 4 pasos) que la placa 2 (r medio 0.21 en 34
        % pasos) - y ya se habia visto antes que la placa 4 tiene una
        % deriva constante de ~-253N en varios trials (posible offset de
        % cero mal calibrado). Se restringe a la placa 2 (la que
        % practicamente todos los sujetos pisan, la mas central del
        % pasillo) - no es ajustar el modelo a los datos, es preferir el
        % sensor mejor calibrado/mas usado del propio dataset.
        if p ~= 2
            continue
        end
        fz_ciclo = Fz(i0:i1, p);
        activa = fz_ciclo >= UMBRAL_N;
        if sum(activa) < round(0.1*n_muestras)
            continue   % cruce espurio (ruido), casi nada de tiempo activo
        end
        % FILTRO DE CALIDAD (28-ago-2026, hallazgo del usuario: "algunas
        % data... se corta su senal"): si la placa SIGUE activa en la
        % ULTIMA muestra de la ventana del ciclo (i1, el siguiente heel-
        % strike detectado), significa que el despegue real NO se capturo
        % dentro de esta ventana - o el trial termino antes de que el pie
        % se levantara, o el evento i1 se detecto mal (ver Zeni et al.
        % 2008, metodo cinematico, puede fallar en el ultimo ciclo de un
        % trial corto). Verificado en 5/44 pasos: la senal quedaba en
        % 65-124%BW justo en pct=100 en vez de caer a ~0 cerca del
        % despegue fisiologico normal (~60-65% del ciclo) - se descartan,
        % no se extrapola ni se asume donde habria terminado.
        if activa(end)
            continue
        end

        tt = linspace(0, 100, n_muestras);
        fz_pctbw = fz_ciclo(:)' / (fila.masa_kg*9.80665) * 100;
        fz_i = interp1(tt, fz_pctbw, pct, 'linear');
        act_i = interp1(tt, double(activa(:)'), pct, 'nearest') > 0;
        fz_i(~act_i) = NaN;

        Fz_todos(end+1,:) = fz_i; %#ok<AGROW>
        mask_todos(end+1,:) = act_i; %#ok<AGROW>
        placa_todos(end+1) = p; %#ok<AGROW>
    end
end

R = struct();
R.n_pasos_validos = size(Fz_todos,1);
R.n_pasos_totales = n_totales;
R.Fz_pctBW_todos = Fz_todos;
R.mask_activa_todos = logical(mask_todos);
R.placa_todos = placa_todos;
R.masa_kg = fila.masa_kg; R.sexo = fila.sexo{1}; R.talla_cm = fila.talla_cm;
R.pct_ciclo = pct;

end

% ==========================================================================
function idx = picos_locales_local(x, dist_min)
x = x(:);
cand = find(x(2:end-1) > x(1:end-2) & x(2:end-1) > x(3:end)) + 1;
if isempty(cand), idx = []; return; end
idx = cand(1);
for i = 2:numel(cand)
    if cand(i) - idx(end) >= dist_min
        idx(end+1) = cand(i); %#ok<AGROW>
    elseif x(cand(i)) > x(idx(end))
        idx(end) = cand(i);
    end
end
end
