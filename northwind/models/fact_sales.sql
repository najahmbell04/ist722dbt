with stg_orders as (
    select
        OrderId as orderid,
        {{ dbt_utils.generate_surrogate_key(['CustomerId']) }} as customerkey,
        {{ dbt_utils.generate_surrogate_key(['EmployeeId']) }} as employeekey,
        replace(to_date(OrderDate)::varchar,'-','')::int as orderdatekey
    from {{ source('northwind','Orders') }}
),

stg_order_details as (
    select
        OrderId as orderid,
        ProductId as productid,
        Quantity as quantity,
        UnitPrice as unitprice,
        Discount as discount
    from {{ source('northwind','Order_Details') }}
),

final as (
    select
        o.orderid,
        o.customerkey,
        o.employeekey,
        o.orderdatekey,
        {{ dbt_utils.generate_surrogate_key(['od.productid']) }} as productkey,
        od.quantity,
        od.quantity * od.unitprice as extendedpriceamount,
        (od.quantity * od.unitprice) * od.discount as discountamount,
        (od.quantity * od.unitprice) - ((od.quantity * od.unitprice) * od.discount) as soldamount
    from stg_orders o
    join stg_order_details od 
        on o.orderid = od.orderid
)

select * from final