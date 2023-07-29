extends Node

func bar():
	return OK


func foo() -> Error:
	return await bar()
