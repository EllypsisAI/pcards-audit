# Part III — Forensic data analysis, OSU P-cards, calendar year 2014

Queries are `sql/qry_T3_QuestionN.sql`; full result sets are `results/qry_T3_QuestionN.csv`.
Every test below is a risk indicator. None of them establishes that fraud occurred, and the
conclusions say what evidence would be needed to move a flag either way.

---

## Question 1 | Benford's Law, first digit — conformity is close, risk is low

112,140 transactions of $1.00 or more were tested.

| Digit | Actual % | Benford % | Deviation |
|---|---|---|---|
| 1 | 29.528 | 30.103 | −0.575 |
| 2 | 17.771 | 17.609 | +0.162 |
| 3 | 12.867 | 12.494 | +0.373 |
| 4 | 9.814 | 9.691 | +0.123 |
| 5 | 8.221 | 7.918 | +0.303 |
| 6 | 6.124 | 6.695 | −0.571 |
| 7 | 5.513 | 5.799 | −0.286 |
| 8 | 5.372 | 5.115 | +0.257 |
| 9 | 4.790 | 4.576 | +0.214 |

The population **conforms closely**. Every digit is within 0.6 percentage points of its expected
frequency and the mean absolute deviation is **0.318 percentage points** — comfortably inside the
range normally read as close conformity. The classic fabrication signature is absent: invented
amounts show a deficit of leading 1s and a pile-up on 5s, 6s and 7s, and here the deficit on 1
(−0.575) is matched by an equal deficit on 6 (−0.571), which is noise rather than pattern.

**Conclusion: low fraud risk at the population level, and the test should not be pushed further
than that.** Benford's is a test of a whole population. OSU's 2014 P-card file is 116,031
transactions dominated by ordinary supply purchases, so a scheme worth a few hundred thousand
dollars — the size of everything flagged elsewhere in this audit — would move these percentages by
far less than the noise already present. A clean Benford result is evidence that the file has not
been wholesale fabricated. It is not evidence that no individual is defrauding the University, and
the tests below find candidates that this one cannot see.

**Follow-up:** none at file level. A per-cardholder version was tried and rejected — fixed-price
billing breaks Benford at card level (see *Test considered and rejected* below).

## Question 2 | Possible duplicate payments — 4,924 charges in 1,732 clusters

Positive 2014 charges sharing date, vendor, cardholder and amount: **4,924 charges forming 1,732
clusters** across **577 employees**. If every cluster were a genuine double payment, the value paid
twice would be **$670,115**. It is not — most of this population is explainable, and saying so is
the finding.

Three patterns account for the bulk of it. **Per-line subscription billing**: AT&T Data is the
largest single vendor at 356 charges, and 25 identical $25.00 charges on one day is a department
paying for 25 mobile data plans, not one payment made 25 times. **Group travel**: one cluster
contains 14 charges of $310.22 at the same Hyatt on the same day — a conference block where each
attendee's room posts separately. **Genuinely separate same-day orders**: Amazon (195 charges) and
Airgas (236) are used many times a day by large departments.

The population worth testing is the one those explanations do not fit — clusters of exactly two
charges, at a vendor billing an irregular amount, where a second identical charge has no
operational reason. **$4,305.00 charged twice at a lock and security supplier** on 29 August is the
clearest example, and **$2,665.08 three times at a FedEx Office** on 8 August is the next.

**Conclusion: the raw count overstates the risk by roughly an order of magnitude.** The test is
useful only after subscription, lodging and high-frequency vendors are stripped out.

**Follow-up:** exclude lodging MCCs and any vendor billing the same amount to the same cardholder in
three or more months (subscriptions), then work the residue by value. Bank statements resolve each
in minutes — a genuine duplicate has one receipt and two charges.

## Question 3 | Employees repeatedly associated with duplicates — 577 employees, 25 material

Counting *occasions* rather than rows, **577 employees** appear in the Question 2 population and
**25 have ten or more separate duplicate occasions**. The top two — 78 occasions across 68 vendors,
and 65 across 39 — are the ones the test is built to surface, because breadth across vendors is what
distinguishes a person from a billing arrangement.

That distinction sorts this list. An employee with 44 occasions across only **9 vendors** is almost
certainly administering recurring subscriptions; an employee with 78 occasions across **68 vendors**
is not, and their pattern needs another explanation. Value follows the same split: the top employee
carries **$41,526** of potentially doubled value, while an employee with 33 occasions carries $2,383.

**Conclusion: two employees justify individual testing on this evidence, and both also appear in
Part II's largest-spend and split-purchase populations.** That convergence — the same cards
surfacing in unrelated tests — is worth more than any single test's ranking.

**Follow-up:** for the top two, request the 2014 bank statements and reconcile the duplicate
occasions to receipts. Vendor breadth, not occasion count, decides who is tested first.

## Question 4 | Four-digit round-thousand amounts — 160 charges, $343,004

**160 positive charges** landed on a whole thousand dollars, worth **$343,004**, across 115
cardholders and 136 vendors. The distribution is the finding:

| Amount | Charges |
|---|---|
| $1,000 | 71 |
| $2,000 | 29 |
| $3,000 | 22 |
| $4,000 | 6 |
| $5,000 | 20 |

Counts fall away as amounts rise — and then **jump at $5,000, the exact single-transaction limit**.
There are more than three times as many charges at exactly $5,000 as at exactly $4,000. A price that
lands on the ceiling to the cent is a price negotiated *to* the ceiling, not one that happened to
fall below it, and this is the same behaviour Part II's Control 14 found in the $4,500–$4,999.99
band. Two independent tests pointing at the limit is a stronger signal than either alone.

Round thousands also cluster in categories where the amount is decided rather than priced —
professional-body memberships and sponsorship-shaped payments (ABET, AASHTO, the Academy of
Nutrition and Dietetics), and a **$5,000 charge at a chop house**, which is a decided amount at a
restaurant. One cardholder has **13 round-thousand charges**.

**Conclusion: the round-number population is small enough to read in full, and two subsets deserve
it** — the 20 charges at exactly $5,000, and the cardholder with 13.

**Follow-up:** for each $5,000 charge, check whether the same vendor was charged again within the
following weeks; that is what separates a negotiated price from a requirement trimmed to fit.

---

# Student-defined forensic tests (5–8)

## Question 5 | Weekend purchasing at retail merchants — 49 cardholders of concern

Fraud hypothesis: a card used for personal shopping is used when the cardholder is not at work.
Travel-type merchants (lodging, airlines, restaurants, fuel, freight, car rental) are excluded,
because a university legitimately travels at weekends; what remains is consumer retail.

**724 cardholders** made three or more weekend retail charges, worth **$1,435,410** in total, and
**173 made ten or more**. Raw counts favour the busiest cards, so the test also reports each
cardholder's weekend share of their own activity — the largest spender on campus has 156 weekend
charges but that is only **4.6%** of their transactions, which is what a facilities card doing
call-outs looks like.

The population of concern is where both measures are high: **49 cardholders have ten or more weekend
retail charges *and* more than 15% of their transactions falling at weekends**. One has **113
weekend charges at 19.5%**, another **98 at 15.4%**. A fifth of all buying happening at weekends is
not a pattern University purchasing produces.

**Conclusion: 49 cardholders warrant review, ranked by weekend share rather than count.**

**Follow-up:** check the 49 against departmental function first — grounds, athletics, facilities and
event staff work weekends and will explain most of the list. Whoever remains after that filter is
the population worth testing against receipts.

## Question 6 | Sole-user vendors carrying material spend — 118 vendors, $1,217,739

Fraud hypothesis: Part I prohibits purchases from a company owned by a University employee, from
family, and from any business the cardholder has an interest in. A fictitious or related-party
vendor has a signature — exactly one cardholder ever uses it, repeatedly, for material amounts.
Thresholds of three or more charges and over $5,000 for the year exclude one-off purchases.

**118 vendors** are used by exactly one cardholder, together worth **$1,217,739**. **26 average over
$2,000 a charge** and **20 were active in ten or more months** — a year-round exclusive relationship
is the harder one to explain.

Most of the list has an obvious institutional reading and should be cleared quickly: a $116,022
government-services vendor, a hearing-aid supplier at $39,199, a livestock-products supplier — these
are specialist suppliers to specialist units, which is exactly why one buyer uses them. The residual
risk sits with vendors whose *name does not identify a trade*, where a single buyer, a round-ish
average charge and steady monthly activity have no such explanation.

One caveat on method, which also limits Question 7. **The vendor field is not a vendor identifier.**
Some merchants write a per-order string into it: Life Technologies appears under **283 distinct
vendor strings** for 332 transactions, and Staples under 51 strings for 52. The 17,513 "vendors" in
2014 are therefore far fewer real suppliers. Per-order strings cannot reach this test's three-charge
threshold, so they do not create false positives here, but any vendor-level analysis on this file
understates concentration and needs a normalised supplier name before it can be trusted.

**Conclusion: 118 vendors flagged; the ~20 with year-round exclusive use are the testable set.**

**Follow-up:** run the flagged vendor names against the State's business registry and the employee
address file. A vendor sharing an address with its only buyer is the finding this test exists for.

## Question 7 | Untraceable refunds — 115 credits, $57,511

Risk: Part III asks for tests of "fraud or processing errors", and this one is mainly the second.
Part I requires each cardholder to check that returns are credited properly, which only works if
every credit traces back to a purchase. A credit from a vendor the card never paid can be a
reversal the University never recorded, a return whose purchase sits on another card, or — the
fraud case — a refund for goods bought with other funds being routed onto a University card.

**115 credits of $100 or more, worth $57,511**, come from vendors the cardholder made no 2014
purchase from. Two things had to be fixed before that number meant anything.

First, **the test was rewritten**. Matching credits to charges of the same amount flagged 2,351 of
the 3,791 credits — a population too large to act on, because partial refunds, restocking deductions
and price adjustments legitimately fail an exact-amount match. Requiring no purchase at that vendor
*at all* narrows it to 298, and a $100 floor to 115. The rewrite also replaced a correlated
subquery with a join: **92 seconds to under one second**.

Second, **33 of the 115 are a data artefact, not an exception**. Their vendor names begin
`CLAIM ADJ/` — bank chargeback adjustments, where the disputed vendor's name is rewritten with a
prefix. `CLAIM ADJ/THE HOME DEPOT` can never match a charge at `THE HOME DEPOT`, so the test flags
successfully disputed transactions, which are the system working. Those 33 are worth $23,949.

That leaves **82 credits worth $33,562** genuinely unexplained — and some of those are the
per-order vendor strings described above, where a Staples credit carries a different order number
from the purchase it reverses. A third source of false positives cannot be removed at all: the
case restricts testing to 2014, so a January refund for a December 2013 purchase looks untraceable.

**Conclusion: after removing chargeback adjustments and order-numbered vendor strings, the
investigable population is small — a few dozen credits.** The value of the test is not the
population size but that it is cheap and repeatable each year.

**Follow-up:** normalise vendor names, re-run, and check the residue against the requirement that
credits be reconciled to the cardholder's own statement.

## Question 8 | Fiscal year-end spending surge — 41 cardholders, $391,095 in June

Fraud and misstatement hypothesis: Oklahoma's fiscal year ends 30 June. Budget holders facing a
lapsing balance have an incentive to spend it — buying what is not yet needed, stockpiling, or
prepaying, which Part I prohibits outright as a State statute violation. The signature is a June
concentration the rest of that cardholder's year does not explain, so each cardholder is compared
against their own eleven-month average rather than against other people.

**41 cardholders** spent at least $5,000 in June at more than three times their own monthly average,
**$391,095** in total, and **10 exceeded ten times**. The extremes are stark: one cardholder spent
**$7,504 in June against a $212 monthly average — 35 times** — across only six charges, and another
**$17,546 against $747, 23 times**, across 30 charges.

Those two shapes are different risks. Six charges at 35× is a small number of large purchases made
because money was available, which is where prepayment and stockpiling live. Thirty charges at 23×
is a spending spree across many small items, which is where unallowable and personal purchases hide.

**Conclusion: 41 cardholders show a year-end pattern that their own year does not otherwise support,
and the 10 above ten times are a priority.** This is the test most likely to find something Part
II's category tests cannot, because nothing here is individually prohibited — it is the *timing*
that is wrong.

**Follow-up:** for the top 10, list June purchases and check delivery dates against the invoice
dates. Goods delivered in the new fiscal year against a June charge are a prepayment, which is a
statutory violation and not merely poor budgeting.

---

## Test considered and rejected: Benford per cardholder

Question 1's own conclusion is that a whole-file Benford test cannot see one person, so the obvious
next step was to run it per cardholder, on every card with 300 or more charges of $1.00 or more
(`sql/considered/benford_by_cardholder.sql`).

It does not work on this data. **18 of the 36 cards fail** (mean absolute deviation above 0.015),
and every card at the top fails because of a fixed price billed over and over: **$30.00 charged 170
times** (an AT&T data plan), **$83.00 charged 131 times** (a hotel room rate), **$12.00 charged 188
times**. Benford's law assumes amounts vary freely; a card that pays one fixed price hundreds of
times breaks that assumption without anyone doing anything wrong. Per-card Benford therefore ranks
billing arrangements, not fraud risk — the same lesson as the duplicate test in Question 2 — and it
was not used.

---

## What Part III establishes

The file as a whole is not fabricated — Benford conformity is close, with a mean absolute deviation
of 0.318 percentage points. Risk sits in individual behaviour, and four tests converge on the same
small group of cards: the two employees with the broadest duplicate patterns are also among the
largest spenders and appear in the split-purchase tests, and the round-number test independently
confirms the pile-up at the $5,000 limit found in Part II.

Two of the four given tests badly overstate their populations before judgment is applied — 4,924
"duplicates" that are mostly per-line subscription billing and group hotel bookings, and an initial
2,351 unmatched credits that were mostly partial refunds. Both needed a second dimension before they
became findings, and the same is true of the prohibited-category tests in Part II. **Reading the
flagged rows is the analysis; producing them is not.**

The limiting factor on this dataset is identity. The vendor field carries per-order strings for some
merchants (283 strings for one supplier), and cardholders are pseudonymised with no department, card
limit or approver attached. Half the tests here end at "request the mapping" — not because the
analysis is incomplete, but because these tests rank risk, and only the underlying records can
settle it.
