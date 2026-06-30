1. Initial Rule

- Dormancy >180 days
- Review customer activity within 30 days of reactivation
- Alert if:
  - Transaction Volume > 2 × Expected Monthly Volume, OR
  - Dormancy Period > 300 Days

2. Threshold Experiments

| Version | Change Tested | Alerts Generated |Reduction vs Baseline| Comments |
| :--- | :---: | ---: | :--- | :---: |
|V1|Dormancy > 180 days|11|-|Baseline rule capturing all qualifying reactivation events.|
|V2|Dormancy > 270 days|9|18.2%|Reduced alert population but excluded a customer with multiple dormant periods and another exhibiting a 23× volume multiple.|
|V3|Dormancy > 365 days|7|36.4%|Further reduced alerts but excluded a High-risk customer together with another significant behavioural outlier.|

Insight: The dormancy threshold had a direct impact on alert generation. Increasing the threshold reduced alert volume but also removed customers demonstrating potentially meaningful behavioural changes. Based on the current dataset, 180 days provided the best balance between alert coverage and investigation quality.

| Version | Change Tested | Alerts Generated |Reduction vs Previous| Comments |
| :--- | :---: | ---: | :--- | :---: |
|V1|> 3 * expected monthly volume|11|-|Baseline production threshold.|
|V2|> 3 * expected monthly volume|11|0%|No change in alert population.|
|V3|> 3 * expected monthly volume|11|0%|No change in alert population. Customers continued to qualify through either exceptionally high transaction volumes or the prolonged dormancy condition (>300 days).|

Insight: Increasing the reactivation volume threshold from 2× to 5× Expected Monthly Volume did not reduce the alert population. This indicates that, within the current dataset, the shortlisted customers already exhibited substantial deviations from expected behaviour or continued to qualify through the alternative prolonged dormancy condition (>300 days). Consequently, the volume threshold was not the primary driver of alert generation.

3. Rule Tuning Summary

|Parameter Tested|Impact|Assessment|
|:---|:---|:---|
|Dormancy Threshold|High|Primary tuning parameter influencing alert volume and sensitivity.|
|Reactivation Volume Multiple|Low|Minimal impact under the current rule logic due to the alternative prolonged dormancy condition.|

4. Recommended Production Rule : Keep same

5. Key Learning

This tuning exercise demonstrated that not all thresholds contribute equally to rule optimisation. While increasing the dormancy threshold reduced alert volume, it also excluded customers exhibiting significant behavioural changes. In contrast, increasing the reactivation volume threshold from 2× to 5× Expected Monthly Volume had no measurable impact because the alert population was primarily driven by the prolonged dormancy condition and customers already exhibiting substantial volume deviations.

The results indicate that, for this rule, the dormancy threshold is the primary optimisation lever, while further improvements are more likely to come from refining the interaction between rule conditions or introducing additional behavioural indicators rather than increasing the volume threshold alone.


