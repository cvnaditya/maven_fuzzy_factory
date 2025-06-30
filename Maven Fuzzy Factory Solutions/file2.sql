-- Final Course Project

/* Question 01 : First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter 
for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it. */

select
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
	count(distinct website_sessions.website_session_id) as total_sessions,
    count(distinct orders.order_id) as total_orders
from website_sessions
left join orders
	on website_sessions.website_session_id=orders.website_session_id
group by 1,2
order by 1,2;

/* Question 02: Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we 
launched, for session-to-order conversion rate, revenue per order, and revenue per session. */

select
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
	-- count(distinct website_sessions.website_session_id) as total_sessions,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate,
    sum(price_usd)/count(distinct orders.order_id) as rev_per_orders,
    sum(price_usd)/count(distinct website_sessions.website_session_id) as rev_per_session
from website_sessions
left join orders
	on website_sessions.website_session_id=orders.website_session_id
group by 1,2
order by 1,2;


/* Question 03: I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch 
nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in? */

select
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
    count(distinct case when utm_source = 'gsearch' and utm_campaign='nonbrand' then orders.order_id else null end) as Gsearch_nonbrand_orders,
	count(distinct case when utm_source = 'bsearch' and utm_campaign='nonbrand' then orders.order_id else null end) as Bsearch_nonbrand_orders,
	count(distinct case when utm_campaign='brand' then orders.order_id else null end) as Brand_overall_orders,
	count(distinct case when utm_source is NULL and http_referer is NULL then orders.order_id else null end) as direct_type_in_orders,
	count(distinct case when utm_source is NULL and http_referer in('https://www.gsearch.com', 'https://www.bsearch.com') then orders.order_id else null end) as Organic_search_orders
from website_sessions
		left join orders
			on website_sessions.website_session_id=orders.website_session_id
	group by 1,2
    order by 1,2;
    
    
/* Question 04: Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. 
Please also make a note of any periods where we made major improvements or optimizations.*/

select
	year(website_sessions.created_at) as yr,
    quarter(website_sessions.created_at) as qtr,
    count(distinct case when utm_source = 'gsearch' and utm_campaign='nonbrand' then orders.order_id else null end)
			/count(distinct case when utm_source = 'gsearch' and utm_campaign='nonbrand' then website_sessions.website_session_id else null end) as Gsearch_nonbrand_conv,
	count(distinct case when utm_source = 'bsearch' and utm_campaign='nonbrand' then orders.order_id else null end)
			/count(distinct case when utm_source = 'bsearch' and utm_campaign='nonbrand' then website_sessions.website_session_id else null end) as Bsearch_nonbrand_conv,
	count(distinct case when utm_campaign='brand' then orders.order_id else null end)/
			count(distinct case when utm_campaign='brand' then website_sessions.website_session_id else null end) as Brand_overall_conv,
	count(distinct case when utm_source is NULL and http_referer is NULL then orders.order_id else null end)
			/count(distinct case when utm_source is NULL and http_referer is NULL then website_sessions.website_session_id else null end) as direct_type_in_conv,
	count(distinct case when utm_source is NULL and http_referer in('https://www.gsearch.com', 'https://www.bsearch.com') then orders.order_id else null end)
			/count(distinct case when utm_source is NULL and http_referer in('https://www.gsearch.com', 'https://www.bsearch.com') then website_sessions.website_session_id else null end) as Organic_search_conv
from website_sessions
		left join orders
			on website_sessions.website_session_id=orders.website_session_id
	group by 1,2
    order by 1,2;

/* Question 05: We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality */

select 
	year(created_at) as yr,
    month(created_at) as mon,
    sum(case when product_id=1 then price_usd else null end) as mrfuzzy_rev,
    sum(case when product_id=1 then price_usd-cogs_usd else null end) as mrfuzzy_marg,
    sum(case when product_id=2 then price_usd else null end) as lovebear_rev,
    sum(case when product_id=2 then price_usd-cogs_usd else null end) as lovebear_marg,
	sum(case when product_id=3 then price_usd else null end) as birthdaybear_rev,
	sum(case when product_id=3 then price_usd-cogs_usd else null end) as birthdaybear_marg,
    sum(case when product_id=4 then price_usd else null end) as minibear_rev,
    sum(case when product_id=4 then price_usd-cogs_usd else null end) as minibear_marg,
    sum(price_usd) as total_revenue,
    sum(price_usd-cogs_usd) as total_margin
from order_items
group by 1,2
order by 1,2
;

/* Question 06: Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products 
page, and show how the % of those sessions clicking through another page has changed over time, along with 
a view of how conversion from /products to placing an order has improved */

create temporary table product_pageviews
select 
	website_session_id,
    website_pageview_id,
    created_at as product_page_seen_at
from website_pageviews
where pageview_url='/products';
    
-- select*from product_pageviews

select 
	year(product_page_seen_at) as yr,
    month(product_page_seen_at) as mon,
    count(distinct product_pageviews.website_session_id) as sessions_to_product_page,
    count(distinct website_pageviews.website_session_id) as clicked_to_next_page,
    count(distinct website_pageviews.website_session_id)/count(distinct product_pageviews.website_session_id) as clickthru_rt,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct product_pageviews.website_session_id) as product_to_order_rt
from product_pageviews
	left join website_pageviews
		on website_pageviews.website_session_id=product_pageviews.website_session_id
        and website_pageviews.website_pageview_id>product_pageviews.website_pageview_id
	left join orders
		on orders.website_session_id=product_pageviews.website_session_id
group by 1,2;


/* Question 07: We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell 
item). Could you please pull sales data since then, and show how well each product cross-sells from one another? */

create temporary table primary_products
select
	order_id,
    primary_product_id,
    created_at as ordered_at
from orders
where created_at>'2014-12-05'   -- when the 4th product was added 
;
-- select*from primary_products

select 
	primary_product_id,
    count(distinct order_id) as total_orders,
    count(distinct case when cross_sell_product_id=1 then order_id else null end) as _xsold_p1,
    count(distinct case when cross_sell_product_id=2 then order_id else null end) as _xsold_p2,
    count(distinct case when cross_sell_product_id=3 then order_id else null end) as _xsold_p3,
    count(distinct case when cross_sell_product_id=4 then order_id else null end) as _xsold_p4,
    count(distinct case when cross_sell_product_id=1 then order_id else null end)/count(distinct order_id) as p1_xsell_rt,
    count(distinct case when cross_sell_product_id=2 then order_id else null end)/count(distinct order_id) as p2_xsell_rt,
    count(distinct case when cross_sell_product_id=3 then order_id else null end)/count(distinct order_id) as p3_xsell_rt,
    count(distinct case when cross_sell_product_id=4 then order_id else null end)/count(distinct order_id) as p4_xsell_rt
from 
	(
		select
			primary_products.*,
			order_items.product_id as cross_sell_product_id
		from primary_products
			left join order_items
				on order_items.order_id=primary_products.order_id
                and order_items.is_primary_item=0 -- only bringing in cross-sells;
		) as primary_w_cross_sell
	group by 1;