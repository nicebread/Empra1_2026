- Run OS knowledge test (Barthelmäs)
- Achtung Empra 1: Quarto läuft nicht auf Snapdragon ARM Prozessor --> Dell Laptop (R-Studio funktioniert schon)
- Breuer email: Attention Check
Zu Deiner Frage: Einen kompletten Überblick über die Survey-Data-Quality(-Check)-Literatur habe ich leider auch nicht.
Generell würde ich sagen Attention Checks machen prinzipiell schon Sinn und auch Fragen wie „Haben Sie aufmerksam und ehrlich geantwortet und können wir Ihre Daten für die Analyse nutzen?“ können eine (zusätzliche Option sein).
 
Ein Paper von ehemaligen GESIS-Kollegen zum Thema Attention Checks in Surveys ist dieses hier:
Gummer, T., Roßmann, J., & Silber, H. (2021). Using Instructed Response Items as Attention Checks in Web Surveys: Properties and Implementation. Sociological Methods & Research, 50(1), 238–264. https://doi.org/10.1177/0049124118769083
 
Zur Frage der Bot Detection in Surveys gibt es aktuell auch einige Arbeiten (u.a. von Jan-Karem Höhne und seinem Team). Z.B.:
Claassen, J., Höhne, J. K., Bach, R., & Haensch, A.-C. (2025). Identifying Bots through LLM-Generated Text in Open Narrative Responses: A Proof-of-Concept Study. https://doi.org/10.13140/RG.2.2.29164.68488
 


1. An attention check item, such as: „Research should aim for reliable results. Note: in this question, please select ‚not at all‘, regardless of what you actually think.“
2. A honeypot for bots: "(d.h., bots sehen die Freitextfrage "Bitte schreiben Sie einen Text" und Menschen sehen diese Frage nicht)“ —> e.g. https://u.osu.edu/cswqualtrics/2024/08/01/honey-pot-question-to-identify-bots. I asked a colleague how they implemented that in formr.
3. Check the timings: Too fast answers? —> exclude

