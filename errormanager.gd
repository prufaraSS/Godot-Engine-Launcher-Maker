extends Node

var tracer setget set_tracer

signal tracer_added

func set_tracer(trace):
	tracer = trace
	emit_signal("tracer_added")

func error(text:String):
	if !tracer:
		yield(self,"tracer_added")
	tracer.add_message(text,true)

func warn(text:String):
	if !tracer:
		yield(self,"tracer_added")
	tracer.add_message(text,false)
