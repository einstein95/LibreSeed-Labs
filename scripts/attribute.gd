class_name Attribute extends RefCounted

signal changed

var multiplier: float = 1
var exponent: float = 1
var raw: float


func _init(d: float) -> void :
    raw = d


func add(a: float, m: float, e: float = 0, e_count: float = 0) -> void :
    raw += a * (1.0 + (m / multiplier)) * multiplier * exponent
    multiplier += m
    if e > 0:
        var exp: float = pow(e, e_count)
        raw *= exp
        exponent *= exp
    changed.emit()
