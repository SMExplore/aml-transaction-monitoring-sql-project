with high_incoming as(
select
	c.customer_id ,
	count(distinct t.counterparty_id) as in_unq_ctrparty,
	sum(t.amount) as in_total_volume,
	count(*) as in_trx_no
from customers c 
join transactions t
on c.customer_id = t.customer_id
where t.direction = 'IN'
group by c.customer_id
having  count(distinct t.counterparty_id) >= 10
and sum(t.amount) > 5 * c.annual_income
)

select
	h.customer_id,
	h.in_unq_ctrparty,
	h.in_total_volume,
	h.in_trx_no,
	sum(t.amount) as out_total_volume,
	count(distinct t.counterparty_id) as out_unq_ctrparty,
	c.country,
	c.customer_type,
	c.annual_income,
	c.risk_rating
from high_incoming h
join transactions t
on t.customer_id = h.customer_id
join customers c
on h.customer_id = c.customer_id
where t.direction = 'OUT'
group by 1,2,3,4,7,8,9,10
having h.in_total_volume > sum(t.amount) and sum(t.amount) > 0.80 * h.in_total_volume   
order by 2 desc

