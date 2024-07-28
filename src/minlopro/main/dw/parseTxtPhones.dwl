%dw 2.0
input phoneNumbersAsTxt text/plain
output application/apex
---
phoneNumbersAsTxt splitBy("\n")
