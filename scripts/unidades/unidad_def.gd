## Datos de un tipo de unidad. Cada tipo tiene su archivo en data/unidades/.
class_name UnidadDef
extends Resource

enum Movimiento { A_PIE, RUEDAS, ORUGAS, VUELO }

@export var id: String = ""
@export var nombre: String = ""
## Letra que se ve en el icono al alejar la cámara.
@export var letra: String = ""
@export var movimiento: Movimiento = Movimiento.A_PIE
@export_group("GDD 6.2")
@export var coste: int = 0
@export var mg: int = 1
@export_group("GDD 13.3")
@export var vida: float = 100.0
## Metros por segundo.
@export var velocidad: float = 4.0
## Alcance del arma principal, en metros.
@export var alcance: float = 150.0
@export_group("GDD 13.5")
## Metros que ve la unidad.
@export var vision: float = 250.0
@export_group("Forma")
## Radio que ocupa, en metros.
@export var radio: float = 0.5
@export var altura: float = 1.8
