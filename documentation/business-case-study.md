# Business case study — Credit Monitoring BI Analytics

## Context and analytical approach

The problem is not merely to report a credit balance: portfolio monitoring requires a consistent snapshot, comparable measures, drill-down dimensions, and controls to identify when the data cannot support a confident decision. This case study uses **1 November 2026** as the main reporting snapshot and compares September and October where useful. All financial values are anonymised/synthetic local-currency-unit amounts.

## 1. Exposure composition and movement

| Snapshot | Facility rows | Distinct accounts | Exposure (LCY) |
|---|---:|---:|---:|
| 2026-09-01 | 7,913 | 3,926 | 3,333,245,492.35 |
| 2026-10-01 | 7,889 | 3,702 | 3,199,404,549.28 |
| 2026-11-01 | 4,921 | 3,112 | 1,582,246,828.01 |

November direct exposure is **1,505,062,889.33**; contingent is **77,183,938.68**. October–November net change is **−1,617,157,721.27 (−50.55%)**. The account/type bridge decomposes this into missing direct combinations **−1,679,518,507.14**, new direct combinations **+363,948,647.35**, continuing direct combinations **−292,399,975.18**, and continuing contingent combinations **−9,187,886.30**. These are account/type combinations, not independently verified facility closures or repayments. Synthetic transformations may affect comparability.

**Business use:** investigate source-population shifts before declaring improvement in exposure or credit risk.

## 2. Customer concentration

The top ten anonymised customer keys total approximately **73.82m LCY**, or **4.67%** of total exposure; the largest is **13.92m (0.88%)**. This measures individual surrogate-key concentration, not connected-party, sector or group concentration. Customer mapping uses `FactFacilityDetails.CustomerALTKey = DimCustomerALT.CustomerKey`, not the placeholder `FactFacilityDetails.CustomerKey`. All 4,921 November fact rows match dimension keys; one uses the `-1` placeholder with **309,626.02 LCY**.

**Business use:** rank large obligors for further review; do not infer low connected-borrower concentration from this result.

## 3. Delinquency and IFRS classification

| Delinquency | Rows | Exposure LCY | Share of combined portfolio |
|---|---:|---:|---:|
| Current | 1,295 | 370,831,214.51 | 23.44% |
| 1–30 days | 102 | 25,815,168.53 | 1.63% |
| 31–60 days | 124 | 32,631,641.31 | 2.06% |
| 61–90 days | 104 | 26,674,221.08 | 1.69% |
| >90 days | 1,117 | 326,364,807.83 | 20.63% |
| Unknown | 2,179 | 799,929,774.75 | 50.56% |

All 113 contingent records have missing overdue days; direct exposure has **2,066 missing-overdue rows**, representing **722,745,836.07 LCY**. Within direct exposure, 537 IFRS Stage 1 rows have >90 overdue days, representing **166,584,758.84 LCY**. A further 556 unclassified direct rows have >90 overdue days, representing **152,684,935.37 LCY**. Direct Stage 3 exposure is **26,748,949.51 LCY**, but this is **not** equivalent to the official NPL measure. IFRS 9 staging depends on more than overdue days; the synthetic date/classification transformations may create apparent conflicts.

**Business use:** produce exception queues and data-quality alerts; do not publish an unvalidated IFRS/prudential NPL ratio.

## 4. Impairment

November impairment totals **31,216,491.36 LCY** (direct **29,694,895.19**, contingent **1,521,596.17**). Values are approximately 2% of exposure across many segments, suggesting a possible synthetic allocation rule. Do not present them as validated IFRS 9 ECL, provisions saved, or realised losses.

## 5. Credit limits

In direct exposure, **2,732** rows fall below 50% utilisation, **1,984** between 50% and 80%, **zero** between 80% and 100%, and **92** above 100%. These 92 direct rows carry **206,861,667.52 LCY** exposure and **204,135,460.96 LCY** principal; their indicative excess above limits is **146,578,060.96 LCY**. A further **27 contingent** rows have principal above limit, with indicative excess **40,305,364.26 LCY**. These are exploratory comparisons of synthetic balances and recorded limits, not confirmed policy breaches. The empty 80–100% band is itself a synthetic-data caveat.

## 6. Repayment obligations

| Measure | Direct LCY | Contingent LCY |
|---|---:|---:|
| Principal outstanding | 1,484,744,748.60 | 76,079,807.10 |
| Amount due | 139,149,349.99 | 2,962,713.43 |
| Unsettled principal | 48,486,656.00 | 1,030,856.00 |
| Unsettled interest | 17,932,709.99 | 385,573.43 |
| Total unsettled | 75,519,826.73 | 3,863,301.58 |
| Scheduled principal | 121,216,640.00 | 2,577,140.00 |
| Settled principal | 72,729,984.00 | 1,546,284.00 |

Scheduled principal minus settled principal equals unsettled principal in both exposure types. However, stored total unsettled exceeds unsettled principal plus interest by **9,100,460.74 direct** and **2,446,872.15 contingent**, combined **11,547,332.89 LCY**. All 119 rows with a difference are above their recorded limit; no below-limit rows have a material difference. This is a **perfect observed association in the snapshot**, not proof of the source formula. The indicative principal-above-limit excess is much larger than the unsettled difference.

## 7. Maturity

| Maturity category | Direct LCY | Contingent LCY |
|---|---:|---:|
| Past maturity | 503,933,616.73 | 30,040,907.62 |
| 0–30 days | 36,766,835.05 | 3,335,049.83 |
| 31–90 days | 86,815,916.41 | 7,466,565.15 |
| 91–180 days | 115,706,778.49 | 6,059,362.28 |
| 181–365 days | 256,272,031.44 | 30,282,053.80 |
| Unknown | 505,567,711.21 | 0 |

Combined past-maturity exposure is **533.97m LCY**; unknown maturity is **505.57m LCY**. Exposure scheduled within 90 days (excluding already past maturity) is **134.38m LCY**. Synthetic dates and derived days-to-maturity must be checked for consistency before treating these as contractual maturity facts.

## 8. Collections

November collections has **3,302 records**, **2,994 distinct accounts**, and **1,662,173,470.10 LCY** principal outstanding. The stored 3-, 6-, and 12-month collection amounts are **99,730,409.43**, **199,460,818.86**, and **398,921,637.72 LCY**. They differ from fixed 6%, 12%, and 24% of principal by only **1.224**, **2.448**, and **4.896 LCY** respectively. This is strong evidence of modelled or synthetically generated amounts; **do not call them observed recoveries**. Collections-fact principal exceeds facility-fact principal by approximately **101.35m LCY**, but populations and grains differ, so direct reconciliation is not valid without an account-level mapping.

## Data quality and model safeguards

- Reporting snapshot: always filter `ProcessingDateKey`; never sum multiple snapshots as one current balance.
- Dimension matching: `FacilityDetailKey → DimFacility.FacilityKey` matches 4,921/4,921 November rows, but no SQL foreign-key constraint was returned. Verify SSAS/ETL semantics.
- Customer matching: `CustomerALTKey → DimCustomerALT.CustomerKey` matches 4,921/4,921; one unknown surrogate `-1` is still a business-level unknown.
- Nulls: preserve unknown overdue and maturity statuses rather than coalescing to zero.
- NPL: retain the semantic model's existing measures, but do not assert that their regulatory definitions have been validated.
- Privacy: publish aggregates and redacted screenshots only; do not commit raw PII, customer identifiers, credentials or proprietary source data.

## Interview-ready Problem → Action → Result

**Problem:** Credit exposure, delinquency, limits, repayment obligations and maturity need consistent portfolio-level visibility, while raw totals can conceal exceptions and inconsistent reporting populations.

**Action:** Built and analysed a SQL Server dimensional credit-monitoring warehouse, exposed reusable measures through SSAS Tabular, developed Power BI reporting, and implemented snapshot reconciliation and exception checks across customer mappings, overdue classification, limit utilisation and unsettled obligations.

**Result:** Produced a reproducible synthetic portfolio analysis reconciling **1.582bn LCY** of November exposure, decomposing a **50.55%** snapshot movement, identifying **119** indicative above-limit rows and **11.55m LCY** in related unsettled-balance differences, while documenting material data-quality and anonymisation limitations. These are **analytical outputs**, not measured business savings.
