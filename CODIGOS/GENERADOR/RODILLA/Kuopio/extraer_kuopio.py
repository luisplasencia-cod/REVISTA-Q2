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

    filas = []
    for fno, points, analog in r.read_frames():
        ok = all(points[idx[p], 3] >= 0 for p in PUNTOS.values())
        if not ok:
            continue
        cad = points[idx[PUNTOS['cadera']], :3]
        rod = points[idx[PUNTOS['rodilla']], :3]
        tob = points[idx[PUNTOS['tobillo']], :3]
        filas.append([fno, fno / fr, cad[1], cad[2], rod[1], rod[2], tob[1], tob[2]])

    if len(filas) < 50:
        raise ValueError(f'{ruta_c3d}: muy pocos frames validos ({len(filas)})')

    with open(out_csv, 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['frame', 't_s', 'cadera_y_mm', 'cadera_z_mm', 'rodilla_y_mm', 'rodilla_z_mm', 'tobillo_y_mm', 'tobillo_z_mm'])
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
    IDS = [1, 4, 7, 10, 13, 19, 22, 25, 28, 31, 37, 40, 43, 46, 49]
    main(IDS)
