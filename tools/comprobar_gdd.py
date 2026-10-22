"""Compara los números del GDD con los de data/ (partida.tres y unidades/*.tres).

Uso: python3 tools/comprobar_gdd.py
Sale con código 1 si hay diferencias. Lo usa la skill balance-sincronizar.

Tablas que revisa: 3.2 (hot zone), 6.2 (coste y MG), 13.3 (vida, velocidad y
alcance del arma de inicio), 13.5 (visión) y 13.6 (parámetros de la partida).
"""
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parent.parent
GDD = (RAIZ / "docs" / "GDD.md").read_text(encoding="utf-8")

# Nombre de la clase en las tablas del GDD → archivo de data/unidades
CLASES = {
    "Conductor / Piloto": "conductor",
    "Asalto": "asalto",
    "Médico": "medico",
    "Ingeniero": "ingeniero",
    "Apoyo": "apoyo",
    "Francotirador": "francotirador",
}


def numero(texto):
    """Primer número de un texto: punto para los miles y coma para los decimales."""
    m = re.search(r"\d[\d.]*(,\d+)?", texto)
    if not m:
        return None
    return float(m.group(0).replace(".", "").replace(",", "."))


def seccion(titulo):
    """Texto de una sección del GDD (desde su título hasta el siguiente)."""
    m = re.search(r"^#+ " + re.escape(titulo) + r".*?$(.*?)(?=^#+ )", GDD, re.M | re.S)
    return m.group(1) if m else ""


def celdas(texto, primera):
    """Celdas de la primera fila de una tabla que empieza por `primera`."""
    for linea in texto.splitlines():
        partes = [c.strip() for c in linea.strip().strip("|").split("|")]
        if partes and partes[0] == primera:
            return partes
    return None


def leer_tres(ruta):
    datos = {}
    for linea in ruta.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^(\w+) = (.+)$", linea)
        if m:
            valor = m.group(2).strip('"')
            try:
                datos[m.group(1)] = float(valor)
            except ValueError:
                datos[m.group(1)] = valor
    return datos


def comprobaciones():
    """Lista de (descripción, valor del GDD, valor en data/, de dónde sale)."""
    res = []
    partida = leer_tres(RAIZ / "data" / "partida.tres")
    s136 = seccion("13.6")
    s32 = seccion("3.2")

    def p(desc, texto, sacar, campo, factor=1):
        esperado = sacar(texto) if texto else None
        actual = partida.get(campo)
        res.append((desc, esperado, actual * factor if actual is not None else None, "partida." + campo))

    fila = lambda nombre, s=s136: (celdas(s, nombre) or [None, None])[1]
    despues = lambda corte: (lambda t: numero(t.split(corte, 1)[1]) if corte in t else None)
    p("Dinero inicial", fila("Dinero inicial"), numero, "dinero_inicial")
    p("Límite de unidades", fila("Límite de unidades"), numero, "limite_unidades")
    p("Dinero por baja (%)", fila("Dinero por baja"), numero, "porcentaje_por_baja")
    p("Dinero por baja en hot zone (%)", fila("Dinero por baja"), despues("("), "porcentaje_por_baja_hot_zone")
    p("Pelotón gratis: umbral", fila("Pelotón gratis"), despues("menos de"), "peloton_gratis_umbral")
    p("Pelotón gratis: espera (s)", fila("Pelotón gratis"), despues("cada"), "peloton_gratis_espera")
    p("Puntos para ganar", fila("Puntos para ganar"), numero, "puntos_para_ganar")
    p("Segundos por punto", fila("Intervalo de puntuación"), despues("cada"), "segundos_por_punto")
    p("Tiempo herido (s)", fila("Tiempo en el suelo herido"), numero, "tiempo_herido")
    p("Tiempo herido con torniquete (s)", fila("Tiempo en el suelo herido"), despues("("), "tiempo_herido_torniquete")
    p("Tiempo de reanimación (s)", fila("Tiempo de reanimación"), numero, "tiempo_reanimacion")
    p("FOB máximas", fila("FOB máximas"), numero, "fob_maximas")
    p("Hot zone: cambio (min)", fila("Cambio de la hot zone"), numero, "hot_zone_cambio_minutos")
    p("Hot zone: aviso (s)", fila("Cambio de la hot zone"), despues("con"), "hot_zone_aviso")
    p("Despliegue de soldados (s)", fila("Despliegue de soldados"), numero, "despliegue_soldados")
    p("Bajas para el helicóptero de combate", fila("Helicóptero de combate"), despues("con"), "bajas_helicoptero_combate")
    p("Hot zone: diámetro (m)", fila("Forma y tamaño", s32), despues("de"), "hot_zone_diametro")
    p("Hot zone: distancia a FOB (m)", fila("Dónde aparece", s32), despues("menos de"), "hot_zone_distancia_fob")

    s62 = seccion("6.2")
    s133 = seccion("13.3")
    s135 = seccion("13.5")
    for nombre, archivo in CLASES.items():
        d = leer_tres(RAIZ / "data" / "unidades" / (archivo + ".tres"))

        def u(desc, texto, campo, sacar=numero):
            esperado = sacar(texto) if texto else None
            res.append((f"{nombre}: {desc}", esperado, d.get(campo), f"{archivo}.{campo}"))

        c62 = celdas(s62, nombre) or []
        c133 = celdas(s133, nombre) or []  # primera tabla: vida y velocidad
        arma = None
        for linea in s133.splitlines():  # segunda tabla: la primera fila de la clase es el arma de inicio
            partes = [x.strip() for x in linea.strip().strip("|").split("|")]
            if len(partes) == 9 and partes[0] == nombre:
                arma = partes
                break
        vision = celdas(s135, "Francotirador" if archivo == "francotirador" else "Soldados")
        u("coste", c62[1] if len(c62) > 1 else None, "coste")
        u("MG", c62[2] if len(c62) > 2 else None, "mg")
        u("vida", c133[1] if len(c133) > 1 else None, "vida")
        u("velocidad", c133[2] if len(c133) > 2 else None, "velocidad")
        u("alcance", arma[8] if arma else None, "alcance")
        u("visión", vision[1] if vision else None, "vision")
    return res


def main():
    diferencias = 0
    print("| Parámetro | GDD | data/ | Estado |\n| --- | --- | --- | --- |")
    for desc, esperado, actual, origen in comprobaciones():
        ok = esperado is not None and actual is not None and abs(esperado - actual) < 1e-6
        diferencias += 0 if ok else 1
        print(f"| {desc} | {esperado} | {actual} ({origen}) | {'OK' if ok else 'DISTINTO'} |")
    print(f"\n{diferencias} diferencias")
    return 1 if diferencias else 0


if __name__ == "__main__":
    sys.exit(main())
