extends CanvasModulate

enum TimePhase { DAY, SUNSET, NIGHT, SUNRISE }

@export var gradient : GradientTexture1D
@export var paused = false

var day_duration : float = 20 #120.0  # Duração de um dia em segundos
var last_phase  : TimePhase = TimePhase.DAY
var current_phase : TimePhase = TimePhase.DAY
var time : float = 0.0

# Definindo os tempos de início e término para cada fase do ciclo
const phase_times = {
	TimePhase.DAY: { "start": 0.0, "end": 0.25 },
	TimePhase.SUNSET: { "start": 0.25, "end": 0.375 },
	TimePhase.NIGHT: { "start": 0.375, "end": 0.625 },
	TimePhase.SUNRISE: { "start": 0.625, "end": 0.75 },
}
const phase_names = {
	TimePhase.DAY: "DAY",
	TimePhase.SUNSET: "SUNSET",
	TimePhase.NIGHT: "NIGHT",
	TimePhase.SUNRISE: "SUNRISE",
}

func _ready():
	update_time_phase()

func _process(delta):
	visible = !paused
	if paused:
		return
	
	time += delta / day_duration
	if time > 1.0:
		time -= 1.0  # Reinicia o ciclo quando chega ao final
	
	var value = (sin(time * PI - PI / 2) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)
	
	# Calcular nível de luminosidade baseado no tempo
	MainGlobal.light_level = calculate_light_level(time)
	
	update_time_phase()

func update_time_phase():
	for phase in TimePhase.values():
		var start_time = phase_times[phase]["start"]
		var end_time = phase_times[phase]["end"]
		if time >= start_time and time < end_time:
			current_phase = phase
			break
	
	if last_phase != current_phase:
		if last_phase == TimePhase.SUNRISE and current_phase == TimePhase.DAY:
			MainGlobal.calculate_pollution()
		
		last_phase = current_phase

func calculate_light_level(time: float) -> float:
	# Definir o nível de luminosidade baseado na fase do tempo
	if current_phase == TimePhase.DAY:
		return 1.0  # Luminosidade máxima durante o dia
	elif current_phase == TimePhase.SUNSET:
		return lerp(1.0, 0.2, (time - phase_times[TimePhase.SUNSET]["start"]) / (phase_times[TimePhase.SUNSET]["end"] - phase_times[TimePhase.SUNSET]["start"]))
	elif current_phase == TimePhase.NIGHT:
		return 0.1  # Luminosidade mínima durante a noite
	elif current_phase == TimePhase.SUNRISE:
		return lerp(0.1, 1.0, (time - phase_times[TimePhase.SUNRISE]["start"]) / (phase_times[TimePhase.SUNRISE]["end"] - phase_times[TimePhase.SUNRISE]["start"]))
	return 1.0
