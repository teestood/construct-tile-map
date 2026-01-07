@tool
class_name BuildScheduler
extends Resource

@export var max_scan_per_tick: int = 32
@export var base_retry_delay_ticks: int = 10
@export var max_retry_delay_ticks: int = 120

var _cursor_idx: int = 0
var _tick: int = 0
var _cooldown_until: Dictionary = {} # Dictionary[Vector2i, int]
var _retry_heap: Array = [] # min-heap of [eligible_tick:int, Vector2i]
var _tmp_result: Dictionary = {"can_construct": false}

func reset() -> void:
	_cursor_idx = 0
	_tick = 0
	_cooldown_until.clear()
	_retry_heap.clear()

func on_progress_cells_changed(size: int) -> void:
	if size <= 0:
		_cursor_idx = 0
	else:
		_cursor_idx = clampi(_cursor_idx, 0, size - 1)

func on_nutrient_changed(_key: StringName, _amount: float) -> void:
	_cooldown_until.clear()
	_retry_heap.clear()

## 次の建設対象を選ぶ。見つかれば {can_construct=true, coords=Vector2i}
func get_progress(plan: ConstructPlan) -> Dictionary:
	_tick += 1
	_release_cooldowns()

	_tmp_result.clear()
	_tmp_result["can_construct"] = false

	var cells := plan.progress_cells
	if cells.is_empty():
		return _tmp_result

	var n := cells.size()
	var scanned := 0
	var limit := min(max_scan_per_tick, n)

	while scanned < limit:
		var idx := (_cursor_idx + scanned) % n
		var coords: Vector2i = cells[idx]

		if plan.is_built_tile(coords):
			scanned += 1
			continue

		var until_tick := _cooldown_until.get(coords, -1)
		if until_tick > _tick:
			scanned += 1
			continue

		if plan.can_construct_at(coords):
			_cursor_idx = idx
			_tmp_result["can_construct"] = true
			_tmp_result["coords"] = coords
			return _tmp_result

		var delay := _calc_retry_delay_ticks(plan, coords)
		_set_cooldown(coords, _tick + delay)
		scanned += 1

	_cursor_idx = (_cursor_idx + scanned) % n
	return _tmp_result

func _calc_retry_delay_ticks(plan: ConstructPlan, coords: Vector2i) -> int:
	var td := plan.get_cell_tile_data(coords)
	if td == null:
		return base_retry_delay_ticks
	var soil := td.get_custom_data("Soil") as Soil
	if soil == null or soil.cost == null:
		return base_retry_delay_ticks

	var max_ratio := 0.0
	for nut in soil.cost.get_nutrients():
		var key: StringName = nut.stats.name
		var need: float = max(nut.amount, 0.0)
		if need <= 0.0:
			continue
		var have := 0.0
		var cur := plan.ground.storage.get_nutrient(key) if plan.ground != null and plan.ground.storage != null else null
		if cur != null:
			have = max(cur.amount, 0.0)
		var deficit: float = max(need - have, 0.0)
		var ratio := deficit / need
		if ratio > max_ratio:
			max_ratio = ratio

	var delay := int(round(base_retry_delay_ticks + (max_retry_delay_ticks - base_retry_delay_ticks) * max_ratio))
	return clampi(delay, base_retry_delay_ticks, max_retry_delay_ticks)

func _set_cooldown(coords: Vector2i, eligible_tick: int) -> void:
	_cooldown_until[coords] = eligible_tick
	_heap_push([eligible_tick, coords])

func _release_cooldowns() -> void:
	while _retry_heap.size() > 0:
		var top = _heap_peek()
		var eligible_tick: int = top[0]
		if eligible_tick > _tick:
			break
		var item = _heap_pop()
		var coords: Vector2i = item[1]
		if _cooldown_until.get(coords, -1) == eligible_tick:
			_cooldown_until.erase(coords)

func _heap_push(pair: Array) -> void:
	_retry_heap.append(pair)
	var i := _retry_heap.size() - 1
	while i > 0:
		var p := (i - 1) >> 1
		if _retry_heap[p][0] <= _retry_heap[i][0]:
			break
		var tmp = _retry_heap[p]
		_retry_heap[p] = _retry_heap[i]
		_retry_heap[i] = tmp
		i = p

func _heap_peek():
	return _retry_heap[0]

func _heap_pop():
	var last = _retry_heap.pop_back()
	if _retry_heap.is_empty():
		return last
	var ret = _retry_heap[0]
	_retry_heap[0] = last
	var i := 0
	while true:
		var l := i * 2 + 1
		var r := l + 1
		var smallest := i
		if l < _retry_heap.size() and _retry_heap[l][0] < _retry_heap[smallest][0]:
			smallest = l
		if r < _retry_heap.size() and _retry_heap[r][0] < _retry_heap[smallest][0]:
			smallest = r
		if smallest == i:
			break
		var tmp = _retry_heap[i]
		_retry_heap[i] = _retry_heap[smallest]
		_retry_heap[smallest] = tmp
		i = smallest
	return ret
