extends Obstacle

class_name Puddle

signal died
signal large_reached
signal large_reversed

enum Stage {
	SMALL,
	MEDIUM,
	LARGE,
}

var stage_thresholds = {
	Stage.SMALL: PUDDLE_CAPACITY * 1/3,
	Stage.MEDIUM: PUDDLE_CAPACITY * 2/3,
	Stage.LARGE: PUDDLE_CAPACITY,
}

const SPREAD_AMOUNT = 120 # Number divisble by 3 then 4 then 2 and still a whole number, for spreading mechanic ease
const PUDDLE_CAPACITY = SPREAD_AMOUNT * 3 # 3 stages, so capacity should be 3x max spread amount 
const PUDDLE_SIZE = Vector2(32,32)

var puddle_amount = 0
var overflow = 0
var stage = Stage.SMALL
var can_spread = true

var is_dead = false
var assignees: Array[Worker]

# Store neighbor puddle states here
	   #[top]
#[left] [self] [right]
	  #[bottom]
var neighbor_puddles = {
	"top": {"puddle": null, "spawn_point": null},
	"bottom": {"puddle": null, "spawn_point": null},
	"right": {"puddle": null, "spawn_point": null},
	"left": {"puddle": null, "spawn_point": null},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level = get_tree().get_nodes_in_group("level").front() as Level
	spawned.connect(level._on_stat_entity_spawned.bind(self))
	died.connect(level._on_stat_entity_died.bind(self))
	if not Globals.boat:
		Globals.boat_ready.connect(_update_stage)
	elif puddle_amount > 0:
		_update_stage()
	
	_update_neighbor_spawn_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_stage():
	var old_stage = stage
	if puddle_amount <= 0:
		die()
	elif puddle_amount <= stage_thresholds[Stage.SMALL]:
		stage = Stage.SMALL
		$AnimatedSprite2D.play("small")
	elif puddle_amount <= stage_thresholds[Stage.MEDIUM]:
		stage = Stage.MEDIUM
		$AnimatedSprite2D.play("medium")
	else:
		stage = Stage.LARGE
		$AnimatedSprite2D.play("large")
		
		# Spread if the latest update is higher than puddle capacity
		overflow = puddle_amount - PUDDLE_CAPACITY
		if overflow > 0:
			puddle_amount = PUDDLE_CAPACITY
			spread(overflow, self)
	
	if old_stage != stage:
		if stage == Stage.LARGE:
			large_reached.emit()
		elif old_stage == Stage.LARGE:
			large_reversed.emit()

func increase_stage():
	puddle_amount += SPREAD_AMOUNT
	_update_stage()

func decrease_stage():
	puddle_amount -= SPREAD_AMOUNT
	_update_stage()

func die():
	remove_from_group("puddle")
	if stage == Stage.LARGE:
		large_reversed.emit()
	died.emit()
	is_dead = true
	_remove_assignees()
	queue_free()

# Override assignee and worker setters since we want multiple to be able to work on a puddle at a time
func set_assignee(new_assignee: Worker) -> bool:
	if not is_dead:
		assignees.append(new_assignee)
	return not is_dead

func set_worker(new_worker: Worker) -> bool:
	return not is_dead

# Attempt to spread in this pattern
	#[1]
#[4] [0] [2]
	#[3]
# Split spread amount to each 
func spread(amount: int, source: Puddle):
	if can_spread:
		if amount >= neighbor_puddles.size():
			if stage < Stage.LARGE:
				puddle_amount += amount
				_update_stage()
			else:
				_update_neighbor_puddles()
				for neighbor in neighbor_puddles.values():
					if neighbor["puddle"] and neighbor["puddle"] != source:
						neighbor["puddle"].spread(amount/neighbor_puddles.size(), self)
					else:
						neighbor["puddle"] = Globals.boat.spawn_puddle(neighbor["spawn_point"])

func spawn(spawn_point: Vector2, add_to_puddle: bool = false):
	var spawn_occupant = _spawn("puddle", spawn_point)
	if spawn_occupant == self:
		_update_neighbor_spawn_points()
		var effect_check_occupant = _check_spawn_space_occupied("cargo")
		if effect_check_occupant is Cargo:
			if global_position == effect_check_occupant.global_position:
				stage = Stage.LARGE
				spread(SPREAD_AMOUNT, self)
				queue_free()
				return null
			else:
				effect_check_occupant.add_threat(self)
		else:
			effect_check_occupant = _check_spawn_space_occupied("rowing_task")
			if effect_check_occupant is RowingTask:
				effect_check_occupant.add_threat(self)
		spread(SPREAD_AMOUNT, self)
		spawned.emit()
	elif add_to_puddle:
		if spawn_occupant is Puddle:
			spawn_occupant.increase_stage()
	_update_neighbor_puddles()
	
	return spawn_occupant
	
func _update_neighbor_spawn_points():
	neighbor_puddles["top"]["spawn_point"] = $NeighborSpawnPoints/Top.global_position
	neighbor_puddles["bottom"]["spawn_point"] = $NeighborSpawnPoints/Bottom.global_position
	neighbor_puddles["right"]["spawn_point"] = $NeighborSpawnPoints/Right.global_position
	neighbor_puddles["left"]["spawn_point"] = $NeighborSpawnPoints/Left.global_position

func _update_neighbor_puddles():
	for neighbor in neighbor_puddles.values():
		neighbor["puddle"] = null
	
	var puddles = get_tree().get_nodes_in_group("puddle")
	puddles.erase(self)
	
	for puddle in puddles:
		var puddle_polygon = puddle.get_self_polygon()
		if not Geometry2D.intersect_polygons(puddle_polygon, Utils.shift_polygon($NeighborSpawnPoints/Top/Polygon2D.polygon, $NeighborSpawnPoints/Top/Polygon2D.global_position)).is_empty():
			neighbor_puddles["top"]["puddle"] = puddle
		if not Geometry2D.intersect_polygons(puddle_polygon, Utils.shift_polygon($NeighborSpawnPoints/Bottom/Polygon2D.polygon, $NeighborSpawnPoints/Bottom/Polygon2D.global_position)).is_empty():
			neighbor_puddles["bottom"]["puddle"] = puddle
		if not Geometry2D.intersect_polygons(puddle_polygon, Utils.shift_polygon($NeighborSpawnPoints/Right/Polygon2D.polygon, $NeighborSpawnPoints/Right/Polygon2D.global_position)).is_empty():
			neighbor_puddles["right"]["puddle"] = puddle
		if not Geometry2D.intersect_polygons(puddle_polygon, Utils.shift_polygon($NeighborSpawnPoints/Left/Polygon2D.polygon, $NeighborSpawnPoints/Left/Polygon2D.global_position)).is_empty():
			neighbor_puddles["left"]["puddle"] = puddle

func _remove_assignees():
	for assignee in assignees:
		if assignee.current_assignment == self:
			assignee.set_assignment(null)
