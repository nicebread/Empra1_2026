# Course material for "Forschungsorientiertes Praktikum I – Grundlagen der Forschung" in BSc Psychology of LMU Munich (2nd semester)

![](https://img.shields.io/badge/Semester-Summer%20term%202026-informational?logo=&style=flat&logoColor=333333&color=ff9300&labelColor=999999)
![Static Badge](https://img.shields.io/badge/%F0%9F%8C%90%20Visit%20Website-informational?link=https%3A%2F%2Fnicebread.github.io%2FEmpra1_2026%2F)

> 📣 This repository currently has the state of the course from summer term 2024, and has still many PDF slides. This will be (a) updated to Quarto slides during the summer term 2026, and (b) made more generic, with less content for the specific study done.

> 🌐 This repo contains the source code. See the rendered website at [https://nicebread.github.io/Empra1_2026/](https://nicebread.github.io/Empra1_2026/).

*Note: The material will (initially) be a  mixture of German and English. Your mileage may vary.*



## Compilation / dependencies

You need:

- quarto > 1.3.45
- [Font Awesome Extension for Quarto](https://github.com/quarto-ext/fontawesome)
- [Attribution Extension](https://github.com/quarto-ext/attribution)
- The [nicebread theme](https://github.com/nicebread/quarto-FS), which is based on the [Quarto clean theme](https://github.com/grantmcdermott/quarto-revealjs-clean/tree/main)

If you clone the repo, these plugins will already be installed under `_extensions`. Otherwise, run the following commands in the project's root:

```
quarto add quarto-ext/attribution
quarto add quarto-ext/fontawesome
quarto install extension nicebread/quarto-FS
```

To update the theme to the current version, run:

```sh
quarto update nicebread/quarto-FS
```

## Notes to self:

- The default presentation size is 1050 x 700.
- To publish online, run `quarto publish gh-pages` locally.
- Right arrow (→): `&rarr;`
- Double headed arrow (↔): `&harr;`

The repository contains a Github workflow that automatically renders the website when you push to main.



## Quizzes

Quiz questions are stored as R/exams `.Rmd` files.
From this source, two output formats can be generated:

1. Export as **Particify** .csv file, which can be imported into Particify for live quizzes during the lecture (participants scan a QR code and do it on their smartphones).
2. Directly include in a qmd website via the [exams2forms](https://www.r-exams.org/tutorials/exams2forms/) package.

In this repository, the `.Rmd` files for the quiz questions reside in a `/quizzes` subfolder under each presentation (i.e., the quizzes are nested in the folder they belong to). Only "uncategorized" quiz questions are in the general `./quizzes` folder.)

### How to export Particify quizzes

- In R-exams, every `schoice` question needs a solution in the metadata. If you want to assess attitudes or anything else without a correct solution, you can use the `exextra[noCorrect,logical]: TRUE` flag in the exercise file. Then, in the postprocessing step, the (fake) correct solution is removed in the Particify export file.
- Wordclouds can be created with the setting: 

```
extype: string
exsolution: ""
expoints: 0
exextra[wordcloud,numeric]: 3
```

(3 is the number of entry fields)

- Import the `.csv` file into Particify:
  - Log into your Particify account
  - "+ Fragenserie erstellen" --> Add a name --> "Gemischt"
  -  Three vertical dots --> "Inhalte importieren"

### How to setup R/exams webquizzes

- copy https://www.r-exams.org/assets/posts/2024-11-07-exams2forms//webex.css and https://www.r-exams.org/assets/posts/2024-11-07-exams2forms//webex.js to the project folder (in this case, to the `/common` folder)
- link them in `_quarto.yml`:

```yaml
format:
  html:
    css: common/webex.css
    include-after-body: common/webex.js
```

- include in R chunks, e.g.:

````
```{r, echo = FALSE, message = FALSE, results = "asis"}
library(exams2forms)
exams2forms("quizzes/swisscapital.Rmd", title = 'test quiz', solution=FALSE)
```
````
