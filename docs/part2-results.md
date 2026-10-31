# Part II — Internal control testing, OSU P-cards, calendar year 2014

Every figure below is reproduced by `python3 run.py` against the provided `pcards.db`;
full result sets are in `results/QuestionN.csv`.

## Scope and assumptions

The file provided contains **489,178 transactions**, all of them agency 1000, Oklahoma State
University — despite the case background describing a state-wide extract, no other agency is
present, so no agency filter was needed. **116,031 transactions totalling $33,504,148** fall in
2014, spread across **2,021 cardholders**, 17,513 vendors and 350 merchant category codes.

Four data decisions govern every test:

1. **`Year` is a reliable calendar-year filter.** It matches the year in `TransactionDate` in
   489,178 of 489,178 rows, so `WHERE Year = 2014` is exact. It matches `PostedDate` in only
   488,836 rows, which confirms the column follows the transaction, not the posting.
2. **`TransactionDate` does not sort.** It is text in `M/D/YYYY 0:00:00` form, so a text sort puts
   1 January 2012 next to 1 October 2014. Every test that groups or orders by date parses it to
   `YYYY-MM-DD` first. The time component is midnight on all 489,178 rows.
3. **Amounts are summed net of credits.** 3,791 of the 2014 rows are negative (returns and
   refunds). Netting them gives what the cardholder actually cost the University; on a gross
   basis the Control 1 and 2 populations would be slightly larger.
4. **Cardholders are pseudonymised** (`Employee 51914657`). Tests identify people consistently but
   the auditor needs the mapping back to real names, and to department and card limits, before any
   of this reaches a person.

A flagged transaction is a *potential* exception. Nothing below establishes a violation; the point
is to rank where additional testing is worth doing.

---

## Control 1 | Annual spend above $50,000 — 127 cardholders

**127 of 2,021 cardholders** (6.3%) exceeded $50,000 of net spend in 2014, together accounting for
**$15,527,124** — 46% of the University's entire P-card spend. The distribution is extremely
skewed: the median flagged cardholder spent $76,076, while the top card spent **$1,595,302** across
3,510 transactions, and the top two together spent $2.78m.

Cards of that size are almost certainly departmental purchasing cards operated by a buyer on behalf
of a unit, not personal cards used against a $50,000 credit limit — a $1.6m annual spend is not a
control failure so much as a card whose limit was set well above the policy default. Part I allows
exactly that: limits are set departmentally on the application form and reviewed annually under
Cardholder Limit Recertification.

**Follow-up:** this test cannot be concluded without the card-limit table. The audit question is not
"who spent more than $50,000" but "who spent more than *their own approved limit*", and the extract
does not contain limits. Request the limit file, re-run the comparison against it, and treat the
recertification review as the primary control being tested. The seven cardholders flagged in all
twelve months (Control 2) are the natural starting sample.

## Control 2 | Monthly spend above $10,000 — 457 cardholder-months

**457 cardholder-months** breached $10,000, involving **161 distinct cardholders**. Volume is
stable month to month (27 in November to 45 in April), which argues against a seasonal
year-end spending push and for a standing population of high-volume buyers. **Seven cardholders
were flagged in all twelve months** — for those, a $10,000 monthly ceiling plainly does not
describe the job the card is doing.

Part I requires departments to justify any monthly credit limit above $10,000, so a persistent
breach is evidence either of an approved higher limit (documentation should exist) or of a limit
that was never updated. Both are answerable from the P-card application and Change Forms.

**Follow-up:** pull the approval documentation for the seven always-flagged cardholders first; they
give the best return per hour. If the justifications exist, the finding downgrades to a
recertification housekeeping point rather than a control breach.

## Control 3 | Single transactions above $5,000 — 33 transactions

Only **33 transactions** in 116,031 exceeded the $5,000 single-transaction limit, worth **$357,871**
in total, ranging from $5,101 to $29,732. That the number is this small is itself the finding: the
limit is enforced at the point of sale when the card is swiped, so the population should be near
zero and it is.

What matters is the concentration. The 33 transactions belong to just **six cardholders**, and two
of them account for 26 of the 33 — one with 14, one with 12. That pattern is not "the limit
occasionally failed"; it is two cards carrying an approved single-transaction limit above $5,000.
The largest items are consistent with that reading: a $29,732 elevator-maintenance charge, and a
run of large hotel and air-travel charges on one card that looks like a departmental travel
arranger booking for groups.

**Follow-up:** confirm the two cards' approved single-transaction limits. If the limits were
raised, the exceptions resolve and the remaining four cardholders — one transaction each — become
the real test population.

## Control 4 | Split across multiple swipes, same card, same vendor, same day — 66 split-days

**66 cardholder-vendor-days** involving **30 cardholders** show more than one swipe at the same
vendor on the same day with a combined total above $5,000; 254 individual transactions make up
those days. The largest is **$21,020** at a hotel, and one day contains **11 separate swipes**.

The population divides into two very different risks. Lodging and travel days — the $21,020
DoubleTree charge, a $15,327 Hilton day — are typically one folio settled in several charges, or a
group booking, and are weak indicators. Trade-supplier days are the stronger signal: four swipes at
an HVAC contractor totalling $5,164, three at a building-systems contractor totalling $6,063. Those
are the shape Part I describes as split purchasing, because the goods are a known quantity that
could have been consolidated onto one requisition.

**Follow-up:** exclude lodging and airline MCCs and work the contractor and supplier days first.
For each, the test is whether the items were a single known quantity at the time of ordering —
answerable from the receipts the cardholder is required to retain.

## Control 5 | Split between two cardholders — 24 vendor-days

**24 vendor-days** show exactly two cardholders buying from one vendor on one day for a combined
total above $5,000. Requiring exactly two transactions as well as exactly two people is what
excludes double payments: without it, one person's repeat swipe reappears here as Control 4's
population.

Two vendor-days are materially stronger than the rest: on those, **both cardholders charged an
identical amount**. The clearest is B & H Photo-Video, where two cardholders each charged
**$2,544.07** on the same day for a described purchase of the same camera model — $5,088 of
equipment bought as two matching halves. Recurring pairs at the same trade suppliers (EEI, The Lee
Company, MWI Veterinary Supply appear on four rows each) suggest two buyers in one department
routinely splitting supplier orders.

**Follow-up:** the two identical-amount days should be tested immediately — matching amounts are
hard to explain as coincidence. For the recurring supplier pairs, establish whether the two
cardholders sit in the same department and whether a single requisition would have been required.

## Control 6 | Split between two vendors — 59 cardholder-days

**59 cardholder-days** across **48 cardholders** show one person spending above $5,000 in a day
across exactly two vendors. This is the weakest of the three split tests by construction: a busy
buyer who happens to place two unrelated orders on one day looks identical to someone deliberately
splitting one purchase.

The result set bears that out. A carpet showroom plus an office-furniture supplier ($5,438) is
plausibly one refurbishment split across two suppliers — the pattern Part I prohibits. But a $5,000
professional-association membership paired with a $3,775 plumbing charge, or a $5,000 charge paired
with **$2.80 of toll fees**, are unrelated purchases that the day-level threshold has swept up.

**Follow-up:** rank by whether the two vendors are substitutable — same MCC, or same commodity —
before spending time on this population. The single-vendor tests (Controls 4 and 5) deserve the
hours first.

## Control 7 | Travel food alongside lodging — 99 transactions

**31 cardholders** charged food on a day they also charged lodging: **99 transactions totalling
$19,448**, all at eating-place or fast-food merchants. Part I is unambiguous that food while in
travel status belongs on a travel voucher as per diem, not on a P-card, so the whole population is
a potential deviation.

Amounts distinguish two behaviours. Small charges — $6.67 at Chick-fil-A, $15 at Jimmy John's —
read as an individual buying their own meal, exactly the per-diem substitution the policy prohibits.
Large ones do not: **$1,033 and $974 at the same Olive Garden** on separate November days, and $886
at an OSU catering outlet, are group meals, which is a different question (allowable business
hospitality, or an unallowable meal) resolved by the business purpose in Works, not by this test.

One caveat on method: the specification says to match MCCs containing "food", and the 2014 data
contains a `PET SHOPS, PET FOOD AND SUPPLIES` MCC (701 transactions) that satisfies that wording
without being travel food. It happens not to appear in this result — no cardholder charged pet food
on a lodging day — but the same query run on another year would report pet supplies as travel
meals. The literal specification and the control's intent are not the same population.

**Follow-up:** split by amount. Charges under roughly $30 per cardholder-day are the per-diem
substitution the control is aimed at; the four-figure charges are a hospitality question for the
department head.

---

# Student-defined controls (8–14)

Each test below is drawn from a specific prohibition in the Part I procedure.

## Control 8 | Alcohol — 12 transactions, $19,409

Part I prohibits alcohol outright. **12 transactions totalling $19,409** hit liquor-store and
drinking-place MCCs in 2014, across five cardholders — but **one cardholder accounts for the great
majority of the value**, with repeated four-figure purchases at a single liquor store
(BROWNS BOTTLE SHOP) spread across March, May, October, November and December. Individual charges
run to $4,151.

A recurring, deliberate, year-round pattern at one vendor is not an accidental swipe. The plausible
innocent explanation is institutional: OSU runs a hospitality and restaurant-management programme
with a teaching restaurant, and a purchasing card held by that unit would buy alcohol as stock for
teaching and licensed service. That would make the purchases legitimate in substance while still
breaching the stated procedure, which contains no such exemption.

**Follow-up:** the highest-value single test in this set — five transactions, one cardholder,
resolved by identifying the department. Either it is a licensed teaching operation and the
procedure needs a documented exemption, or it is a straightforward statutory violation.

## Control 9 | Donations and sponsorships — 13 transactions, $6,366

Part I prohibits donations and sponsorships outright, and the Part IV brief names them among the
purchases an auditor must be able to find.

The obvious test — every charge at a charitable merchant — fails on inspection. The MCC
`CHARITABLE AND SOCIAL SERVICE ORGANIZATIONS` carries **1,053 transactions worth $489,316** in
2014, but its largest vendors are NFPA ($33,289 of fire-code standards), PLOS ($15,625 of journal
publication fees) and conference bodies such as ACUI and AACRAO. Those are non-profits *selling*
the University something it needs. A donation is defined by its recipient being a cause, so the
test keeps non-profit merchants whose name identifies one, every payment to a religious or
political organisation, and any line that describes itself as a donation.

On that basis **13 transactions worth $6,366** across **12 cardholders** remain: a community food
bank ($308), the American Red Cross ($190), March of Dimes ($113), the Arthritis Foundation ($934),
two university foundations (NSU $1,000, GMU $575), and payments to religious organisations (Freedom
Ranch twice for $1,918, AFA $500). Even these have innocent readings — the Red Cross sells
first-aid training and a foundation can be a conference organiser — and the single "political
organisation" charge is to a vendor named `MEDICAL EQUIPMENT`, which reads as a mis-coded merchant
rather than a political contribution.

**Conclusion:** donations are not a material leak. The finding worth reporting is the method one:
a merchant-type test would have reported half a million dollars of "donations" that are almost all
legitimate purchases.

**Follow-up:** the four religious and political payments first ($2,668) — a political
contribution on a State card is a statutory matter regardless of size — then the named charities.

## Control 10 | Gasoline — 129 cardholders with pump-sized charges

Part I requires gasoline to come from Transportation Services or the vehicle's own fuel card.
**157 cardholders** charged fuel merchants in 2014, totalling **$234,413**.

The first run of this test was misleading and the query was rewritten. Merchant category alone does
not separate filling a car from a bulk fuel delivery: the largest single "service station" charge in
2014 is **$4,075**, and one cardholder charged **$46,405 across 40 transactions at a single fuel
supplier** — that is a facilities fuel account carrying a service-station MCC, not somebody's tank.
Fuel-dealer MCCs (fuel oil, wood, coal, propane) are heating fuel and were dropped from the test
entirely. The rewritten query reports pump-sized charges (≤$150) separately from larger ones.

On that basis **129 cardholders made pump-sized fuel purchases worth $14,083**, and **16 of them did
so five times or more** — one cardholder 62 times across seven different stations. Repetition is
what makes this a finding: a single fill on a rental car during travel is defensible, sixty-two is a
routine that bypasses the fuel-card control.

**Follow-up:** the 16 repeat purchasers. Check each against the vehicle fleet — if they operate a
University vehicle, a fuel card exists and is not being used.

## Control 11 | Purchases from OSU's own units — 272 transactions, $90,118

Part I requires purchases from University departments and auxiliaries to go through the campus
vendor invoice (CVI) system. A card charge to an OSU unit moves money from one University account
to another through an external bank: it pays card fees on an internal transfer and leaves no
internal billing record.

**272 charges worth $90,118** across **113 cardholders** went to vendors named as OSU units. They
fall into three groups that carry very different weight:

| Group | Charges | Value | Reading |
|---|---|---|---|
| Stillwater units — Cowboy Golf, Cowboy Dining, Extension e-store, Atherton Hotel, Nursing | 27 | $17,985 | The clearest breaches: these are University auxiliaries CVI exists for |
| OSU Alumni Association | 79 | $48,633 | A separately incorporated affiliate; whether CVI applies depends on whether it is on the system |
| OSU-Oklahoma City, OSU-Tulsa, OSU Medical Center | 166 | $23,500 | Separate institutions in the OSU system, mostly bookstores and dining; probably legitimate card use |

One Stillwater charge stands out on its own: **$5,000.00 exactly to OSU Nursing**, the same
negotiated-to-the-ceiling amount Control 14 looks for.

**Conclusion:** the core breach population is small — 27 charges, about $18,000. The Alumni
Association is a policy question rather than an exception, and the largest single block.

**Follow-up:** ask Purchasing which of these vendors are on CVI. For the Alumni Association,
identify what was bought — event tables and memberships also touch the memberships prohibition.

## Control 12 | Cash, cash advances and ATM — nil, control effective

Part I prohibits cash, cash advances and ATM transactions. This is a preventive control enforced by
MCC blocking at the point of sale, so the expected result is nil, and **the test returned nil**: no
cash-type transaction occurred on an OSU P-card in 2014. The MCC block operated for the full year.

The first version of this query returned six transactions, all false positives, and the failure is
worth recording. Matching the vendor field on `%ATM%` matched **"THE ROYAL TREATMENT @ HEA"**
(tre**ATM**ent) and **"PAYPAL LPLATMAN"** — a three-letter substring appears inside ordinary words.
Padding the field with spaces and matching `% ATM %` forces ATM to stand as its own word and removes
both without weakening the test. A keyword test that is not anchored to word boundaries will
manufacture exceptions, and an auditor who does not read the flagged rows will report them.

**Follow-up:** none. Document as a control tested and found effective, and repeat annually — the
value of this test is that it establishes the MCC blocking works, which is what makes the other
prohibited-purchase categories testable at all.

## Control 13 | Recurring payments above $5,000 a year — 463 cardholder-vendor pairs

Part I requires maintenance, lease/rental and service agreements above $5,000 for the fiscal year to
go on a requisition and a purchase order. Individual charges can each sit far below the
single-transaction limit and still breach this, so the test looks at the relationship across the
year rather than at transactions.

**463 cardholder-vendor pairs** were charged in six or more distinct months of 2014 with an annual
total above $5,000, worth **$6,090,057** — 18% of all P-card spend. **104 pairs were charged in all
twelve months**, and **265 pairs have an average charge below $500**, which is the pattern the
control exists to catch: a standing supplier relationship drip-fed through a payment card instead of
being competed and put on a PO. The largest is 490 transactions to one electrical supplier
averaging $278 and totalling $136,229.

**Follow-up:** this is the largest-value finding in Part II by an order of magnitude, and the
cheapest to act on, because it does not require judgment about individual transactions. Cross-check
the top pairs against the PO system; any with no PO is a procurement-route breach and a lost
opportunity to competitively bid six-figure annual spend.

## Control 14 | Structuring below the single-transaction limit — 50 cardholders, 184 charges

Controls 4–6 catch splits that land on the same day. This test looks for the behavioural signature
that precedes them: charges parked immediately below the $5,000 ceiling. If purchasing followed
genuine need, amounts would not pile up in the last band before the limit.

They do. 2014 contains **269 charges of $4,500–$4,999.99 against 218 in the $4,000–$4,499.99 band
below it** — the count rises as the limit approaches, when a demand-driven distribution should
continue falling. **50 cardholders had more than one near-limit charge**, 184 charges in total worth
**$885,814**, and **15 charges landed on exactly $5,000.00**. The two most active cardholders — 18
and 17 near-limit charges, spread across 16 and 12 different vendors — are also the two largest
spenders in Control 1 and appear throughout Controls 4 and 5.

An amount of exactly $5,000.00 is the strongest single indicator here: it is a price negotiated to
the ceiling rather than a price that happened to fall below it.

**Follow-up:** the 15 exactly-$5,000 charges first, then the two high-frequency cardholders. For
each, the question is whether a larger known requirement was trimmed to fit the card — visible in
whether the same vendor was charged again shortly afterwards.

---

## Tests considered and rejected

The seven student-defined controls were chosen from a longer list. Every candidate was sized
against the 2014 data before deciding, and the queries are kept in `sql/considered/` so each
number below is reproducible.

| Candidate | Policy basis | 2014 result | Why it was not used |
|---|---|---|---|
| Gifts, flowers, candy | Gifts; items without business purpose | 570 txns, $164,872 | Mostly nursery stock and event supplies — the merchant type cannot tell a bouquet from a pallet of bedding plants. Replaced by Control 9 |
| Insurance | Requisition through Risk Management | 16 txns, $8,752 | Valid but immaterial; mostly travel and event-ticket cover bought at booking. Replaced by Control 11 |
| Personal / consumer merchants (clothing, shoes, jewellery, cosmetics, streaming) | Personal purchases of any type | 820 txns, $166,106 | Too noisy: athletics, theatre and uniform buying share these merchant types, and there is no department field to separate them |
| Apple products outside the Bookstore | Apple products rule | 17 txns, $7,028 | Small, and the rule is Stillwater-only — the data cannot show which campus a cardholder works on |
| Memberships and dues | Personal and individual memberships | 996 txns, $505,443 | Institutional memberships are allowed; nothing in the data separates them from personal ones |
| Mail and postage | Use University Mailing | 21 txns, $5,297 | Small; left to the Part IV vendor search |
| Late fees | Late fees | nil | The phrase does not occur in any vendor or description |
| Charitable-organisation merchant type | Donations and sponsorships | 1,053 txns, $489,316 | Professional bodies, not charities. Narrowed into Control 9 |

Several Part I rules cannot be tested from this file at all, because the evidence is not in it:
the three-person sign-off (no approver or accountant field), delivery to a University address,
sales tax, receipt retention, backorders and conflicts of interest.

---

## What Part II establishes

The transaction-level controls work. The $5,000 limit is enforced at the point of sale (33
exceptions in 116,031 transactions, concentrated in two cards that almost certainly hold approved
higher limits) and the MCC block on cash is completely effective (nil exceptions).

The exposure is in the controls no point-of-sale check can enforce — those that depend on a person
choosing the right purchasing route. Recurring supplier spend that should have been competed and put
on a PO (**$6.1m**, Control 13), amounts trimmed to fit under the ceiling (**$886k**, Control 14),
and prohibited categories bought openly (alcohol, fuel, internal OSU units) are all invisible to a
card system that only sees one transaction at a time. That is where the audit hours belong.

Two method points carry beyond this case. Keyword tests need word boundaries — `%ATM%` matched
"treatment". And merchant category codes describe the merchant, not the purchase: the same code
covers a tank of petrol and a $46,000 facilities fuel account, a bereavement bouquet and a pallet of
nursery stock, a charity and a fire-code publisher. Every MCC-based population here needed a second
dimension — amount, frequency or vendor — before it meant anything.
