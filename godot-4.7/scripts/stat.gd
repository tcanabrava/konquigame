extends RefCounted

## A single bounded gameplay statistic (health, stamina, ...).
##
## Holds a [member current] value clamped to [0, [member maximum]] and emits
## [signal changed] whenever it moves, so UI (e.g. CharacterInformation) can
## react without polling every frame.
class_name Stat

## Emitted whenever [member current] or [member maximum] changes.
signal changed(current: float, maximum: float)

var maximum: float = 100.0
var current: float = 100.0

## A negative [param p_current] means "start full".
func _init(p_maximum: float = 100.0, p_current: float = -1.0) -> void:
	maximum = maxf(p_maximum, 0.0)
	current = maximum if p_current < 0.0 else clampf(p_current, 0.0, maximum)

func set_current(value: float) -> void:
	var clamped := clampf(value, 0.0, maximum)
	if is_equal_approx(clamped, current):
		return
	current = clamped
	changed.emit(current, maximum)

## Add (or, with a negative amount, subtract) from the current value.
func change_by(amount: float) -> void:
	set_current(current + amount)

func set_maximum(value: float) -> void:
	maximum = maxf(value, 0.0)
	current = minf(current, maximum)
	changed.emit(current, maximum)

## Current value as a 0..1 fraction of the maximum.
func ratio() -> float:
	return current / maximum if maximum > 0.0 else 0.0

func is_empty() -> bool:
	return current <= 0.0

func is_full() -> bool:
	return current >= maximum
