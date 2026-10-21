class_name CampusGigsMenu
extends Control

## Interactive Side Hustles & Student Freelance Gigs Board.
## Allows students to work campus gigs for pocket money, balancing energy and study time.

signal gig_completed(gig_id: String, payout: int)
signal menu_closed

const CampusGigsData = preload("res://scripts/data/campus_gigs.gd")

var current_player: CharacterBody3D = null

@onready var gigs_container: VBoxContainer = %GigsContainer if has_node("%GigsContainer") else null
@onready var close_btn: Button = %CloseBtn if has_node("%CloseBtn") else null
@onready var status_label: Label = %StatusLabel if has_node("%StatusLabel") else null


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_menu)
	_populate_gigs()


func open_gigs(player: CharacterBody3D) -> void:
	current_player = player
	_populate_gigs()
	visible = true


func close_menu() -> void:
	visible = false
	current_player = null
	menu_closed.emit()


func _populate_gigs() -> void:
	if not gigs_container:
		return

	for child in gigs_container.get_children():
		child.queue_free()

	var gigs = CampusGigsData.get_all_gigs()
	for g in gigs:
		var panel = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.1, 0.13, 0.18, 0.95)
		p_style.border_width_left = 1
		p_style.border_width_top = 1
		p_style.border_width_right = 1
		p_style.border_width_bottom = 1
		p_style.border_color = Color(0.2, 0.35, 0.5, 0.5)
		p_style.corner_radius_top_left = 8
		p_style.corner_radius_top_right = 8
		p_style.corner_radius_bottom_right = 8
		p_style.corner_radius_bottom_left = 8
		p_style.content_margin_left = 14.0
		p_style.content_margin_right = 14.0
		p_style.content_margin_top = 10.0
		p_style.content_margin_bottom = 10.0
		panel.add_theme_stylebox_override(&"panel", p_style)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override(&"separation", 14)

		var icon_lbl = Label.new()
		icon_lbl.text = String(g.get("icon", "💼"))
		icon_lbl.add_theme_font_size_override(&"font_size", 28)
		hbox.add_child(icon_lbl)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override(&"separation", 2)

		var title_lbl = Label.new()
		title_lbl.text = String(g.get("title", "Gig"))
		title_lbl.add_theme_font_size_override(&"font_size", 16)
		title_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))
		info_vbox.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = "%s  •  ⏱️ %dm  •  ⚡ -%d%%" % [String(g.get("location", "")), int(g.get("duration_minutes", 30)), int(g.get("energy_cost", 20))]
		desc_lbl.add_theme_font_size_override(&"font_size", 13)
		desc_lbl.add_theme_color_override(&"font_color", Color(0.75, 0.82, 0.9))
		info_vbox.add_child(desc_lbl)

		var detail_lbl = Label.new()
		detail_lbl.text = String(g.get("desc", ""))
		detail_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_lbl.add_theme_font_size_override(&"font_size", 12)
		detail_lbl.add_theme_color_override(&"font_color", Color(0.65, 0.7, 0.75))
		info_vbox.add_child(detail_lbl)

		hbox.add_child(info_vbox)

		# Action Column
		var action_vbox = VBoxContainer.new()
		action_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		action_vbox.add_theme_constant_override(&"separation", 4)

		var pay_lbl = Label.new()
		pay_lbl.text = "+₦%s" % _format_number(int(g.get("payout", 1000)))
		pay_lbl.add_theme_font_size_override(&"font_size", 17)
		pay_lbl.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.45))
		pay_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action_vbox.add_child(pay_lbl)

		var work_btn = Button.new()
		work_btn.text = "Work Gig"
		work_btn.custom_minimum_size = Vector2(96, 36)
		work_btn.pressed.connect(_on_work_gig_pressed.bind(g))
		action_vbox.add_child(work_btn)

		hbox.add_child(action_vbox)
		panel.add_child(hbox)
		gigs_container.add_child(panel)


func _on_work_gig_pressed(gig: Dictionary) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var energy_req: float = float(gig.get("energy_cost", 20.0))
	if needs.energy < energy_req:
		if status_label:
			status_label.text = "⚠️ You are too tired to work (Need %d%% Energy)! Rest on your hostel bed." % int(energy_req)
			status_label.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.3))
		if SoundManager:
			SoundManager.play_alert()
		return

	var min_cgpa: float = float(gig.get("min_cgpa", 0.0))
	if min_cgpa > 0.0 and needs.cgpa < min_cgpa:
		if status_label:
			status_label.text = "⚠️ This tutoring gig requires at least %.2f CGPA (Current: %.2f)!" % [min_cgpa, needs.cgpa]
			status_label.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.3))
		if SoundManager:
			SoundManager.play_alert()
		return

	# Deduct energy, advance time, pay student
	var payout: int = int(gig.get("payout", 2000))
	var duration: int = int(gig.get("duration_minutes", 30))
	needs.modify_energy(-energy_req)
	needs.modify_money(payout)
	TimeSystem.advance_minutes(duration)

	if gig.get("id") == "math_tutoring":
		needs.modify_cgpa(0.05) # Teaching sharpens academic understanding

	if SoundManager:
		SoundManager.play_coin()

	if current_player.has_method("display_notification"):
		current_player.display_notification("Gig Done: %s! +₦%s earned!" % [gig.get("title"), _format_number(payout)])

	if current_player.has_method("play_celebrate_animation"):
		current_player.play_celebrate_animation("💼 GIG PAID! +₦%s" % _format_number(payout))

	PropBuilder3D.advance_quest_if_matching(7, current_player)

	if status_label:
		status_label.text = "✓ Finished %s! Credited +₦%s to your wallet." % [gig.get("title"), _format_number(payout)]
		status_label.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.5))

	gig_completed.emit(gig.get("id", ""), payout)


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
