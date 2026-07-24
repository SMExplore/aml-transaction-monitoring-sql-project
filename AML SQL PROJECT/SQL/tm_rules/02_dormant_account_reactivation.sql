----shortlist customers who did not have any activity in past 180 days
with shortlist_cust as ( 
						select 
						sub1.customer_id,
						sub1.transaction_datetime,
						sub1.last_trx_dt,
						sub1.transaction_datetime - sub1.last_trx_dt as time_since_lst_trx 
						
						from ( select 
								customer_id,
								transaction_datetime,
								lag(transaction_datetime,1 ) over(partition by customer_id order by transaction_datetime ) as last_trx_dt 
								
							   from transactions 
							) sub1 
							
						where sub1.last_trx_dt is not null and sub1.transaction_datetime - sub1.last_trx_dt > interval '180 days' 
						order by 4 desc
						)
----from such customers select those who showed high volume or trx count in the next 30 days after activation.
----and enrich details about those customers 

select 
	t.customer_id,
	sum(t.amount) as volume,
	count(t.amount) as trx_count,
	c.customer_type,
	c.country,
	c.risk_rating,
	c.annual_income,
	c.expected_transaction_count,
	c.expected_monthly_volume,
	sum(t.amount)/c.expected_monthly_volume as volume_multiple,
	sc.transaction_datetime as reactivation_date,
	sc.transaction_datetime - sc.last_trx_dt as delay

from transactions t 
right join shortlist_cust sc 
on t.customer_id = sc.customer_id 

join customers c
on t.customer_id = c.customer_id 

where t.transaction_datetime < sc.transaction_datetime + interval '30 days' and t.transaction_datetime >= sc.transaction_datetime  

group by 1,4,5,6,7,8,9,11,12 

having sum(t.amount) > 2 * c.expected_monthly_volume or sum(t.amount) > c.annual_income or (sc.transaction_datetime - sc.last_trx_dt > interval'300 days')

order by 1, 2 desc

  

