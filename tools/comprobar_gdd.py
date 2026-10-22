"""Compara los parámetros generales del GDD (13.6 y 3.2) con los del código.

Uso: python3 tools/comprobar_gdd.py
Sale con código 1 si hay diferencias. Lo usa la skill balance-sincronizar.
"""
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parent.parent
GDD = (RAIZ / "docs" / "GDD.md").read_text(encoding="utf-8")
CODIGO = (RAIZ / "scripts" / "game_data.gd").read_text(encoding="utf-8")


def numero(texto):
    """Primer número de un texto, con el punto como separador de miles."""
    m = re.search(r"\d[\d.]*", texto)
    return float(m.group(0).replace(".", "")) if m else None


def fila_gdd(nombre):
    m = re.search(r"^\| " + re.escape(nombre) + r" \| (.+?) \|$", GDD, re.M)
    return m.group(1) if m else None


def constante(nombre):
    m = re.search(r"^const " + nombre + r" := ([\d.]+)", CODIGO, re.M)
    return float(m.group(1)) if m else None


# (descripción, fila del GDD, cómo sacar el número, constante del código, factor código→GDD)
COMPROBACIONES = [
    ("Dinero inicial", "Dinero inicial", numero, "START_MONEY", 1),
    ("Límite de unidades", "Límite de unidades", numero, "POP_CAP", 1),
    ("Puntos para ganar", "Puntos para ganar", numero, "SCORE_TO_WIN", 1),
    ("Segundos por punto", "Intervalo de puntuación", lambda t: numero(t.split("cada")[1]), "SCORE_INTERVAL", 1),
    ("Pelotón gratis: umbral de dinero", "Pelotón gratis", lambda t: numero(t.split("menos de")[1]), "FREE_SQUAD_THRESHOLD", 1),
    ("Pelotón gratis: espera (s)", "Pelotón gratis", lambda t: numero(t.split("cada")[1]), "FREE_SQUAD_COOLDOWN", 1),
    ("FOB máximas", "FOB máximas", numero, "FOB_MAX", 1),
    ("Hot zone: cambio (min)", "Cambio de la hot zone", lambda t: numero(t.split("Cada")[1]), "HOT_ZONE_MOVE_TIME", 1 / 60),
    ("Hot zone: aviso (s)", "Aviso", numero, "HOT_ZONE_WARNING", 1),
    ("Dinero por baja (%)", "Dinero por baja", numero, "KILL_REWARD", 100),
]


def main():
    diferencias = 0
    print("| Parámetro | GDD | Código | Estado |\n| --- | --- | --- | --- |")
    for desc, fila, sacar, const, factor in COMPROBACIONES:
        texto = fila_gdd(fila)
        esperado = sacar(texto) if texto else None
        actual = constante(const)
        actual = actual * factor if actual is not None else None
        ok = esperado is not None and actual is not None and abs(esperado - actual) < 1e-6
        diferencias += 0 if ok else 1
        print(f"| {desc} | {esperado} | {actual} ({const}) | {'OK' if ok else 'DISTINTO'} |")
    print(f"\n{diferencias} diferencias")
    return 1 if diferencias else 0


if __name__ == "__main__":
    sys.exit(main())
