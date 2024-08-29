extends CanvasModulate

enum TimePhase { DAY, SUNSET, NIGHT, SUNRISE }

@export var gradient : GradientTexture1D
@export var paused = false

var day_duration : float = (1200.0)  # Duração de um dia 1200.0 segundos
var last_phase  : TimePhase = TimePhase.DAY
var current_phase : TimePhase = TimePhase.DAY
var time : float = 0.0

var phase_times = {
	TimePhase.DAY: 0.0,
	TimePhase.SUNSET: 0.75,
	TimePhase.NIGHT: 0.25,
	TimePhase.SUNRISE: 0.55
}

func _ready():
	update_time_phase()

func _process(delta):
	visible = !paused
	if paused:
		return
	
	time += delta / day_duration
	if time > 1.0:
		time -= 1.0  # Reset do ciclo de dia
	
	var value = (sin(time * PI - PI / 2) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)
	
	update_time_phase()

func update_time_phase():
	if time >= phase_times[TimePhase.DAY] and time < phase_times[TimePhase.SUNSET]:
		current_phase = TimePhase.DAY
	elif time >= phase_times[TimePhase.SUNSET] and time < phase_times[TimePhase.NIGHT]:
		current_phase = TimePhase.SUNSET
	elif time >= phase_times[TimePhase.NIGHT] and time < phase_times[TimePhase.SUNRISE]:
		current_phase = TimePhase.NIGHT
	elif time >= phase_times[TimePhase.SUNRISE] or time < phase_times[TimePhase.DAY]:
		current_phase = TimePhase.SUNRISE
	
	if last_phase != current_phase:
		if last_phase == TimePhase.SUNRISE and current_phase == TimePhase.DAY:
			MainGlobal.calculate_pollution()
		
		last_phase = current_phase

