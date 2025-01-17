extends Resource
class_name ActionData

@export var id := 0

## Name of Action
@export var name : String

## Action icon in texture2D, displayed by [SlotUI]
@export var icon : Texture2D

@export var tooltip : String

## Action custom properties
@export var properties : Dictionary

## Action Categories (Use Bit Flags)
@export var categories : Array[ItemCategory]

## Id represents none Action (Used in networked scripts)
const NONE = -1

func contains_category(category : ItemCategory) -> bool:
	for c in categories:
		if c == category:
			return true
	return false
