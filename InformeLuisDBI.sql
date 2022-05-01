--Consultas
--i. Edad promedio de los clientes
select avg(DATEDIFF(YEAR,fecha_nacimento,GETDATE())) as Promedio_Edad from clientes

-- ii. 10 productos más vendidos
select top 10 fk_idproducto, sum(cantidad)Cantidad from compradetalle group by fk_idproducto order by sum(cantidad)  desc

-- iii. Cantidad de productos por categoría
select cat.nombre, sum(cantidad)Cantidad from inventario iv
inner join productos pr on iv.fk_idproducto=pr.idproducto
inner join categoria cat on cat.idcategoria=pr.fk_idcategoria
group by cat.nombre

-- iv. Listar los productos más bajos en ventas
select top 10 fk_idproducto, sum(cantidad)Cantidad from compradetalle group by fk_idproducto order by sum(cantidad)  asc

-- v. Listado de productos agrupados por categoría
select cat.nombre, count(*) Cantidad from  productos pr 
inner join categoria cat on cat.idcategoria=pr.fk_idcategoria
group by cat.nombre


--Vistas
-- i. Reporte mensual de ventas por sucursal
create view VW_Ventas_Sucursal 
as
select s.nombre, sum(total) total_ventas from compra c
inner join sucursal s on s.idsucursal=c.fk_idsucursal
group by s.nombre

select * from VW_Ventas_Sucursal

-- ii. Reporte de ventas mensual por producto
create view VW_Ventas_Producto
as
select p.nombre, sum(cantidad) total_ventas from compra c
inner join compradetalle cd on cd.fk_idcliente=c.fk_idcliente and cd.fk_idcompra=c.idcompra
inner join productos p on p.idproducto=cd.fk_idproducto
group by p.nombre

select * from VW_Ventas_Producto

-- iii. Total ventas por categoría
create view VW_Ventas_Categoria
as
select cat.nombre, sum(cantidad) total_ventas from compra c
inner join compradetalle cd on cd.fk_idcliente=c.fk_idcliente and cd.fk_idcompra=c.idcompra
inner join productos p on p.idproducto=cd.fk_idproducto
inner join categoria cat on p.fk_idcategoria=cat.idcategoria
group by cat.nombre

select * from VW_Ventas_Categoria

-- iv. Productos en el inventario con cantidad menor que 10 unidades por sucursal
create view VW_Inventario_Menor_10
as
select s.nombre Sucursal, p.nombre Producto, sum(inv.cantidad)Cantidad from inventario inv
inner join productos p  on p.idproducto=inv.fk_idproducto
inner join sucursal s on s.idsucursal=inv.fk_idsucursal
group by s.nombre, p.nombre
having sum(inv.cantidad)<10

select * from VW_Inventario_Menor_10

-- v. Listado de clientes que no han realizado ningún pedido durante el mes
create view VM_Clientes_Sin_Pedido as
select nombre, telefono_fijo, telefono_celular, correo from clientes
where idcliente not in (select fk_idcliente from compra where month(fecha_compra)=MONTH(GETDATE()))

select * from VM_Clientes_Sin_Pedido

--c. Procedimientos almacenados
-- i. Función para búsqueda de clientes por nombre

create procedure SP_Buscar_Cliente (@nombre varchar(10))
as
begin
select  nombre, telefono_fijo, telefono_celular, correo from clientes where nombre like '%'+@nombre+'%'
end

execute SP_Buscar_Cliente 'Luis'

-- ii. Eliminar clientes por id
create procedure SP_Eliminar_Cliente (@idcliente int)
as
begin
delete from clientes where idcliente=@idcliente
end

execute SP_Eliminar_Cliente 5

-- iii. Actualizar clientes por id
create procedure SP_Actualizar_Cliente
(@idcliente int, @fk_iddireccion int, @nombre varchar(60), @telefono_fijo varchar(15),
@telefono_celular varchar(15), @correo varchar(30), @fecha_nacimento date,
@usuario varchar(20), @contraseña varchar(100) )
as
begin
update clientes set
fk_iddireccion=@fk_iddireccion, 
nombre=@nombre, 
telefono_fijo=@telefono_fijo,
telefono_celular=@telefono_celular, 
correo=@correo, 
fecha_nacimento=@fecha_nacimento,
usuario=@usuario, 
contraseña=@contraseña 
where idcliente=@idcliente
end

execute SP_Actualizar_Cliente 4, 3, 'Prueba', 'Prueba', 'Prueba', 'Prueba', '29/02/1988', 'Prueba',  'Prueba'

-- iv. Listado de todos los pedidos realizados por un cliente


create procedure SP_Buscar_Pedidos_Cliente (@idcliente int)
as
begin
select c.* from clientes cl
inner join  compra c on cl.idcliente=c.fk_idcliente
where cl.idcliente=@idcliente
end

execute SP_Buscar_Pedidos_Cliente 1

-- v. Total de ventas de un producto en una fecha determinada
create procedure SP_Ventas_Producto (@fechaInicio date, @fechaFin date, @idproducto int)
as
begin
select p.nombre, sum(cd.precio) total_ventas from compra c
inner join compradetalle cd on cd.fk_idcompra=c.idcompra
inner join productos p on p.idproducto=c.fk_idsucursal
where c.fecha_compra between @fechaInicio and @fechaFin and p.idproducto=@idproducto
group by p.nombre
end

execute SP_Ventas_Producto '01/04/2022','30/04/2022', 1