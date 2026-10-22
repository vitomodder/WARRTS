---
name: balance-sincronizar
description: Comprobar que los números del código de WARRTS coinciden con las tablas del GDD y listar las diferencias.
---

1. Ejecuta `python3 tools/comprobar_gdd.py`. Muestra una tabla GDD frente a código y sale con código 1 si hay diferencias.
2. Si una diferencia es un error del código, corrígelo en `data/`.
3. Si el GDD ha cambiado o la diferencia es intencionada (por ejemplo, un ajuste que pidió Vito al probar), no toques el código sin preguntar: apúntalo en «Diferencias con el GDD» del informe de fase.
4. Cuando se añadan tablas nuevas a `data/`, amplía `COMPROBACIONES` en `tools/comprobar_gdd.py` para cubrirlas.
