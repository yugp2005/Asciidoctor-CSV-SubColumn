# Asciidoctor-CSV-SubColumn
 Select sub column in asciidoctor CSV table to form new table
 
Example:
FieldAgents.csv
Field agent,ID,score-A,score-B,score-final, note
James Bond,00-7,100,82,91,A
Bill,00-8,85,96,90.5,A
Edward Donne,00-1,89,54,71.5,B
Stuart Thomas,00-5,56,75,65.5,C

New csv file with choosed sub column
[format="csv", options="header"]
|===
include::FieldAgents.csv[cols="1,5,6"]
|===

SubFieldAgents.csv
ID,score-final, note
00-7,91,A
00-8,90.5,A
00-1,71.5,B
00-5,65.5,C
