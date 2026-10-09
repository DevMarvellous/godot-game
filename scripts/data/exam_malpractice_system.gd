class_name ExamMalpracticeSystem
extends RefCounted

## Nigerian Campus Academic Integrity & Disciplinary Tribunal Engine.
## Governs moral dilemmas during Continuous Assessment tests and Semester Exams.
## Options: Honest Effort vs "Expo / Microchip" cheat sheets.

enum DilemmaResult { HONEST_PASS, EXPO_SUCCESS, CAUGHT_BY_INVIGILATOR }

const CATCH_PROBABILITY: float = 0.35 # 35% chance of invigilator inspection

static func attempt_expo(player_cgpa: float) -> Dictionary:
	# Desperation factor: Lower CGPA students are more scrutinized by invigilators
	var catch_chance: float = CATCH_PROBABILITY + (0.15 if player_cgpa < 2.50 else 0.0)
	var roll: float = randf()

	if roll < catch_chance:
		return {
			"result": DilemmaResult.CAUGHT_BY_INVIGILATOR,
			"title": "🚨 CAUGHT RED-HANDED WITH EXPO!",
			"message": "Dr. Adebayo caught you sneaking a microchip under your desk!\n'Examination Malpractice is a criminal violation of University Senate Regulations! You are hereby reported to the Student Disciplinary Committee!'",
			"bonus_marks": 0.0,
			"cgpa_penalty": -0.40,
			"faith_penalty": -35.0,
			"disciplinary_record": "Misconduct: Examination Malpractice (Expo)"
		}
	else:
		return {
			"result": DilemmaResult.EXPO_SUCCESS,
			"title": "⚠️ EXPO SMUGGLED (UNCAUGHT)",
			"message": "You copied answers from the smuggled microchip without Dr. Adebayo noticing.\nYour test marks increased, but your guilty conscience troubles your spirit.",
			"bonus_marks": 12.0,
			"cgpa_penalty": 0.0,
			"faith_penalty": -20.0,
			"disciplinary_record": "Clear"
		}


static func choose_honesty() -> Dictionary:
	return {
		"result": DilemmaResult.HONEST_PASS,
		"title": "✓ ACADEMIC INTEGRITY MAINTAINED",
		"message": "You chose honesty and answered with your genuine knowledge.\n'The blessing of the Lord maketh rich, and he addeth no sorrow with it.'",
		"bonus_marks": 0.0,
		"cgpa_penalty": 0.0,
		"faith_penalty": 0.0,
		"faith_boost": 20.0,
		"disciplinary_record": "Clear"
	}
