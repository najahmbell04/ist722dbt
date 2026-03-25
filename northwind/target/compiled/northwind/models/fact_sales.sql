with stg_orders as (
    select
        OrderId as orderid,
        md5(cast(coalesce(cast(CustomerId as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as customerkey,
        md5(cast(coalesce(cast(EmployeeId as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as employeekey,
        replace(to_date(OrderDate)::varchar,'-','')::int as orderdatekey
    from raw.northwind.Orders
),

stg_order_details as (
    select
        OrderId as orderid,
        ProductId as productid,
        Quantity as quantity,
        UnitPrice as unitprice,
        Discount as discount
    from raw.northwind.Order_Details
),

final as (
    select
        o.orderid,
        o.customerkey,
        o.employeekey,
        o.orderdatekey,
        md5(cast(coalesce(cast(od.productid as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as productkey,
        od.quantity,
        od.quantity * od.unitprice as extendedpriceamount,
        (od.quantity * od.unitprice) * od.discount as discountamount,
        (od.quantity * od.unitprice) - ((od.quantity * od.unitprice) * od.discount) as soldamount
    from stg_orders o
    join stg_order_details od 
        on o.orderid = od.orderid
)

select * from final