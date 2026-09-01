"""
extraer_kuopio.py -- 25-ago-2026

Extractor "tonto" (sin decisiones de biomecanica) de trayectorias 3D reales
de cadera/rodilla/tobillo del Kuopio Gait Dataset (Lavikainen et al. 2024,
Data Brief 56:110841, DOI 10.5281/zenodo.10559504, CC-BY-4.0), para
alimentar Cargar_Kuopio2024_Core.m (MATLAB) - misma division de trabajo que
Cargar_Ferber2024_Core.m: Python solo extrae numeros crudos a CSV, TODA la
logica de deteccion de eventos/ciclos/marco de referencia vive en MATLAB,
donde el resto del proyecto vive y se revisa.

Por que este dataset: es la unica base con marcha OVERGROUND real (no
cinta, a diferencia de Ferber - confirmado en el paper, 3 plataformas de
fuerza empotradas en el piso) + antropometria real por sujeto (sexo,
talla, masa, largo de muslo/tibia MEDIDOS, no estimados) - necesaria para
validar el termino de avance (velocidad x tiempo) que Ferber no pudo
probar por ser cinta (ver Evaluar_vs_Ferber_Avance.m, cabecera).

Convencion de ejes verificada empiricamente (25-ago-2026, graficando
X/Y/Z crudos de un trial real, ver Kuopio/_scratch/axes_check.png):
  Y = direccion de avance (anteroposterior) - rango ~5.5m en un trial,
      confirma que SI hay traslacion neta real (a diferencia de Ferber)
  Z = vertical (hip~900mm, rodilla~450mm, tobillo 0-220mm - alturas
      anatomicas plausibles)
  X = mediolateral (rango pequeno, ~0-520mm) - NO se usa aqui
Los puntos ya son centros articulares FUNCIONALES calculados por Vicon
Nexus (SCoRE/SARA), no marcadores de piel crudos:
  cadera  = 'Pelvis_RFemur_score'
  rodilla = 'RKnee'
  tobillo = 'RTibia_RFoot_score'
Frames invalidos (oclusion) se identifican con el residual del c3d
(columna 4, valor -1 = invalido, estandar del formato) - se descartan.

Requiere: pip install remotezip c3d numpy openpyxl (ya instalados en esta
sesion, 25-ago-2026).

--- 28-ago-2026: agregadas las 5 plataformas de fuerza reales ---
Confirmado por sondeo directo de un trial real (01/r_comf_01): el c3d trae
36 canales analogicos a 1000Hz (10 muestras por cada frame de puntos a
100Hz) - 30 son Force.Fx/Fy/Fz + Moment.Mx/My/Mz x 5 plataformas, el resto
son sincronismo/EEG (no se extraen). Fz maximo observado en ese trial:
~820-875N en 3 de las 5 plataformas (plausible, orden de magnitud de peso
corporal) - confirma que son las plataformas donde el sujeto piso, no ruido.
Sigue la misma division de trabajo: aqui solo se promedian las 10 muestras
analogicas de cada frame de punto (downsampling numerico simple, sin
decidir que plataforma esta activa ni calcular centro de presion - esa
logica de deteccion de apoyo queda para MATLAB, igual que el resto).
"""
import os
import csv
import openpyxl
import numpy as np
import c3d
from remotezip import RemoteZip

CARPETA = os.path.dirname(os.path.abspath(__file__))
DIR_RAW = os.path.join(CARPETA, 'raw')
URL_META = 'https://zenodo.org/records/10559504/files/info_participants.xlsx?download=1'
URLS_ZIP = {
    range(1, 18):  'https://zenodo.org/records/10559504/files/measurement_data_1_to_17.zip?download=1',
    range(18, 35): 'https://zenodo.org/records/10559504/files/measurement_data_18_to_34.zip?download=1',
    range(35, 52): 'https://zenodo.org/records/10559504/files/measurement_data_35_to_51.zip?download=1',
}
PUNTOS = {'cadera': 'Pelvis_RFemur_score', 'rodilla': 'RKnee', 'tobillo': 'RTibia_RFoot_score'}
N_PLATAFORMAS = 5
CANALES_FUERZA = [f'{grupo}.{prefijo}{eje}{k}' for k in range(1, N_PLATAFORMAS + 1)
                   for grupo, prefijo in (('Force', 'F'), ('Moment', 'M')) for eje in 'xyz']


def url_zip_de(sub_id):
    for rango, url in URLS_ZIP.items():
        if sub_id in rango:
            return url
    raise ValueError(f'sub_id {sub_id} fuera de rango 1-51')


def descargar_meta():
    import requests
    dest = os.path.join(DIR_RAW, 'info_participants.xlsx')
    if not os.path.isfile(dest):
        os.makedirs(DIR_RAW, exist_ok=True)
        r = requests.get(URL_META, timeout=60)
        r.raise_for_status()
        with open(dest, 'wb') as f:
            f.write(r.content)
    wb = openpyxl.load_workbook(dest, data_only=True)
    ws = wb.worksheets[0]
    filas = list(ws.iter_rows(min_row=1, values_only=True))
    header, filas = filas[0], filas[1:]
    idx = {h: i for i, h in enumerate(header)}
    meta = {}
    for f in filas:
        sid = int(f[idx['ID']])
        invalid = f[idx['Invalid_trials']]
        invalid_set = set(x.strip() for x in invalid.split(',')) if invalid else set()
        meta[sid] = dict(
            sexo=f[idx['Gender']], talla_cm=f[idx['Height']], masa_kg=f[idx['Mass']],
            muslo_mm=f[idx['Right_thigh_length']], tibia_mm=f[idx['Right_shank_length']],
            invalid=invalid_set,
        )
    return meta


def escribir_meta_csv(meta, ids_usados):
    dest = os.path.join(DIR_RAW, 'subjects_meta.csv')
    with open(dest, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['sub_id', 'sexo', 'talla_cm', 'masa_kg', 'muslo_mm', 'tibia_mm'])
        for sid in ids_usados:
            m = meta[sid]
            w.writerow([sid, m['sexo'], m['talla_cm'], m['masa_kg'], m['muslo_mm'], m['tibia_mm']])
    print('Guardado', dest)


def elegir_trials_validos(sub_id, meta, n_trials=3):
    invalid = meta[sub_id]['invalid']
    candidatos = [f'{lado}_comf_{i:02d}' for lado in ('l', 'r') for i in range(1, 11)]
    validos = [c for c in candidatos if c not in invalid]
    return validos[:n_trials]


def extraer_trial(zf, ruta_c3d, out_csv):
    with zf.open(ruta_c3d) as fh:
        raw = fh.read()
    import io
    r = c3d.Reader(io.BytesIO(raw))
    labels = [l.strip() for l in r.point_labels]
    idx = {lbl: i for i, lbl in enumerate(labels)}
    for nombre_punto in PUNTOS.values():
        if nombre_punto not in idx:
            raise ValueError(f'{ruta_c3d}: falta el punto {nombre_punto}')
    fr = r.point_rate

    labels_analog = [l.strip() for l in r.analog_labels]
    idx_a = {lbl: i for i, lbl in enumerate(labels_analog)}
    tiene_fuerza = all(c in idx_a for c in CANALES_FUERZA)
    if tiene_fuerza:
        idx_fuerza = [idx_a[c] for c in CANALES_FUERZA]

    filas = []
    for fno, points, analog in r.read_frames():
        ok = all(points[idx[p], 3] >= 0 for p in PUNTOS.values())
        if not ok:
            continue
        cad = points[idx[PUNTOS['cadera']], :3]
        rod = points[idx[PUNTOS['rodilla']], :3]
        tob = points[idx[PUNTOS['tobillo']], :3]
        fila = [fno, fno / fr, cad[1], cad[2], rod[1], rod[2], tob[1], tob[2]]
        if tiene_fuerza:
            # promedio de las 10 muestras analogicas (1000Hz) dentro de este frame de puntos (100Hz)
            fila += list(np.mean(analog[idx_fuerza, :], axis=1))
        filas.append(fila)

    if len(filas) < 50:
        raise ValueError(f'{ruta_c3d}: muy pocos frames validos ({len(filas)})')

    header = ['frame', 't_s', 'cadera_y_mm', 'cadera_z_mm', 'rodilla_y_mm', 'rodilla_z_mm', 'tobillo_y_mm', 'tobillo_z_mm']
    if tiene_fuerza:
        header += [c.replace('.', '_') + '_N_Nm' for c in CANALES_FUERZA]
    else:
        print(f'  AVISO {ruta_c3d}: sin canales de fuerza completos, CSV sin columnas de plataforma')

    with open(out_csv, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(filas)
    return len(filas), fr


def main(ids):
    os.makedirs(DIR_RAW, exist_ok=True)
    meta = descargar_meta()
    escribir_meta_csv(meta, ids)

    por_zip = {}
    for sid in ids:
        por_zip.setdefault(url_zip_de(sid), []).append(sid)

    resumen = []
    for url, sids in por_zip.items():
        print(f'--- Abriendo {url} para sujetos {sids} ---')
        with RemoteZip(url) as zf:
            nombres = set(zf.namelist())
            for sid in sids:
                trials = elegir_trials_validos(sid, meta)
                for trial in trials:
                    ruta = f'{sid:02d}/mocap/{trial}.c3d'
                    if ruta not in nombres:
                        print(f'  SALTADO (no existe): {ruta}')
                        continue
                    out_csv = os.path.join(DIR_RAW, f'{sid:02d}_{trial}.csv')
                    try:
                        n, fr = extraer_trial(zf, ruta, out_csv)
                        print(f'  OK {ruta} -> {n} frames validos @ {fr}Hz')
                        resumen.append((sid, trial, n, fr))
                    except Exception as e:
                        print(f'  FALLO {ruta}: {e}')
    print(f'\n=== Listo: {len(resumen)} trials extraidos en {DIR_RAW} ===')


if __name__ == '__main__':
    # AMPLIADO 28-ago-2026 (pedido del usuario: "vale la validacion con mas
    # sujetos de Kuopio si tiene datos de fuerza") - de 15 a los 51 sujetos
    # totales del dataset, para dar mas potencia estadistica a Evaluar_GRF_
    # vs_Kuopio.m (hoy solo 34 pasos reales validos de 13 sujetos utiles).
    IDS = list(range(1, 52))
    main(IDS)
