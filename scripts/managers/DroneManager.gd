extends Node

signal load_new_build

var drones = []
var builds_for_drones = []

func _process(delta):
	put_drones_to_work()

# Adiciona um drone à lista
func register_drone(drone):
	if not drones.has(drone):
		drones.append(drone)

# Remove um drone da lista
func unregister_drone(drone):
	drones.erase(drone)

func put_drones_to_work():
	for build in builds_for_drones:
		var build_assigned = build[1]
		var bul = build[0]
		
		bul.name = str(builds_for_drones.find(build))
		
		for drone : baseDrone in drones:
			if drone is BuilderDrone:
				if !drone.busy:
					# Verifica se outro drone já foi atribuído a essa construção
					if build_assigned:
						break
					drone.busy = true
					drone.target = bul
					drone.build(bul)
					builds_for_drones[builds_for_drones.find(build)][1] = true
					break
				
				elif drone.target == bul:
					builds_for_drones[builds_for_drones.find(build)][1] = true
					break
