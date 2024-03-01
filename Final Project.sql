-- 1. Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi paling besar? 

select 
    EXTRACT(MONTH from order_date) as bulan,
    sum(after_discount) as total_transaksi_terbesar
from 
    order_detail
where 
    EXTRACT(YEAR from order_date) = 2021
    and is_valid = 1
GROUP by 
    bulan
order by 
    total_transaksi_terbesar DESC
limit 1   

-- 2. Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar? 

SELECT
    sd.category,
    sum(od.after_discount) as total_transaksi_terbesar
from 
    order_detail as od
    join sku_detail as sd 
    on od.sku_id = sd.id
WHERE
    EXTRACT(year from od.order_date) = 2022
    and is_valid = 1
GROUP by 
    sd.category
order by 
    total_transaksi_terbesar DESC
limit 1

-- 3. Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022.
--    Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami
--    penurunan nilai transaksi dari tahun 2021 ke 2022. 

with transaksiperkategori as (
  SELECT 
  	sd.category,
  	extract (year from od.order_date) as tahun,
  	round(sum(od.after_discount * od.qty_ordered) :: NUMERIC, 0) as total_transaksi
  from 
  	order_detail as od
  	INNER join sku_detail as sd
  	on od.sku_id = sd.id
  where 
  	od.is_valid = 1
    	and EXTRACT(year from od.order_date) in (2021, 2022)
  GROUP by 1, 2
)
  
 SELECT
    category,
    max(case when tahun = 2021 then total_transaksi end) as total_2021,
    max(case when tahun = 2022 then total_transaksi end) as total_2022,
    case 
    	when max(case when tahun = 2022 then total_transaksi end) > 
             max(case when tahun = 2021 then total_transaksi end) then 'peningkatan'
        when max(case when tahun = 2022 then total_transaksi end) <
             max(case when tahun = 2021 then total_transaksi end) then 'penurunan'
        else 'Tetap'
        end as status_perubahan
  from transaksiperkategori
  group by category
  order by status_perubahan ASC;
    
-- 4. Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022

select 
    pd.id,
    pd.payment_method,
    count(DISTINCT od.id) as total_payment

from 
    order_detail as od
    join payment_detail as pd
    on od.payment_id = pd.id
where 
    od.is_valid = 1
    and extract(year from od.order_date) = '2022'
group by 1, 2
order by 3 DESC
limit 5

-- 5. Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
--    1. Samsung
--    2. Apple
--    3. Sony
--    4. Huawei
--    5. Lenovo

with product_sales as (
select 
  case 
  	when lower(sd.sku_name) like lower('%Samsung%') then 'Samsung'
  	when lower(sd.sku_name) like lower('%Apple%') then 'Apple'
 	when lower(sd.sku_name) like lower('%Iphone%') then 'Apple'
  	when lower(sd.sku_name) like lower('%Macbook%') then 'Apple'
  	when lower(sd.sku_name) like lower('%Ipad%') then 'Apple'
  	when lower(sd.sku_name) like lower('%Sony%') then 'Sony'
  	when lower(sd.sku_name) like lower('%Huawei%') then 'Huawei'
  	when lower(sd.sku_name) like lower('%Lenovo%') then 'Lenovo'
  	end as product_category,
  	sum(od.after_discount) as total_sales
FROM 
  order_detail as od
  join sku_detail as sd
  on od.sku_id = sd.id
where 
  od.is_valid = 1           
group by 
  case 
  	when lower(sd.sku_name) like lower('%Samsung%') then 'Samsung'
  	when lower(sd.sku_name) like lower('%Apple%') then 'Apple'
 	when lower(sd.sku_name) like lower('%Iphone%') then 'Apple'
  	when lower(sd.sku_name) like lower('%Macbook%') then 'Apple'
  	when lower(sd.sku_name) like lower('%Ipad%') then 'Apple'
  	when lower(sd.sku_name) like lower('%Sony%') then 'Sony'
  	when lower(sd.sku_name) like lower('%Huawei%') then 'Huawei'
  	when lower(sd.sku_name) like lower('%Lenovo%') then 'Lenovo'
  	END
 )
	
SELECT
*
from 
	product_sales 
where product_category is not NULL
order by total_sales DESC
