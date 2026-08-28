# Renewable Energy and Carbon Emissions: Global Panel Analysis

An individual Stata project examining how renewable energy consumption is associated with per-capita CO2 emissions across a global panel from 1991 to 2022.

## Project overview

This project demonstrates an end-to-end analytical workflow:

1. Collect four indicators from the World Bank World Development Indicators.
2. Reshape annual country data from wide to long format.
3. Merge the series using country code and year.
4. Validate panel keys and construct analysis variables.
5. Estimate country fixed-effects models with country-clustered standard errors.
6. Explore lagged relationships, income-group heterogeneity, winsorized samples, and nonlinear specifications.
7. Translate statistical results into a concise research report.

## Research question

How is renewable energy consumption associated with per-capita CO2 emissions after accounting for economic development and time-invariant country characteristics?

## Data

Source: World Bank World Development Indicators (WDI)

| Variable | WDI indicator | Role |
|---|---|---|
| CO2 emissions per capita | `EN.GHG.CO2.PC.CE.AR5` | Outcome |
| Renewable energy consumption (% of total final energy consumption) | `EG.FEC.RNEW.ZS` | Main predictor |
| Services value added (% of GDP) | `NV.SRV.TOTL.ZS` | Control |
| GDP per capita, PPP (current international $) | `NY.GDP.PCAP.PP.CD` | Control |

The original complete-case analytical sample contained 6,720 economy-year observations and covered up to 251 World Bank entities. World Bank downloads can include aggregates as well as countries; a production extension would explicitly exclude non-country aggregates.

Raw data are not redistributed in this repository. Download instructions are provided in [`data/README.md`](data/README.md).

## Methods

- Panel construction and key validation
- Descriptive statistics and within/between variation
- Country fixed effects
- Country-clustered robust standard errors
- One- and two-year lag specifications
- Winsorization sensitivity check
- Income-group and renewable-penetration subgroup comparisons
- Quadratic exploratory specification

## Selected findings

- In the fully controlled fixed-effects model, the renewable-energy coefficient was small and statistically insignificant (`0.0129`, `p = 0.411`).
- GDP per capita was positively associated with per-capita CO2 emissions (`0.3710`, `p < 0.001`) in the original analysis.
- The renewable-energy coefficient differed between low- and high-penetration subsamples, but this is an exploratory heterogeneity result rather than proof of a causal threshold.
- The quadratic terms were not statistically significant, so the calculated 2.83% turning point should not be interpreted as an established threshold.

These estimates describe conditional associations and should not be interpreted as causal effects.

## Repository structure

```text
code/
  renewable_energy_panel_analysis.do
data/
  README.md
results/
  baseline_models.csv
  heterogeneity_models.csv
reports/
  Renewable_Energy_Panel_Analysis_Summary.pdf
README.md
```

## How to reproduce

1. Download the four WDI CSV files listed in `data/README.md`.
2. Place and rename them in `data/raw/` as instructed.
3. Open `code/renewable_energy_panel_analysis.do` in Stata.
4. Change the `project_root` global at the top of the file.
5. Run the do-file from beginning to end.

The do-file checks that `countrycode year` uniquely identifies each source dataset before merging and creates the numeric panel ID only after the merge.

## Tools

Stata, panel-data management, fixed-effects regression, data visualization, and research writing.

## Author contribution

Individual course project. I completed the full workflow, including data collection, reshaping, cleaning, merging, model specification, robustness checks, interpretation, and report writing.

## Limitations

- Observational estimates do not establish causality.
- Reverse causality and omitted time-varying variables may remain.
- Entity coverage is unbalanced across years.
- Subgroup splits are descriptive and are not formal panel-threshold estimators.
- A stronger extension would add year fixed effects, exclude World Bank aggregates, and test alternative measures of energy composition.

