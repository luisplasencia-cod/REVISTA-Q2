    function App_Animacion_Cadera_Rodilla_Tobillo()
% APP_ANIMACION_CADERA_RODILLA_TOBILLO  Herramienta INTERACTIVA (pedido
%   explicito del usuario, 30-ago-2026, prompt completo): anima el
%   desplazamiento de rodilla y tobillo durante un ciclo de marcha
%   completo con cinematica directa (cadena abierta cadera-rodilla-
%   tobillo, tipo pendulo doble). Candidato: SOLO Koopman (unico angulo
%   validado contra dato real, ver GUIA_INTERPRETACION.md #RODILLA) -
%   solo se ingresa talla, todo lo demas (velocidad, L1, L2, duracion de
%   ciclo) se deriva de ahi con el pipeline ya existente del proyecto.
%   SIN exportacion (GIF/video) - a pedido explicito del usuario, es solo
%   para visualizar/interactuar en vivo.
%
% Construida de CERO (usa Cinematica_DoblePendulo_Core.m y Trayectoria_
% Cadera_Core.m, nuevas, mismo pedido) - NO reusa Cadena_Completa_Core.m
% ni Cadera_Continua_Zhao_Core.m, para poder comparar al final contra
% esas soluciones ya existentes en el proyecto.
%
% DATOS QUE SI SE REUSAN (son insumos/datos, no una "solucion de
% posicion" - confirmado con el usuario, 30-ago-2026):
%   Estimar_Antropometria_Core.m   talla -> L1 (muslo), L2 (tibia), m
%   Temporizacion_Core.m           velocidad (Froude si no se mide) +
%                                   duracion de ciclo
%   Koopman2014_Core.m             theta1 = cadera_flexext (deg, "flexion
%                                   positiva", ya verificado empiricamente
%                                   contra Perry & Burnfield/Winter)
%   Reduccion_Winter_Core.m        theta2 = theta_tibia_via_rodilla_rad
%                                   (rad, MISMA referencia y signo que
%                                   theta1 - unico camino validado contra
%                                   dato real para Koopman, r=0.982 vs
%                                   CSV real, r=0.933 vs 246 sujetos
%                                   Kuopio; el camino "via tobillo" esta
%                                   marcado como no confiable, no se usa)
%
% UNIDADES: todo en CENTIMETROS dentro de esta app.
%
% CONTROLES:
%   - Talla (m), editable - dispara recalculo completo al cambiar
%   - Amplitud vertical de cadera A (cm), editable - default 2.25 cm
%     (~4.5cm pico a pico, centro del rango 4-5cm de literatura -
%     Saunders/Inman/Eberhart 1953 y fuentes posteriores, ver
%     Trayectoria_Cadera_Core.m para el detalle de la verificacion)
%   - Slider de %ciclo (0-100) - avance MANUAL, arrastrar en cualquier
%     direccion
%   - Boton Reproducir/Pausar - avance AUTOMATICO continuo (timer),
%     hace loop de un solo ciclo (100% -> 0%)
%
% PANELES:
%   - Mapa sagital: segmentos cadera-rodilla-tobillo (linea solida) +
%     trayectoria PUNTEADA de rodilla y tobillo, revelada progresivamente
%     hasta el %ciclo actual (no pre-dibujada completa)
%   - Lectura numerica en vivo: theta1, theta2 (deg), posicion (x,y) de
%     rodilla y tobillo (cm)
%   - Graficas %ciclo vs desplazamiento (X e Y por separado) de rodilla y
%     tobillo, normalizadas a 0 en el punto inicial (0%), con marcador
%     movil sincronizado con el %ciclo actual
%
% USO: correr en una sesion MATLAB interactiva (Editor o consola normal,
% NO en modo -batch, que cierra la figura al terminar el script):
%   >> App_Animacion_Cadera_Rodilla_Tobillo
% ==========================================================================

    % ---------- estado compartido (workspace de la funcion principal,
    % visible y modificable por todas las funciones anidadas de abajo -
    % patron estandar de una app de un solo archivo en MATLAB, sin
    % necesidad de App Designer / clases) ----------
    n            = 101;    % puntos por ciclo (0-100%), MISMO grid que Koopman2014_Core
    A_cm         = 2.25;
    pct_actual   = 0;
    corriendo    = false;
    PASO_TICK    = 1;      % %ciclo que avanza cada tick del timer
    PERIODO_TICK = 0.05;   % s entre ticks -> un ciclo completo dura ~5 s en Reproducir

    pct          = linspace(0, 100, n);
    theta1_full  = zeros(1, n);
    theta2_full  = zeros(1, n);
    L1_cm = NaN; L2_cm = NaN; zancada_cm = NaN;
    Xh_full = zeros(1,n); Yh_full = zeros(1,n);
    Xk_full = zeros(1,n); Yk_full = zeros(1,n);
    Xa_full = zeros(1,n); Ya_full = zeros(1,n);
    dXk_full = zeros(1,n); dYk_full = zeros(1,n);
    dXa_full = zeros(1,n); dYa_full = zeros(1,n);
    Xm_full = nan(1,n); Ym_full = nan(1,n);
    dXm_full = nan(1,n); dYm_full = nan(1,n);
    hay_montaje = false;  % true cuando efMontaje.Value > 0 (ver Recalcular)

    tmr = [];

    % ---------- figura y layout ----------
    fig = uifigure('Name', 'Cadera - rodilla - tobillo: ciclo de marcha', ...
        'Position', [70 40 1220 840]);
    fig.CloseRequestFcn = @OnCerrar;

    gl = uigridlayout(fig, [4,1]);
    gl.RowHeight = {60, 55, '2x', '1x'};

    % --- fila 1: talla / amplitud / boton reproducir ---
    glCtrl = uigridlayout(gl, [1,11]);
    glCtrl.Layout.Row = 1; glCtrl.Layout.Column = 1;
    glCtrl.ColumnWidth = {80,90,190,90,230,90,205,225,110,140,'1x'};
    glCtrl.Padding = [0 0 0 0];

    uilabel(glCtrl, 'Text', 'Talla (m):');
    efTalla = uieditfield(glCtrl, 'numeric', 'Value', 1.70, 'Limits', [1.30 2.10]);
    uilabel(glCtrl, 'Text', 'Amplitud vertical cadera A (cm):');
    efA = uieditfield(glCtrl, 'numeric', 'Value', A_cm, 'Limits', [0 6]);
    % 02-sep-2026 (sesion de integracion con GAITSIM/Raspberry, pedido del
    % usuario): punto de montaje protesico sobre el segmento tibial,
    % distancia en cm DESDE EL TOBILLO hacia la rodilla (0 <= valor <=
    % L2_cm, validado en Recalcular). Con 0 (default) el comportamiento es
    % identico al de antes de este cambio (no se dibuja ningun punto
    % nuevo) - ver Aplicar_Punto_Montaje_Core.m para la formula y la
    % convencion de angulo/eje usada (misma que Cinematica_DoblePendulo_
    % Core.m, NO la de Cadena_Cinematica_Core.m/el CSV del simulador).
    uilabel(glCtrl, 'Text', 'Punto de montaje (cm desde tobillo):');
    efMontaje = uieditfield(glCtrl, 'numeric', 'Value', 0, 'Limits', [0 Inf]);
    % 31-ago-2026 (tarde-noche, pedido del usuario): separados en DOS
    % checkboxes independientes (antes un solo "Correccion final" que los
    % ataba juntos sin poder ver el estado intermedio). La calibracion de
    % angulo (LOSO, Calibracion_Koopman_Kuopio_Core.m) es una correccion
    % YA CONFIRMADA de forma independiente (corrige un sesgo sistematico
    % de Koopman 2014, documentado y validado antes de que existiera la
    % correccion de posicion) - se puede activar sola. La correccion de
    % posicion (HIBRIDA desde esta noche - warp temporal en X + Fourier
    % sin cambio en Y, Correccion_Hibrida_PenduloDoble_Core.m) SI se
    % ajusto asumiendo angulo ya calibrado (Analisis_Correccion_
    % Fase6_ComboSuave.m) - activarla fuerza tambien el angulo (ver
    % callbacks abajo), no se puede activar sola.
    cbAngulo   = uicheckbox(glCtrl, 'Text', 'Calibrar angulo (LOSO)', 'Value', false);
    cbPosicion = uicheckbox(glCtrl, 'Text', 'Corregir posicion (hibrida: warp X + Fourier Y, requiere angulo)', 'Value', false);
    btnPlay = uibutton(glCtrl, 'Text', 'Reproducir');
    % 02-sep-2026 (sesion de integracion con GAITSIM/Raspberry, pedido
    % explicito del usuario): exporta el CSV real (Escribir_CSV_Simulador.m,
    % via Generar_Trayectoria.m) para la talla y el punto de montaje que
    % esten cargados AHORA MISMO en la app - la trayectoria final exportada
    % es la del punto de montaje si esta activo (mismo criterio que se ve en
    % pantalla), no un barrido automatico. Control manual, uno a la vez, a
    % pedido del usuario.
    btnExportar = uibutton(glCtrl, 'Text', 'Exportar CSV');
    lblInfo = uilabel(glCtrl, 'Text', '', 'FontColor', [0.4 0.4 0.4]);

    % --- fila 2: slider de %ciclo + advertencia de rango de la correccion ---
    glSlider = uigridlayout(gl, [1,3]);
    glSlider.Layout.Row = 2; glSlider.Layout.Column = 1;
    glSlider.ColumnWidth = {110,'1x',380};
    glSlider.Padding = [0 10 0 10];
    uilabel(glSlider, 'Text', '% ciclo (manual):');
    sldPct = uislider(glSlider, 'Limits', [0 100], 'Value', 0);
    lblAdvertencia = uilabel(glSlider, 'Text', '', 'FontColor', [0.75 0.10 0.10], 'FontWeight', 'bold');

    % --- fila 3: mapa sagital + lectura numerica ---
    glMedio = uigridlayout(gl, [1,2]);
    glMedio.Layout.Row = 3; glMedio.Layout.Column = 1;
    glMedio.ColumnWidth = {'3x','1x'};

    axMapa = uiaxes(glMedio);
    axMapa.Layout.Row = 1; axMapa.Layout.Column = 1;
    title(axMapa, 'Cadena cadera - rodilla - tobillo (plano sagital)');
    xlabel(axMapa, 'X (cm) - avance'); ylabel(axMapa, 'Y (cm) - altura');
    axis(axMapa, 'equal'); grid(axMapa, 'on'); hold(axMapa, 'on');

    trRodilla = plot(axMapa, nan, nan, ':', 'LineWidth', 1.4, 'Color', [0.15 0.35 0.75]);
    trTobillo = plot(axMapa, nan, nan, ':', 'LineWidth', 1.4, 'Color', [0.75 0.30 0.15]);
    trMontaje = plot(axMapa, nan, nan, ':', 'LineWidth', 1.4, 'Color', [0.20 0.60 0.25]);
    lnMuslo   = plot(axMapa, nan, nan, '-o', 'LineWidth', 2.5, ...
        'Color', [0.15 0.35 0.75], 'MarkerFaceColor', [0.15 0.35 0.75]);
    lnTibia   = plot(axMapa, nan, nan, '-o', 'LineWidth', 2.5, ...
        'Color', [0.75 0.30 0.15], 'MarkerFaceColor', [0.75 0.30 0.15]);
    mkMontaje = plot(axMapa, nan, nan, 'd', 'MarkerSize', 9, ...
        'Color', [0.20 0.60 0.25], 'MarkerFaceColor', [0.20 0.60 0.25]);
    legend(axMapa, [lnMuslo lnTibia trRodilla trTobillo mkMontaje], ...
        {'muslo (cadera-rodilla)','tibia (rodilla-tobillo)','trayectoria rodilla','trayectoria tobillo','punto de montaje'}, ...
        'Location', 'southoutside');

    pReadout = uipanel(glMedio, 'Title', 'Lectura en vivo');
    pReadout.Layout.Row = 1; pReadout.Layout.Column = 2;
    lblReadout = uilabel(pReadout, 'Position', [10 10 230 300], ...
        'Text', '', 'VerticalAlignment', 'top', 'WordWrap', 'on');

    % --- fila 4: graficas %ciclo vs desplazamiento (X e Y) ---
    glGraf = uigridlayout(gl, [1,2]);
    glGraf.Layout.Row = 4; glGraf.Layout.Column = 1;

    axDx = uiaxes(glGraf); axDx.Layout.Row = 1; axDx.Layout.Column = 1;
    title(axDx, 'Desplazamiento X (con "Corregir posicion" activo, 0% no es exactamente 0cm - ver informe)');
    xlabel(axDx, '% ciclo'); ylabel(axDx, 'X - X(0%)  (cm)');
    grid(axDx, 'on'); hold(axDx, 'on'); xlim(axDx, [0 100]);
    ln_dxK = plot(axDx, pct, nan(1,n), 'Color', [0.15 0.35 0.75], 'LineWidth', 1.5);
    ln_dxA = plot(axDx, pct, nan(1,n), 'Color', [0.75 0.30 0.15], 'LineWidth', 1.5);
    ln_dxM = plot(axDx, pct, nan(1,n), 'Color', [0.20 0.60 0.25], 'LineWidth', 1.5);
    mk_dxK = plot(axDx, nan, nan, 'o', 'MarkerFaceColor', [0.15 0.35 0.75], 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    mk_dxA = plot(axDx, nan, nan, 'o', 'MarkerFaceColor', [0.75 0.30 0.15], 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    mk_dxM = plot(axDx, nan, nan, 'o', 'MarkerFaceColor', [0.20 0.60 0.25], 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    legend(axDx, [ln_dxK ln_dxA ln_dxM], {'rodilla','tobillo','punto de montaje'}, 'Location', 'best');

    axDy = uiaxes(glGraf); axDy.Layout.Row = 1; axDy.Layout.Column = 2;
    title(axDy, 'Desplazamiento Y (con "Corregir posicion" activo, 0% no es exactamente 0cm - ver informe)');
    xlabel(axDy, '% ciclo'); ylabel(axDy, 'Y - Y(0%)  (cm)');
    grid(axDy, 'on'); hold(axDy, 'on'); xlim(axDy, [0 100]);
    ln_dyK = plot(axDy, pct, nan(1,n), 'Color', [0.15 0.35 0.75], 'LineWidth', 1.5);
    ln_dyA = plot(axDy, pct, nan(1,n), 'Color', [0.75 0.30 0.15], 'LineWidth', 1.5);
    ln_dyM = plot(axDy, pct, nan(1,n), 'Color', [0.20 0.60 0.25], 'LineWidth', 1.5);
    mk_dyK = plot(axDy, nan, nan, 'o', 'MarkerFaceColor', [0.15 0.35 0.75], 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    mk_dyA = plot(axDy, nan, nan, 'o', 'MarkerFaceColor', [0.75 0.30 0.15], 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    mk_dyM = plot(axDy, nan, nan, 'o', 'MarkerFaceColor', [0.20 0.60 0.25], 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
    legend(axDy, [ln_dyK ln_dyA ln_dyM], {'rodilla','tobillo','punto de montaje'}, 'Location', 'best');

    % ---------- callbacks ----------
    efTalla.ValueChangedFcn    = @Recalcular;
    efA.ValueChangedFcn        = @Recalcular;
    efMontaje.ValueChangedFcn  = @Recalcular;
    cbAngulo.ValueChangedFcn   = @OnCambioAngulo;
    cbPosicion.ValueChangedFcn = @OnCambioPosicion;
    sldPct.ValueChangingFcn = @OnSlider;
    btnPlay.ButtonPushedFcn = @OnPlayPause;
    btnExportar.ButtonPushedFcn = @OnExportarCSV;

    tmr = timer('ExecutionMode', 'fixedRate', 'Period', PERIODO_TICK, 'TimerFcn', @OnTick);

    Recalcular();

    % ====================================================================
    function OnCambioAngulo(~, ~)
        % Apagar el angulo mientras la posicion esta activa no tiene
        % sentido (la correccion de posicion se ajusto asumiendo angulo
        % ya calibrado) - se apaga tambien la posicion junto con el angulo.
        if ~cbAngulo.Value && cbPosicion.Value
            cbPosicion.Value = false;
        end
        Recalcular();
    end

    % ====================================================================
    function OnCambioPosicion(~, ~)
        % Activar la posicion sin el angulo calibrado es la combinacion
        % NO validada (cabecera de Correccion_Posicion_Suave_PenduloDoble_
        % Core.m) - se activa el angulo automaticamente junto con ella.
        if cbPosicion.Value && ~cbAngulo.Value
            cbAngulo.Value = true;
        end
        Recalcular();
    end

    % ====================================================================
    function Recalcular(~, ~)
        talla_m = efTalla.Value;
        A_cm = efA.Value;

        try
            antro = Estimar_Antropometria_Core(struct('talla_m', talla_m));
            tempo = Temporizacion_Core(antro, 'Koopman');
            % congelar_vl_angulo=true (02-sep-2026): MISMA correccion que
            % Obtener_Theta_Tibia_Candidato.m/Obtener_Angulos_Candidato.m
            % (produccion) - sin esto, la app quedaba desincronizada del
            % pipeline real (llamaba a Koopman2014_Core directo, que
            % mantiene su propio default sin congelar por diseno, ver
            % cabecera de Koopman2014_Core.m). Detalle: GUIA_INTERPRETACION.md #10.
            K = Koopman2014_Core(tempo.velocidad_ms*3.6, antro.talla_m, ...
                struct('nMuestras', n, 'congelar_vl_angulo', true, 'v_ref_kph', 5.0, 'l_ref_m', 1.735));
        catch ME
            uialert(fig, ME.message, 'Error al calcular');
            return;
        end

        theta1_full = deg2rad(K.cadera_flexext.angulo_deg(:).');
        theta2_full = K.theta_tibia_via_rodilla_rad(:).';

        % 31-ago-2026 (tarde-noche, pedido del usuario): DOS estados
        % independientes, ya no un solo checkbox. cbAngulo (LOSO,
        % Calibracion_Koopman_Kuopio_Core.m) es una correccion CONFIRMADA
        % por si sola, se puede activar sin la posicion. cbPosicion
        % (Correccion_Hibrida_PenduloDoble_Core.m: warp temporal en X,
        % Fourier K=14 sin cambio en Y - reemplaza la version solo-Fourier
        % y la de 16 tramos, ambas con costura o retrocesos) SI requiere
        % angulo ya calibrado (se ajusto asumiendo eso) - los callbacks
        % OnCambioAngulo/OnCambioPosicion ya fuerzan que no se pueda
        % activar sola. Con AMBOS apagados (default), la app muestra el
        % pendulo doble + cadera oscilatoria TAL CUAL sale, sin nada.
        RANGO_TALLA_VALIDADO_CM = [161.0, 186.6];
        talla_cm_actual = talla_m * 100;
        fuera_de_rango = talla_cm_actual < RANGO_TALLA_VALIDADO_CM(1) || talla_cm_actual > RANGO_TALLA_VALIDADO_CM(2);
        % 31-ago-2026 (pedido del usuario, "verifica que quede claro"):
        % con cbAngulo APAGADO (estado por defecto), el angulo tibial
        % mostrado NO tiene la calibracion LOSO aplicada - Calibracion_
        % Koopman_Kuopio_Core.m ya documenta que el angulo crudo de
        % Koopman SOBREESTIMA la excursion real ~20-23% (ganancia_tibia=
        % 0.81 < 1). Antes esto no se avisaba en pantalla, solo en
        % comentarios de codigo - el informe si lo dice siempre ("CRUDO,
        % sin calibrar"), la app no.
        if cbPosicion.Value && fuera_de_rango
            lblAdvertencia.Text = sprintf('ATENCION: talla fuera del rango validado (%.0f-%.1f cm) - correccion en extrapolacion', ...
                RANGO_TALLA_VALIDADO_CM(1), RANGO_TALLA_VALIDADO_CM(2));
        elseif ~cbAngulo.Value
            lblAdvertencia.Text = 'Angulo SIN calibrar: sobreestima la excursion real ~20-23% (ver Calibracion_Koopman_Kuopio_Core.m)';
        else
            lblAdvertencia.Text = '';
        end

        if cbAngulo.Value
            cal = Calibracion_Koopman_Kuopio_Core();
            theta1_full = deg2rad(cal.off_muslo_deg) + cal.gan_muslo * theta1_full;
            theta2_full = deg2rad(cal.off_tibia_deg) + cal.gan_tibia * theta2_full;
        end

        L1_cm = antro.long_muslo_m * 100;
        L2_cm = antro.long_tibia_m * 100;
        zancada_cm = tempo.velocidad_ms * tempo.tiempo_ciclo_s * 100;

        cad = Trayectoria_Cadera_Core(pct, zancada_cm, A_cm, 0);
        Xh_full = cad.Xh_cm; Yh_full = cad.Yh_cm;

        pos = Cinematica_DoblePendulo_Core(theta1_full, theta2_full, L1_cm, L2_cm, Xh_full, Yh_full);
        Xk_full = pos.Xk; Yk_full = pos.Yk;
        Xa_full = pos.Xa; Ya_full = pos.Ya;

        if cbPosicion.Value
            Xk_n = Xk_full - Xk_full(1); Yk_n = Yk_full - Yk_full(1);
            Xa_n = Xa_full - Xa_full(1); Ya_n = Ya_full - Ya_full(1);
            % 31-ago-2026/01-sep-2026/02-sep-2026: correccion HIBRIDA -
            % warp temporal + PAVA (Proyeccion_Isotonica_Core.m) + afin
            % CONSTANTE para X (garantiza 0 retrocesos SIEMPRE, para
            % cualquier talla, y monotono en talla), Fourier sin cambio
            % para Y - ver cabecera de Correccion_Hibrida_PenduloDoble_
            % Core.m. Reemplaza a Correccion_
            % Posicion_Suave_PenduloDoble_Core.m como correccion de
            % produccion (esa funcion sigue existiendo, la usa Y por
            % dentro de la hibrida).
            corr = Correccion_Hibrida_PenduloDoble_Core(pct, Xk_n, Yk_n, Xa_n, Ya_n, tempo.velocidad_ms);
            Xk_full = Xk_full + (corr.Xk - Xk_n);
            Yk_full = Yk_full + (corr.Yk - Yk_n);
            Xa_full = Xa_full + (corr.Xa - Xa_n);
            Ya_full = Ya_full + (corr.Ya - Ya_n);
            % BUG ENCONTRADO Y CORREGIDO 31-ago-2026 (sesion de
            % continuacion, reportado por el usuario: "el informe llega a
            % un valor en X pero la app llega a otro"): la grafica de
            % Desplazamiento (abajo) SIEMPRE hacia Xk_full-Xk_full(1),
            % incluso con la correccion activa. Algebraicamente eso
            % equivale a corr.Xk-corr.Xk(1) - es decir, CANCELA el offset
            % a(0) que la correccion aprendio (el ajuste de Fourier no
            % esta forzado a pasar por 0 en t=0, ver Correccion_Posicion_
            % Suave_PenduloDoble_Core.m) - desalineaba la app hasta 2.4cm
            % en rodilla X y 2.5cm en tobillo X frente a lo que en
            % realidad valida el informe (Evaluar_CorreccionFinal_vs_
            % Kuopio.m / Refit_CorreccionFinal_TallaSola.m usan corr.Xk
            % TAL CUAL, sin restar corr.Xk(1) - y esa es la convencion que
            % da mejor RMSEnorm, ver nota en Correccion_Posicion_Suave_
            % PenduloDoble_Core.m sobre por que forzar el cierre en 0 se
            % probo y se revirtio). Variables dXk_full/dYk_full/dXa_full/
            % dYa_full (abajo) son SOLO para la grafica de desplazamiento
            % - usan corr.Xk/Yk/Xa/Ya directo, misma convencion que el
            % informe, para que la app y el informe muestren el MISMO
            % numero con la misma talla.
            dXk_full = corr.Xk; dYk_full = corr.Yk;
            dXa_full = corr.Xa; dYa_full = corr.Ya;
        else
            dXk_full = Xk_full - Xk_full(1); dYk_full = Yk_full - Yk_full(1);
            dXa_full = Xa_full - Xa_full(1); dYa_full = Ya_full - Ya_full(1);
        end

        % 02-sep-2026: punto de montaje protesico (Aplicar_Punto_Montaje_
        % Core.m), calculado DESPUES de ambas correcciones (angulo LOSO y/o
        % posicion hibrida, lo que este activo) - usa rodilla Y tobillo
        % (Xk_full/Yk_full, Xa_full/Ya_full) YA finales de esta llamada.
        %
        % REESCRITO 03-sep-2026 (firma nueva de Aplicar_Punto_Montaje_
        % Core.m): el punto ya NO se calcula con theta_tibia (el angulo del
        % MODELO) - se calcula sobre el SEGMENTO que forman los dos puntos
        % ya generados. Motivo: con la correccion de posicion activa, el
        % segmento rodilla-tobillo corregido ya no mide L_tibia ni apunta
        % en direccion theta_tibia (se desvia hasta 5.2% / 7.6 grados,
        % informe tecnico Seccion Limitaciones) - usar theta_tibia dejaba
        % el punto hasta 2.5 cm fuera del segmento visible en pantalla.
        % Con la definicion nueva, el punto SIEMPRE cae sobre el segmento
        % que se esta dibujando, y la validacion de rango usa la longitud
        % REAL del segmento en cada instante, no L2_cm nominal.
        d_montaje_cm = efMontaje.Value;
        hay_montaje = d_montaje_cm > 0;
        if hay_montaje
            L_seg_min = min(hypot(Xk_full - Xa_full, Yk_full - Ya_full));
            if d_montaje_cm > L_seg_min
                uialert(fig, sprintf(['Punto de montaje (%.1f cm) mayor que el segmento tobillo-rodilla ' ...
                    'generado (minimo del ciclo: %.1f cm) - no puede estar mas alla de la rodilla. ' ...
                    'Se ignora hasta que ajustes el valor.'], d_montaje_cm, L_seg_min), 'Punto de montaje fuera de rango');
                hay_montaje = false;
                Xm_full = nan(1,n); Ym_full = nan(1,n);
            else
                pm = Aplicar_Punto_Montaje_Core(Xa_full, Ya_full, Xk_full, Yk_full, d_montaje_cm);
                Xm_full = pm.Xm_cm; Ym_full = pm.Ym_cm;
            end
        else
            Xm_full = nan(1,n); Ym_full = nan(1,n);
        end
        dXm_full = Xm_full - Xm_full(1);
        dYm_full = Ym_full - Ym_full(1);

        margen = 15;
        xTodos = [Xk_full, Xa_full, Xh_full];
        yTodos = [Yk_full, Ya_full, Yh_full];
        if hay_montaje
            xTodos = [xTodos, Xm_full]; %#ok<AGROW>
            yTodos = [yTodos, Ym_full]; %#ok<AGROW>
        end
        xlim(axMapa, [min(xTodos)-margen, max(xTodos)+margen]);
        ylim(axMapa, [min(yTodos)-margen, max(yTodos)+margen]);

        set(ln_dxK, 'YData', dXk_full);
        set(ln_dxA, 'YData', dXa_full);
        set(ln_dxM, 'YData', dXm_full);
        set(ln_dyK, 'YData', dYk_full);
        set(ln_dyA, 'YData', dYa_full);
        set(ln_dyM, 'YData', dYm_full);
        ylim(axDx, 'auto'); ylim(axDy, 'auto');

        lblInfo.Text = sprintf('v=%.2f m/s | T_ciclo=%.2f s | zancada=%.1f cm | L1=%.1f cm | L2=%.1f cm', ...
            tempo.velocidad_ms, tempo.tiempo_ciclo_s, zancada_cm, L1_cm, L2_cm);

        pct_actual = 0;
        sldPct.Value = 0;
        ActualizarCuadro();
    end

    % ====================================================================
    function ActualizarCuadro(~, ~)
        idx = 1 + round(pct_actual/100*(n-1));
        idx = max(1, min(n, idx));

        Xh_i = Xh_full(idx); Yh_i = Yh_full(idx);
        Xk_i = Xk_full(idx); Yk_i = Yk_full(idx);
        Xa_i = Xa_full(idx); Ya_i = Ya_full(idx);

        set(lnMuslo, 'XData', [Xh_i, Xk_i], 'YData', [Yh_i, Yk_i]);
        set(lnTibia, 'XData', [Xk_i, Xa_i], 'YData', [Yk_i, Ya_i]);

        set(trRodilla, 'XData', Xk_full(1:idx), 'YData', Yk_full(1:idx));
        set(trTobillo, 'XData', Xa_full(1:idx), 'YData', Ya_full(1:idx));

        set(mk_dxK, 'XData', pct(idx), 'YData', dXk_full(idx));
        set(mk_dxA, 'XData', pct(idx), 'YData', dXa_full(idx));
        set(mk_dyK, 'XData', pct(idx), 'YData', dYk_full(idx));
        set(mk_dyA, 'XData', pct(idx), 'YData', dYa_full(idx));

        if hay_montaje
            Xm_i = Xm_full(idx); Ym_i = Ym_full(idx);
            set(mkMontaje, 'XData', Xm_i, 'YData', Ym_i);
            set(trMontaje, 'XData', Xm_full(1:idx), 'YData', Ym_full(1:idx));
            set(mk_dxM, 'XData', pct(idx), 'YData', dXm_full(idx));
            set(mk_dyM, 'XData', pct(idx), 'YData', dYm_full(idx));
            txtMontaje = sprintf('\n\nPunto de montaje (%.1f cm desde tobillo):\n  X = %.2f cm\n  Y = %.2f cm', ...
                efMontaje.Value, Xm_i, Ym_i);
        else
            set(mkMontaje, 'XData', nan, 'YData', nan);
            set(trMontaje, 'XData', nan, 'YData', nan);
            set(mk_dxM, 'XData', nan, 'YData', nan);
            set(mk_dyM, 'XData', nan, 'YData', nan);
            txtMontaje = '';
        end

        lblReadout.Text = sprintf([...
            '%% ciclo: %.1f\n\n' ...
            'theta1 (muslo): %.1f grados\n' ...
            'theta2 (tibia): %.1f grados\n\n' ...
            'Rodilla:\n  X = %.2f cm\n  Y = %.2f cm\n\n' ...
            'Tobillo:\n  X = %.2f cm\n  Y = %.2f cm%s'], ...
            pct(idx), rad2deg(theta1_full(idx)), rad2deg(theta2_full(idx)), ...
            Xk_i, Yk_i, Xa_i, Ya_i, txtMontaje);
    end

    % ====================================================================
    function OnSlider(~, event)
        pct_actual = event.Value;
        if corriendo
            corriendo = false;
            stop(tmr);
            btnPlay.Text = 'Reproducir';
        end
        ActualizarCuadro();
    end

    % ====================================================================
    function OnPlayPause(~, ~)
        corriendo = ~corriendo;
        if corriendo
            btnPlay.Text = 'Pausar';
            start(tmr);
        else
            btnPlay.Text = 'Reproducir';
            stop(tmr);
        end
    end

    % ====================================================================
    function OnExportarCSV(~, ~)
        % 02-sep-2026: exporta el CSV real para la talla/punto de montaje
        % EXACTOS que estan cargados en la app en este momento - usa
        % Generar_Trayectoria.m + Escribir_CSV_Simulador.m tal cual, sin
        % duplicar ninguna logica de calculo aqui.
        %
        % CAMBIO 03-sep-2026 (pedido explicito del usuario, tras leer el
        % paper de conferencia aceptado y encontrar una protesis real de
        % 42cm de eje, distinta de los ~0.38m que este proyecto tenia
        % documentados sin verificar, y saber que el usuario tiene AL MENOS
        % otro eje real de referencia ~0.21m): la distancia de montaje NO
        % tiene un valor por defecto para exportacion a hardware real -
        % depende de que protesis este montada en cada ensayo, y usar
        % cualquier numero como default silencioso arriesga exportar una
        % trayectoria para una protesis distinta de la que en realidad esta
        % en el banco. Se EXIGE un valor explicito (>0) en efMontaje antes
        % de exportar - si esta vacio/0, se rechaza el export con un
        % mensaje claro, sin generar ningun archivo. Esto es DISTINTO del
        % default de Generar_Trayectoria.m (rodilla anatomica), que sigue
        % siendo correcto para trayectorias de VALIDACION (Kuopio/Ferber/
        % Camargo) - ese default no se toca, esta funcion solo se vuelve
        % mas estricta para el camino de exportacion a hardware real.
        talla_m = efTalla.Value;
        talla_cm_id = round(talla_m * 100);
        d_montaje_cm = efMontaje.Value;

        if isempty(d_montaje_cm) || ~(isnumeric(d_montaje_cm) && isscalar(d_montaje_cm)) || d_montaje_cm <= 0
            uialert(fig, ['Ingresa la distancia de montaje (cm desde el tobillo) de LA PROTESIS ' ...
                'que esta realmente montada en el banco antes de exportar - no hay un valor por ' ...
                'defecto para hardware real (distintas protesis tienen distinto eje: p.ej. ~42cm o ' ...
                '~21cm segun el modelo, no se puede asumir uno).'], 'Falta distancia de montaje');
            return;
        end

        opciones_gt = struct('punto_seguimiento_m', d_montaje_cm / 100);
        id_sujeto = sprintf('talla%d_montaje%d', talla_cm_id, round(d_montaje_cm));

        try
            traj = Generar_Trayectoria(struct('talla_m', talla_m), opciones_gt);
        catch ME
            uialert(fig, ME.message, 'Error al generar trayectoria');
            return;
        end

        carpeta_salida = fullfile(fileparts(mfilename('fullpath')), 'EXPORT_RASPBERRY');
        if ~isfolder(carpeta_salida)
            mkdir(carpeta_salida);
        end

        try
            [archivo_apoyo, archivo_balanceo] = Escribir_CSV_Simulador(traj, id_sujeto, carpeta_salida);
        catch ME
            uialert(fig, ME.message, 'Error al escribir CSV');
            return;
        end

        uialert(fig, sprintf('Exportado:\n%s\n%s', archivo_apoyo, archivo_balanceo), ...
            'Exportacion completa', 'Icon', 'success');
    end

    % ====================================================================
    function OnTick(~, ~)
        pct_actual = pct_actual + PASO_TICK;
        if pct_actual > 100
            pct_actual = pct_actual - 100;
        end
        sldPct.Value = pct_actual;
        ActualizarCuadro();
    end

    % ====================================================================
    function OnCerrar(~, ~)
        if ~isempty(tmr) && isvalid(tmr)
            stop(tmr);
            delete(tmr);
        end
        delete(fig);
    end

end
