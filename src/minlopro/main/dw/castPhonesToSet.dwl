%dw 2.0
input phoneNumbersAsTxt text/plain
output application/apex
---
phoneNumbersAsTxt
  splitBy("\n")
  map (line) -> trim(line)
  filter (line) -> line != "" as String
