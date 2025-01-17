@icon("res://Assets/Mine/UI.svg")
extends Control

#Main Column
@onready var Icon:TextureRect = $MainColumn/Frame/Icon
@onready var Name:Label = $"MainColumn/Name Field"
@onready var HP:Label = $"MainColumn/HP Field"
@onready var AETHER:Label = $"MainColumn/AETHER Field"

#Item
@onready var ItemDescription:Label = $"MainColumn/AETHER Field"
@onready var ItemDescriptionTool:Control = $"Item Description Field/Tooltip"

#Armor and Damage
@onready var ArmorIcon:TextureRect = $VisibleStats/DamageAndArmor/ArmorIcon
@onready var Armor:Label = $VisibleStats/DamageAndArmor/ArmorField
@onready var DamageIcon:TextureRect = $VisibleStats/DamageAndArmor/DamageIcon
@onready var Damage:Label = $VisibleStats/DamageAndArmor/DamageField

#Hero
@onready var Body:Label = $"VisibleStats/HeroStats/Strength Field"
@onready var Finesse:Label = $"VisibleStats/HeroStats/Agility Field"
@onready var Mind:Label = $"VisibleStats/HeroStats/Int Field"

@onready var heroSection:Control = $VisibleStats/HeroStats
@onready var unitSection:Control = $VisibleStats/DamageAndArmor

func _ready() -> void:
	ItemDescriptionTool = $"Item Description Field/Tooltip"
	HideHero()
	HideItem()

func ShowHero(hero:Node) -> void:
	ShowUnit(hero)
	Body.text = str(hero.GetBodyAmount())
	Finesse.text = str(hero.GetFinesseAmount())
	Mind.text = str(hero.GetMindAmount())
	
	heroSection.visible = true
	
func HideHero() -> void:
	heroSection.visible = false
	HideUnit()

func ShowUnit(unit:Node)	-> void:
	Icon.texture = unit.GetIcon()
	Name.text = unit.GetName()
	HP.text = str(unit.GetCurrentHPAmount()) + " / " + str(unit.GetMaxHPAmount())
	AETHER.text = str(unit.GetCurrentAETHERAmount()) + " / " + str(unit.GetMaxAETHERAmount())

	Armor.text = str(unit.GetArmorAmount())
	Damage.text = str(unit.GetDamageAmount())

	#Do Armor and Damage Icon update based on type
	# assign armor texture from source based on armor type
	# assign damage texture from source based on damage type

	Icon.visible = true
	Name.visible = true
	HP.visible = true
	AETHER.visible = true
	unitSection.visible = true

func HideUnit()	-> void:
	Icon.visible = false
	Name.visible = false
	HP.visible = false
	AETHER.visible = false
	unitSection.visible = false

func ShowItem(item:InventoryItem) -> void:
	#ItemDescription.text = item.getItemDescription()
	ItemDescription.visible = true
	Icon.texture = item.icon
	Name.text = item.name
	HP.visible = false
	AETHER.visible = false
	Icon.visible = true
	ItemDescriptionTool.setToolTipName(item.name,"")
	ItemDescriptionTool.setToolTipLore(item.properties["Lore"])
	ItemDescriptionTool.setToolTipRank(item.properties["Rank"])
	ItemDescriptionTool.show_tooltip()

func HideItem() -> void:
	ItemDescription.visible = false
	if ItemDescriptionTool:
		ItemDescriptionTool.hide_tooltip()
