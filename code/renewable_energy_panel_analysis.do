version 17.0
clear all
set more off

* Set this to the local repository directory.
global project_root "C:/path/to/renewable-energy-panel-analysis"
global raw  "$project_root/data/raw"
global work "$project_root/data/processed"
global out  "$project_root/results"

cap mkdir "$work"
cap mkdir "$out"

cap which esttab
if _rc ssc install estout
cap which winsor2
if _rc ssc install winsor2

* Helper program: import one standard WDI CSV and reshape it to economy-year form.
capture program drop import_wdi
program define import_wdi
    syntax, File(string) Value(string) Save(string)

    import delimited using "`file'", rowrange(5) varnames(5) clear
    drop indicatorname indicatorcode
    capture drop v70 v71

    local year = 1960
    unab yearvars : v5-v69
    foreach var of local yearvars {
        rename `var' value`year'
        local ++year
    }

    reshape long value, i(countrycode) j(year)
    rename value `value'
    keep if inrange(year, 1991, 2022)
    drop if missing(`value')
    isid countrycode year
    keep countryname countrycode year `value'
    save "`save'", replace
end

import_wdi, file("$raw/co2_per_capita.csv")       value(co2_pc)        save("$work/co2.dta")
import_wdi, file("$raw/renewable_share.csv")      value(renew_share)   save("$work/renewable.dta")
import_wdi, file("$raw/services_share.csv")       value(service_share) save("$work/services.dta")
import_wdi, file("$raw/gdp_per_capita_ppp.csv")   value(gdp_pc_ppp)    save("$work/gdp.dta")

* Merge on stable string key plus year; create numeric panel ID only afterward.
use "$work/co2.dta", clear
merge 1:1 countrycode year using "$work/renewable.dta", nogen keep(match)
merge 1:1 countrycode year using "$work/services.dta",  nogen keep(match)
merge 1:1 countrycode year using "$work/gdp.dta",       nogen keep(match)
isid countrycode year
egen country_id = group(countrycode), label
xtset country_id year

* Transformations.
replace renew_share = 0.001 if renew_share == 0
gen ln_co2    = ln(co2_pc)
gen ln_renew  = ln(renew_share)
gen ln_service = ln(service_share)
gen ln_gdp    = ln(gdp_pc_ppp)
drop if missing(ln_co2, ln_renew, ln_service, ln_gdp)
save "$work/analysis_panel.dta", replace

* Descriptive statistics.
estpost summarize co2_pc renew_share service_share gdp_pc_ppp, detail
esttab using "$out/descriptive_statistics.csv", ///
    cells("count mean sd min p50 max") replace plain
xtsum co2_pc renew_share service_share gdp_pc_ppp

* Global trends.
preserve
collapse (mean) ln_co2 ln_renew, by(year)
twoway (line ln_co2 year, lcolor(navy)) ///
       (line ln_renew year, lcolor(maroon) yaxis(2)), ///
       title("Global Trends: CO2 and Renewable Energy") ///
       xtitle("Year") ytitle("Ln(CO2 per capita)") ///
       ytitle("Ln(Renewable share)", axis(2)) ///
       legend(order(1 "CO2" 2 "Renewable"))
graph export "$out/global_trends.png", replace width(2000)
restore

* Baseline country fixed-effects models with country-clustered standard errors.
xtreg ln_co2 ln_renew, fe vce(cluster country_id)
estimates store fe1
xtreg ln_co2 ln_renew ln_service, fe vce(cluster country_id)
estimates store fe2
xtreg ln_co2 ln_renew ln_service ln_gdp, fe vce(cluster country_id)
estimates store fe3
esttab fe1 fe2 fe3 using "$out/baseline_models.csv", replace plain ///
    star(* 0.10 ** 0.05 *** 0.01) stats(N r2_w)

* Correct panel lags: L. and L2. respect gaps in the yearly panel.
xtreg ln_co2 L.ln_renew ln_service ln_gdp, fe vce(cluster country_id)
estimates store lag1
xtreg ln_co2 L2.ln_renew ln_service ln_gdp, fe vce(cluster country_id)
estimates store lag2
esttab lag1 lag2 using "$out/lag_models.csv", replace plain ///
    mtitles("One-year lag" "Two-year lag") stats(N r2_w)

* Exploratory income heterogeneity based on each entity's sample-period mean GDP.
bys country_id: egen mean_gdp = mean(gdp_pc_ppp)
egen income_cut = median(mean_gdp)
gen high_income = mean_gdp > income_cut
xtreg ln_co2 ln_renew ln_service ln_gdp if high_income == 0, fe vce(cluster country_id)
estimates store lower_income
xtreg ln_co2 ln_renew ln_service ln_gdp if high_income == 1, fe vce(cluster country_id)
estimates store higher_income

* Exploratory renewable-penetration heterogeneity; not a formal threshold estimator.
bys country_id: egen mean_renew = mean(renew_share)
egen renew_cut = median(mean_renew)
gen high_renew = mean_renew > renew_cut
xtreg ln_co2 ln_renew ln_service ln_gdp if high_renew == 0, fe vce(cluster country_id)
estimates store low_renew
xtreg ln_co2 ln_renew ln_service ln_gdp if high_renew == 1, fe vce(cluster country_id)
estimates store high_renew
esttab low_renew high_renew using "$out/penetration_groups.csv", replace plain ///
    mtitles("Low penetration" "High penetration") stats(N r2_w)

* Quadratic exploratory model. Interpret a turning point only if nonlinear terms
* are jointly supported; the original course result did not satisfy this condition.
gen ln_renew_sq = ln_renew^2
xtreg ln_co2 ln_renew ln_renew_sq ln_service ln_gdp, fe vce(cluster country_id)
test ln_renew ln_renew_sq
display "Candidate turning point = " exp(-_b[ln_renew] / (2 * _b[ln_renew_sq]))

* Winsorization sensitivity check on a preserved copy.
preserve
winsor2 co2_pc renew_share service_share gdp_pc_ppp, cuts(1 99) replace
replace renew_share = 0.001 if renew_share == 0
replace ln_co2     = ln(co2_pc)
replace ln_renew   = ln(renew_share)
replace ln_service = ln(service_share)
replace ln_gdp     = ln(gdp_pc_ppp)
xtreg ln_co2 ln_renew ln_service ln_gdp, fe vce(cluster country_id)
estimates store winsorized
restore

esttab fe3 lag1 lag2 winsorized using "$out/robustness_models.csv", replace plain ///
    mtitles("Baseline" "Lag 1" "Lag 2" "Winsorized") stats(N r2_w)

display "Analysis complete. Results saved in $out."

