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

## Notes to self:

- The default presentation size is 1050 x 700.
- To publish online, run `quarto publish gh-pages` locally.
- Right arrow (→): `&rarr;`
- Double headed arrow (↔): `&harr;`
- Full processing:

```
quarto render
quarto publish gh-pages
```