# Data instructions

Download the following four CSV files from the World Bank indicator pages and save them in `data/raw/` using these names:

| Filename | Indicator |
|---|---|
| `co2_per_capita.csv` | `EN.GHG.CO2.PC.CE.AR5` |
| `renewable_share.csv` | `EG.FEC.RNEW.ZS` |
| `services_share.csv` | `NV.SRV.TOTL.ZS` |
| `gdp_per_capita_ppp.csv` | `NY.GDP.PCAP.PP.CD` |

Indicator pages:

- https://data.worldbank.org/indicator/EN.GHG.CO2.PC.CE.AR5
- https://data.worldbank.org/indicator/EG.FEC.RNEW.ZS
- https://data.worldbank.org/indicator/NV.SRV.TOTL.ZS
- https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.CD

Choose **Download data -> CSV** on each page. World Bank CSV exports sometimes contain metadata rows before the header. The do-file expects the standard WDI export layout and imports from row 5.

Raw data are excluded from the portfolio package to keep the repository lightweight and to direct users to the authoritative source.

