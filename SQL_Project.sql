--Who is the senior most employee a/c job title ?

select * from employee
order by levels desc
limit 1

--Which countries have the most invoices ?

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

--What are top 3 values of total invoices ?

select total from invoice
order by total desc
limit 3

--Which city has the best customers ? We would like to throw a promotional music festival in the city
--We made the most money, Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city names & sum of all invoice totals

select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc

--Who is the best customer ? The customer who has spent the most money will be declared as the best customer
--Write a query that returns the person who has spent the most money

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

--Write a query to return the email, first name, last name & genre of all rock music listeners.
--Return your list ordered alphabetically by email starting with A

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
	Select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
Order by email ASC;

--Lets invite the artist who have written the most rock music in our dataset.
--Write a query that returns the Artist name and total track count of the top 10 rock bands.

select artist.artist_id, artist.name, count(artist.artist_id) as total_no_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by total_no_of_songs desc
limit 10

--Return all the track name that have a song length longer than average song length.
--Return the name and milliseconds for each track.
--Order by the song length with the longest songs listed first.

select name, milliseconds
from track
where milliseconds > (
	select AVG(milliseconds) as average_track_length
	from track
)
order by milliseconds desc

--Find how much amount spent by each customer on artists ?
--Write a query to return customer name, artist name and total spent.

With best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, 
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1  -- 1 means artist_id
	order by 3 desc -- 3 means total_sales
	limit 1)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id	
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--We want to find out most popular genre for each country
--(we determine the most popular genre as the genre with the highest amount of purchases)

With popular_genre as
(
	select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(Partition by customer.country order by count(invoice_line.quantity) desc) as RowNO
	From invoice_line
	join invoice ON invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)

Select * from popular_genre where RowNo <= 1

