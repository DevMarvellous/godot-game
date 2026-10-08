class_name AcademicProgression
extends RefCounted

## Nigerian 4-Year / 5-Year Academic Progression System.
## 100 Level -> 200 Level (Direct Entry option) -> 300 Level -> 400 Level -> 500 Level (Engineering/Medicine).
## Tracks probation, disciplinary committee suspensions, and expulsion risk!

enum AcademicStanding { GOOD_STANDING, WARNING, PROBATION, SUSPENDED, EXPELLED, GRADUATED }

const ACADEMIC_LEVELS: Dictionary = {
	100: {"title": "100 Level (Fresher)", "required_units": 36, "max_probation_semesters": 2},
	200: {"title": "200 Level (Sophomore / Direct Entry)", "required_units": 38, "max_probation_semesters": 2},
	300: {"title": "300 Level (Penultimate / SIWES Intern)", "required_units": 34, "max_probation_semesters": 2},
	400: {"title": "400 Level (Final Year - Non-Professional)", "required_units": 32, "max_probation_semesters": 1},
	500: {"title": "500 Level (Final Year - Engineering / Med)", "required_units": 30, "max_probation_semesters": 1}
}

static func evaluate_standing(cgpa: float, consecutive_probations: int) -> Dictionary:
	if cgpa < 1.00:
		return {
			"standing": AcademicStanding.EXPELLED,
			"title": "ADVICE TO WITHDRAW (EXPULSION)",
			"message": "CGPA dropped below 1.00. The Senate has recommended withdrawal from the University."
		}
	elif cgpa < 1.50:
		if consecutive_probations >= 2:
			return {
				"standing": AcademicStanding.EXPELLED,
				"title": "EXPELLED (EXCEEDED PROBATION LIMIT)",
				"message": "Two consecutive semesters on probation without recovery. Academic journey terminated."
			}
		else:
			return {
				"standing": AcademicStanding.PROBATION,
				"title": "ACADEMIC PROBATION (WARNING)",
				"message": "CGPA is below 1.50! You must score at least 3.00 next semester to avoid withdrawal."
			}
	elif cgpa < 2.40:
		return {
			"standing": AcademicStanding.WARNING,
			"title": "THIRD CLASS STANDING",
			"message": "Eligible to progress, but serious academic improvement is required."
		}
	else:
		return {
			"standing": AcademicStanding.GOOD_STANDING,
			"title": "GOOD ACADEMIC STANDING",
			"message": "Clear standing with no disciplinary or probation encumbrances."
		}
