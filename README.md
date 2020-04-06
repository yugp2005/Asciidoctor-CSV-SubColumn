# Asciidoctor-CSV-SubColumn
 Select sub column in asciidoctor CSV table to form new table
 
Example:
Original csv file originalAgent.csv

Field agent,ID,score-A,score-B,review, note
James Bond,007,100,82,not bad,more test
Bill,008,85,96,good, select
Edward Donne,001,89,54,more test,not choose

new csv file with choosed sub column
[format="csv", options="header"]
|===
include::originalAgent.csv[cols="1,5"]
|===

chooseAgent.csv
Field agent,review
007,not bad
008,good
001,more test
