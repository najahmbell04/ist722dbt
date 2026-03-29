
    
    

select
    employeekey as unique_field,
    count(*) as n_records

from analytics.dbt_nbell_northwind.dim_employee
where employeekey is not null
group by employeekey
having count(*) > 1


