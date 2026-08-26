extends CanvasLayer

## On-screen overview of a character's vital stats: health, stamina and power.
##
## Root is a [CanvasLayer] so the panel stays fixed to the screen regardless of
## the [Camera2D] -- a plain Control placed in the world would scroll with it.
##
## Assign [member character] in the inspector to the [Konqui2D] node this panel
## should track. The bars then update automatically via each [Stat]'s
## [signal Stat.changed] signal -- no per-frame polling.
class_name CharacterInformation

## The character whose stats are displayed. Assign this in the editor.
@export var character: Konqui2D

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var power_bar: ProgressBar = %PowerBar

func _ready() -> void:
	if character == null:
		push_warning("CharacterInformation has no 'character' assigned; nothing to display.")
		return

	_track(character.health, health_bar)
	_track(character.stamina, stamina_bar)
	_track(character.power, power_bar)

## Seed a bar with the stat's current values and keep it in sync from then on.
func _track(stat: Stat, bar: ProgressBar) -> void:
	bar.max_value = stat.maximum
	bar.value = stat.current
	stat.changed.connect(func(current: float, maximum: float) -> void:
		bar.max_value = maximum
		bar.value = current)
