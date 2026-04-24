## TODOs:
# - Add a check: No markdown in response options
# - Add a check: No " in response options (rather use ')

library(exams)
library(rio)

# Export quiz exercises to Particify CSV format with post-processing.
#
# @param prefix Character. Filename prefix used to find matching .Rmd files
#   (e.g. "OS-M1-S1-Replicability") and to name the exported CSV.
# @param quiz_dir Character. Directory containing the .Rmd exercise files.
# @param export_dir Character. Directory for the Particify CSV output.
#
# Per-item exextra flags (set in the .Rmd Meta-information section):
#   exextra[noCorrect,logical]: TRUE   – remove correctOptions in Particify
#   exextra[wordcloud,numeric]: N      – convert item to WORDCLOUD with N entry fields
export_to_particify <- function(
	prefix,
	quiz_dir   = "quizzes",
	export_dir = "quizzes/Particify_export"
) {
	fi <- list.files(quiz_dir, pattern = paste0(prefix, ".*\\.Rmd$"), full.names = TRUE)
	exams2particify(fi, dir = export_dir, name = prefix, abstention = TRUE)

	# post-processing: remove `correctOptions` only for items explicitly flagged
	# with `exextra[noCorrect,logical]: TRUE` in the exercise file
	has_solution <- vapply(
		fi,
		function(file) {
			meta <- read_exercise(file)$metainfo
			flag <- meta$noCorrect
			if (is.null(flag)) TRUE else isFALSE(flag)
		},
		logical(1)
	)

	# post-processing: change schoice into a wordcloud for items explicitly flagged
	# with `exextra[wordcloud,numeric]: number_of_entryfields` in the exercise file
	is_wordcloud <- vapply(
		fi,
		function(file) {
			meta <- read_exercise(file)$metainfo
			flag <- meta$wordcloud
			if (is.null(flag)) 0 else flag
		},
		numeric(1)
	)

	p_name <- paste0(prefix, "-1.csv")
	csv <- import(paste0(export_dir, "/", p_name))

	csv$correctOptions[!has_solution] <- "false"

	csv$format[is_wordcloud > 0]        <- "WORDCLOUD"
	csv$options[is_wordcloud > 0]       <- is_wordcloud[is_wordcloud > 0]
	csv$multiple[is_wordcloud > 0]      <- "false"
	csv$correctOptions[is_wordcloud > 0] <- "false"

	export(csv, paste0(export_dir, "/", p_name))
	invisible(csv)
}
