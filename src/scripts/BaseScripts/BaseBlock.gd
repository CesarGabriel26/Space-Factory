extends StaticBody2D
class_name BaseBlock

@onready var ExplosionEffect = preload("res://src/resources/effects/ExplosionEffect.tscn")

enum types {
	Starter = 0,
	Process,
	Reciver,
	Filter,
	Energy,
	Generator
}

@export_category("properties")
## Tipo do bloco
@export var Type : types = types.Reciver

## Vida total do bloco
@export var life = 10

## Resistência a ser congelado (valores mais altos indicam maior resistência)
@export var cold_resistence = 1

## A taxa de mudança para o azul
@export var freeze_rate = 0.1

## Resistência a explosões (valores mais altos indicam maior resistência)
@export var explosion_resistence = 1

## Resistencia a pegar fogo (valores mais altos indicam maior resistência)
@export var heat_resistence = 1

## Chance de pegar fogo (valores mais altos indicam maior probabilidade)
@export var flammability = 0.1

## Velocidade de queima (quanto tempo leva para queimar completamente)
@export var burn_rate = 5.0

## Durabilidade do bloco (afeta sua integridade ao longo do tempo)
@export var durability = 100

## Efeito ao ambiente (pode ser usado para alterar atributos como poluição)
@export var environmental_impact = 0.1

## Chance de gerar escória (ou outro resíduo) quando destruído
@export var slag_yield = 0.05

@export_subgroup("nodes")
@export var colisionShape : CollisionShape2D = null
@export var tierColor : Polygon2D = null
@export var Model : Node2D = null

var data = {}
var preview = false
var active = false

## Reduz a vida do bloco baseado em um dano especificado
func take_damage(amount: float):
	life -= amount
	if life <= 0:
		explode()

## Simula a explosão do bloco
func explode():
	# Instancia a cena de explosão
	var explosion_instance = ExplosionEffect.instantiate()
	get_parent().add_child(explosion_instance)
	
	# Posiciona a explosão na mesma posição do bloco
	explosion_instance.position = global_position
	explosion_instance.explode()
	# Adiciona outras lógicas como causar dano a blocos vizinhos, etc.
	
	# Remove o bloco após a explosão
	queue_free()

## Verifica se o bloco deve pegar fogo
func check_ignite(heat_level: float):
	if heat_level > heat_resistence and randf() < flammability:
		ignite()

## Simula o bloco pegando fogo
func ignite():
	# Código para aplicar efeitos visuais e de dano ao bloco
	while life > 0:
		take_damage(burn_rate)
		await get_tree().create_timer(1.0).timeout # Espera 1 segundo entre cada "queima"
	queue_free()

## Reage a baixas temperaturas
func freeze():
	var current_modulate = self_modulate
	
	# Aumenta a tonalidade azul com base no nível de congelamento
	while current_modulate.b < 1.0:  # Limite máximo para o azul é 1.0
		current_modulate.b += freeze_rate
		self_modulate = current_modulate
		await get_tree().create_timer(1.0).timeout  # Espera 1 segundo entre cada aumento de azul
	
	# Pode adicionar efeitos colaterais como redução de durabilidade ou outras penalidades
	durability -= 5  # Exemplo de penalidade na durabilidade

func check_for_freeze(cold_level: float):
	if cold_level > cold_resistence:
		freeze()

## seta bloco como preview na build tool
func set_as_preview():
	if colisionShape:
		colisionShape.disabled = true
	preview = true
	
	if has_method("set_machine_as_preview"):
		call_deferred("set_machine_as_preview")
