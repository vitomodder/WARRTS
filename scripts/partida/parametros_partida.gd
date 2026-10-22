## Parámetros generales de la partida (GDD 13.6, 3.2). Los valores viven en data/partida.tres.
class_name ParametrosPartida
extends Resource

@export_group("Partida (GDD 13.6)")
@export var dinero_inicial: int = 1000000
@export var limite_unidades: int = 100
@export var porcentaje_por_baja: int = 50
@export var porcentaje_por_baja_hot_zone: int = 75
@export var peloton_gratis_umbral: int = 20000
@export var peloton_gratis_espera: float = 90.0
@export var puntos_para_ganar: int = 100
@export var segundos_por_punto: float = 6.0
@export var tiempo_herido: float = 60.0
@export var tiempo_herido_torniquete: float = 90.0
@export var tiempo_reanimacion: float = 10.0
@export var fob_maximas: int = 3
@export var despliegue_soldados: float = 5.0
@export var bajas_helicoptero_combate: int = 40

@export_group("Hot zone (GDD 3.2)")
@export var hot_zone_cambio_minutos: float = 5.0
@export var hot_zone_aviso: float = 60.0
@export var hot_zone_diametro: float = 400.0
@export var hot_zone_distancia_fob: float = 800.0

@export_group("Simulación (ARQUITECTURA §3)")
## Segundos de juego por paso de simulación.
@export var paso: float = 0.1
## Tamaño de celda del índice espacial, en metros.
@export var celda_indice: float = 50.0
## Rutas nuevas que se calculan como máximo en cada paso.
@export var rutas_por_paso: int = 40
