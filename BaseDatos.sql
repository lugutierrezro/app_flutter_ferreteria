CREATE DATABASE IF NOT EXISTS railway;
USE railway;

-- Tabla Persona
CREATE TABLE IF NOT EXISTS Persona (
    idPersona INT AUTO_INCREMENT PRIMARY KEY,
    Dni VARCHAR(9) NOT NULL,
    Nombre VARCHAR(30) NOT NULL,
    Apellido VARCHAR(30) NOT NULL,
    Direccion VARCHAR(50),
    Telefono CHAR(9)
);

-- Tabla Proveedor
CREATE TABLE IF NOT EXISTS Proveedor (
    idProveedor INT AUTO_INCREMENT PRIMARY KEY,
    ruc VARCHAR(11) NOT NULL,
    idPersonaProveedor INT NOT NULL,
    FOREIGN KEY (idPersonaProveedor) REFERENCES Persona(idPersona)
);

-- Tabla Cliente
CREATE TABLE IF NOT EXISTS Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    ruc VARCHAR(11),
    idPersonaCliente INT NOT NULL,
    estado VARCHAR(20) DEFAULT 'Habilitado',
    FOREIGN KEY (idPersonaCliente) REFERENCES Persona(idPersona)
);

-- Tabla Rol (nuevo)
CREATE TABLE IF NOT EXISTS Rol (
    idRol INT AUTO_INCREMENT PRIMARY KEY,
    nombreRol VARCHAR(20) NOT NULL UNIQUE
);

-- Tabla EstadoCuenta (nuevo)
CREATE TABLE IF NOT EXISTS EstadoCuenta (
    idEstado INT AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(20) NOT NULL -- Ejemplo: 'Habilitado', 'Deshabilitado'
);

-- Tabla Empleado
CREATE TABLE IF NOT EXISTS Empleado (
    idEmpleado INT AUTO_INCREMENT PRIMARY KEY,
    idPersonaEmpleado INT NOT NULL,
    FOREIGN KEY (idPersonaEmpleado) REFERENCES Persona(idPersona)
);

-- Tabla Usuario (nuevo)
CREATE TABLE IF NOT EXISTS Usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    usuario VARCHAR(20) NOT NULL UNIQUE,
    contraseña VARCHAR(120) NOT NULL,
    idRol INT NOT NULL,
    idEstado INT NOT NULL,
    idEmpleado INT NOT NULL,
    FOREIGN KEY (idRol) REFERENCES Rol(idRol),
    FOREIGN KEY (idEstado) REFERENCES EstadoCuenta(idEstado),
    FOREIGN KEY (idEmpleado) REFERENCES Empleado(idEmpleado)
);

CREATE TABLE IF NOT EXISTS Marca (
    idMarca INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    estado VARCHAR(20) DEFAULT 'Habilitado'
);

-- Tabla Categoria con estado
CREATE TABLE IF NOT EXISTS Categoria (
    idCategoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    estado VARCHAR(20) DEFAULT 'Habilitado'
);

-- Tabla Productos
CREATE TABLE IF NOT EXISTS Productos (
    idProducto VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    precioCompra DECIMAL(8,2) NOT NULL,
    precioVenta DECIMAL(8,2) NOT NULL,
    fechaIngreso DATE,
    fechaVencimiento DATE,
    Cantidad INT DEFAULT 0,
    estado VARCHAR(10) DEFAULT 'activo', -- nuevo campo
    idCategoria INT,
    idMarca INT,
    FOREIGN KEY (idCategoria) REFERENCES Categoria(idCategoria),
    FOREIGN KEY (idMarca) REFERENCES Marca(idMarca)
);


-- Tabla Suministros (Compras)
CREATE TABLE IF NOT EXISTS Suministros (
    idSuministro INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    num_documento VARCHAR(10),
    tipo_documento VARCHAR(10),
    subtotal DECIMAL(8,2),
    igv DECIMAL(8,2),
    total DECIMAL(8,2),
    estado VARCHAR(20),
    idUsuario INT,
    idProveedor INT,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idProveedor) REFERENCES Proveedor(idProveedor)
);

-- Detalle de Compras
CREATE TABLE IF NOT EXISTS detalle_compras (
    idDetalleCompra INT AUTO_INCREMENT PRIMARY KEY,
    idCompra INT NOT NULL,
    idProducto VARCHAR(9) NOT NULL,
    cantidad INT NOT NULL,
    precio DECIMAL(8,2) NOT NULL,
    total DECIMAL(8,2),
    FOREIGN KEY (idCompra) REFERENCES Suministros(idSuministro),
    FOREIGN KEY (idProducto) REFERENCES Productos(idProducto)
);

-- Ventas
CREATE TABLE IF NOT EXISTS ventas (
    idVenta INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    serie VARCHAR(7),
    num_documento VARCHAR(10),
    tipo_documento VARCHAR(10),
    subtotal DECIMAL(8,2),
    igv DECIMAL(8,2),
    total DECIMAL(8,2),
    estado VARCHAR(20),
    idUsuario INT,
    idCliente INT,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente)
);

-- Detalle de Ventas
CREATE TABLE IF NOT EXISTS detalle_ventas (
    idDetalleVenta INT AUTO_INCREMENT PRIMARY KEY,
    idVenta INT NOT NULL,
    idProducto VARCHAR(9) NOT NULL,
    cantidad INT NOT NULL,
    precio DECIMAL(8,2) NOT NULL,
    total DECIMAL(8,2),
    FOREIGN KEY (idVenta) REFERENCES ventas(idVenta),
    FOREIGN KEY (idProducto) REFERENCES Productos(idProducto)
);
/*---Verificacion de inicio de sesion-----*/
DELIMITER //
CREATE PROCEDURE sp_login(
    IN p_usuario VARCHAR(20),
    IN p_password VARCHAR(60)
)
BEGIN
    SELECT 
        u.idUsuario,
        e.idEmpleado,
        p.Nombre,
        p.Apellido,
        r.nombreRol AS Rol,
        ec.estado AS EstadoCuenta
    FROM Usuario u
    JOIN Empleado e            ON u.idEmpleado = e.idEmpleado
    JOIN Persona p             ON e.idPersonaEmpleado = p.idPersona
    JOIN Rol r                 ON u.idRol = r.idRol
    JOIN EstadoCuenta ec       ON u.idEstado = ec.idEstado
    WHERE u.usuario = p_usuario
      AND u.contraseña = p_password
      AND ec.estado = 'Habilitado';
END //
DELIMITER ;

/*Cliente----*/

DELIMITER //

CREATE PROCEDURE sp_guardar_Cliente(
    IN p_nombre VARCHAR(30),
    IN p_apellido VARCHAR(30),
    IN p_dni VARCHAR(9),
    IN p_direccion VARCHAR(50),
    IN p_telefono CHAR(9),
    IN p_ruc VARCHAR(11)
)
BEGIN
    DECLARE persona_id INT DEFAULT 0;
    DECLARE cliente_id INT DEFAULT 0;
    DECLARE mensaje VARCHAR(100);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error al registrar el cliente.' AS mensaje;
    END;

    -- Verificar si la persona ya existe
    SELECT idPersona INTO persona_id
    FROM Persona
    WHERE Dni = p_dni
    LIMIT 1;

    IF persona_id > 0 THEN
        -- Verificar si ya es cliente
        SELECT idCliente INTO cliente_id
        FROM Cliente
        WHERE idPersonaCliente = persona_id
        LIMIT 1;

        IF cliente_id > 0 THEN
            SET mensaje = 'La persona ya está registrada como cliente.';
        ELSE
            INSERT INTO Cliente(ruc, idPersonaCliente)
            VALUES (p_ruc, persona_id);
            SET mensaje = 'Cliente asociado a persona existente.';
        END IF;

    ELSE
        -- Insertar nueva persona y cliente
        START TRANSACTION;

        INSERT INTO Persona(Dni, Nombre, Apellido, Direccion, Telefono)
        VALUES (p_dni, p_nombre, p_apellido, p_direccion, p_telefono);

        INSERT INTO Cliente(ruc, idPersonaCliente)
        VALUES (p_ruc, LAST_INSERT_ID());

        COMMIT;

        SET mensaje = 'Cliente nuevo registrado correctamente.';
    END IF;

    -- Mostrar mensaje final
    SELECT mensaje AS mensaje;

END //

DELIMITER ;



CALL sp_listar_Clientes('');
DELIMITER //
CREATE PROCEDURE sp_listar_Clientes(IN buscar VARCHAR(50))
BEGIN
    SELECT 
        c.idCliente, p.Nombre, p.Apellido, p.Dni, p.Direccion, p.Telefono, c.ruc
    FROM Cliente c
    JOIN Persona p ON c.idPersonaCliente = p.idPersona
    WHERE (p.Nombre LIKE CONCAT('%', buscar, '%')
       OR p.Apellido LIKE CONCAT('%', buscar, '%')
       OR p.Dni LIKE CONCAT('%', buscar, '%')
       OR c.ruc LIKE CONCAT('%', buscar, '%'))
      AND c.estado = 'Habilitado';  -- filtro por estado
END //
DELIMITER ;
/*
DELIMITER //
CREATE PROCEDURE sp_listar_Clientes(IN buscar VARCHAR(50))
BEGIN
    SELECT 
        c.idCliente, p.Nombre, p.Apellido, p.Dni, p.Direccion, p.Telefono, c.ruc
    FROM Cliente c
    JOIN Persona p ON c.idPersonaCliente = p.idPersona
    WHERE p.Nombre LIKE CONCAT('%', buscar, '%')
       OR p.Apellido LIKE CONCAT('%', buscar, '%')
       OR p.Dni LIKE CONCAT('%', buscar, '%')
       OR c.ruc LIKE CONCAT('%', buscar, '%');
END //
DELIMITER ;
*/
DELIMITER //

CREATE PROCEDURE sp_editar_Cliente(
    IN p_idCliente INT,
    IN p_nombre VARCHAR(30),
    IN p_apellido VARCHAR(30),
    IN p_dni VARCHAR(9),
    IN p_direccion VARCHAR(50),
    IN p_telefono CHAR(9),
    IN p_ruc VARCHAR(11)
)
BEGIN
    DECLARE idp INT;

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Obtener ID de la persona relacionada
    SELECT idPersonaCliente INTO idp FROM Cliente WHERE idCliente = p_idCliente;

    -- Actualizar Persona
    UPDATE Persona
    SET Nombre = p_nombre,
        Apellido = p_apellido,
        Dni = p_dni,
        Direccion = p_direccion,
        Telefono = p_telefono
    WHERE idPersona = idp;

    -- Actualizar Cliente
    UPDATE Cliente
    SET ruc = p_ruc
    WHERE idCliente = p_idCliente;

    COMMIT;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_eliminar_Cliente(IN p_idCliente INT)
BEGIN
    UPDATE Cliente SET estado = 'Eliminado' WHERE idCliente = p_idCliente;
END//
DELIMITER ;
/*
DELIMITER //
CREATE PROCEDURE sp_eliminar_Cliente(IN p_idCliente INT)
BEGIN
    DELETE FROM Cliente WHERE idCliente = p_idCliente;
END //
*/
DELIMITER ;

/*-----Empleado y usuario-*/

DELIMITER //
CREATE PROCEDURE sp_buscar_empleado(IN buscar VARCHAR(50))
BEGIN
    SELECT 
        u.idUsuario, e.idEmpleado, p.Nombre, p.Apellido, p.Dni, p.Direccion, p.Telefono,
        r.nombreRol AS Rol, ec.estado AS EstadoCuenta, u.usuario
    FROM Usuario u
    JOIN Empleado e ON u.idEmpleado = e.idEmpleado
    JOIN Persona p ON e.idPersonaEmpleado = p.idPersona
    JOIN Rol r ON u.idRol = r.idRol
    JOIN EstadoCuenta ec ON u.idEstado = ec.idEstado
    WHERE p.Nombre LIKE CONCAT('%', buscar, '%')
       OR p.Apellido LIKE CONCAT('%', buscar, '%')
       OR u.usuario LIKE CONCAT('%', buscar, '%');
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_guardar_empleado(
    IN p_nombre VARCHAR(30),
    IN p_apellido VARCHAR(30),
    IN p_dni VARCHAR(9),
    IN p_direccion VARCHAR(50),
    IN p_telefono CHAR(9),
    IN p_idRol INT,
    IN p_idEstado INT,
    IN p_usuario VARCHAR(20),
    IN p_password VARCHAR(60)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    INSERT INTO Persona(Dni, Nombre, Apellido, Direccion, Telefono)
    VALUES (p_dni, p_nombre, p_apellido, p_direccion, p_telefono);
    SET @idPersona = LAST_INSERT_ID();
    INSERT INTO Empleado(idPersonaEmpleado)
    VALUES (@idPersona);
    SET @idEmpleado = LAST_INSERT_ID();
    INSERT INTO Usuario(usuario, contraseña, idRol, idEstado, idEmpleado)
    VALUES (p_usuario, p_password, p_idRol, p_idEstado, @idEmpleado);
    COMMIT;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE sp_eliminar_empleado(IN p_idUsuario INT)
BEGIN
    DECLARE idEmp INT;
    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    START TRANSACTION;
    -- Obtener el idEmpleado vinculado
    SELECT idEmpleado INTO idEmp FROM Usuario WHERE idUsuario = p_idUsuario;
    -- Eliminar primero al usuario, luego al empleado
    DELETE FROM Usuario WHERE idUsuario = p_idUsuario;
    DELETE FROM Empleado WHERE idEmpleado = idEmp;

    COMMIT;
END //
DELIMITER ;


INSERT INTO Rol(nombreRol) VALUES ('Empleado'), ('Administrador');
INSERT INTO EstadoCuenta(estado) VALUES ('Habilitado'), ('Deshabilitado');

/*Proveedor  En prueba

-- Buscar proveedor por nombre o apellido
DELIMITER //
CREATE PROCEDURE sp_buscar_proveedor(IN buscar VARCHAR(30))
BEGIN
    SELECT 
        p.idProveedor, 
        pe.Nombre, 
        pe.Apellido, 
        pe.Dni, 
        pe.Direccion, 
        pe.Telefono, 
        p.ruc
    FROM 
        Proveedor p
    INNER JOIN 
        Persona pe ON p.idPersonaProveedor = pe.idPersona
    WHERE 
        pe.Nombre LIKE CONCAT('%', buscar, '%') 
        OR pe.Apellido LIKE CONCAT('%', buscar, '%');
END //
DELIMITER ;

-- Guardar nuevo proveedor
DELIMITER //
CREATE PROCEDURE sp_guardar_proveedor(
    IN nombre VARCHAR(30),
    IN apellido VARCHAR(30),
    IN dni VARCHAR(9),
    IN direccion VARCHAR(50),
    IN telefono CHAR(9),
    IN ruc VARCHAR(11)
)
BEGIN
    DECLARE id_persona INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Insertar en Persona
    INSERT INTO Persona (Dni, Nombre, Apellido, Direccion, Telefono)
    VALUES (dni, nombre, apellido, direccion, telefono);

    -- Obtener el ID recién insertado mediante el DNI
    SELECT idPersona INTO id_persona
    FROM Persona
    WHERE Dni = dni;

    -- Insertar en Proveedor
    INSERT INTO Proveedor (ruc, idPersonaProveedor)
    VALUES (ruc, id_persona);

    COMMIT;
END //
DELIMITER ;

-- Editar proveedor existente
DELIMITER //
CREATE PROCEDURE sp_editar_proveedor(
    IN param_idProveedor INT, 
    IN nombre VARCHAR(30),
    IN apellido VARCHAR(30),
    IN dni VARCHAR(9),
    IN direccion VARCHAR(50),
    IN telefono CHAR(9),
    IN ruc VARCHAR(11)
)
BEGIN
    DECLARE id_persona INT;

    START TRANSACTION;

    -- Obtener el idPersona relacionado
    SELECT idPersonaProveedor INTO id_persona
    FROM Proveedor
    WHERE idProveedor = param_idProveedor;

    -- Actualizar Persona
    UPDATE Persona
    SET Nombre = nombre,
        Apellido = apellido,
        Dni = dni,
        Direccion = direccion,
        Telefono = telefono
    WHERE idPersona = id_persona;

    -- Actualizar RUC
    UPDATE Proveedor
    SET Ruc = ruc
    WHERE idProveedor = param_idProveedor;

    COMMIT;
END //
DELIMITER ;

-- Eliminar proveedor
DELIMITER //
CREATE PROCEDURE sp_eliminar_proveedor(IN param_idProveedor INT)
BEGIN
    DECLARE id_persona INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Obtener idPersona antes de eliminar el proveedor
    SELECT idPersonaProveedor INTO id_persona
    FROM Proveedor
    WHERE idProveedor = param_idProveedor;

    -- Eliminar Proveedor
    DELETE FROM Proveedor
    WHERE idProveedor = param_idProveedor;

    -- Eliminar Persona
    DELETE FROM Persona
    WHERE idPersona = id_persona;

    COMMIT;
END //
DELIMITER ;
*/
/*----------------------------Venta y detalleventa ----------------------------------*/
DELIMITER //
CREATE PROCEDURE sp_registrar_venta(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_serie VARCHAR(7),
    IN p_num_documento VARCHAR(10),
    IN p_tipo_documento VARCHAR(10),
    IN p_subtotal DECIMAL(8,2),
    IN p_igv DECIMAL(8,2),
    IN p_total DECIMAL(8,2),
    IN p_estado VARCHAR(20),
    IN p_idUsuario INT,
    IN p_idCliente INT
)
BEGIN
    INSERT INTO ventas (
        fecha, hora, serie, num_documento, tipo_documento, 
        subtotal, igv, total, estado, idUsuario, idCliente
    )
    VALUES (
        p_fecha, p_hora, p_serie, p_num_documento, p_tipo_documento, 
        p_subtotal, p_igv, p_total, p_estado, p_idUsuario, p_idCliente
    );
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_registrar_detalle_venta(
    IN p_idVenta INT,
    IN p_idProducto VARCHAR(9),
    IN p_cantidad INT,
    IN p_precio DECIMAL(8,2),
    IN p_total DECIMAL(8,2)
)
BEGIN
    INSERT INTO detalle_ventas(idVenta, idProducto, cantidad, precio, total)
    VALUES (p_idVenta, p_idProducto, p_cantidad, p_precio, p_total);

    -- Actualiza el stock
    UPDATE Productos
    SET Cantidad = Cantidad - p_cantidad
    WHERE idProducto = p_idProducto;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_listar_ventas()
BEGIN
    SELECT 
        v.idVenta,
        v.fecha,
        v.hora,
        v.serie,
        v.num_documento,
        v.tipo_documento,
        v.subtotal,
        v.igv,
        v.total,
        v.estado,
        CONCAT(p.Nombre, ' ', p.Apellido) AS Cliente,
        u.usuario AS Usuario
    FROM ventas v
    INNER JOIN Cliente c ON v.idCliente = c.idCliente
    INNER JOIN Persona p ON c.idPersonaCliente = p.idPersona
    INNER JOIN Usuario u ON v.idUsuario = u.idUsuario;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_buscar_venta(IN buscar VARCHAR(50))
BEGIN
    SELECT 
        v.idVenta,
        v.fecha,
        v.hora,
        v.serie,
        v.num_documento,
        v.tipo_documento,
        v.subtotal,
        v.igv,
        v.total,
        v.estado,
        CONCAT(p.Nombre, ' ', p.Apellido) AS Cliente,
        u.usuario AS Usuario
    FROM ventas v
    INNER JOIN Cliente c ON v.idCliente = c.idCliente
    INNER JOIN Persona p ON c.idPersonaCliente = p.idPersona
    INNER JOIN Usuario u ON v.idUsuario = u.idUsuario
    WHERE p.Nombre LIKE CONCAT('%', buscar, '%')
       OR p.Apellido LIKE CONCAT('%', buscar, '%')
       OR v.num_documento LIKE CONCAT('%', buscar, '%')
       OR v.fecha LIKE CONCAT('%', buscar, '%');
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_detalle_venta_por_id(IN p_idVenta INT)
BEGIN
    SELECT 
        dv.idDetalleVenta,
        pr.nombre AS Producto,
        dv.cantidad,
        dv.precio,
        dv.total
    FROM detalle_ventas dv
    INNER JOIN Productos pr ON dv.idProducto = pr.idProducto
    WHERE dv.idVenta = p_idVenta;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_eliminar_venta(IN p_idVenta INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE p_idProducto VARCHAR(9);
    DECLARE p_cantidad INT;
    DECLARE cur CURSOR FOR
        SELECT idProducto, cantidad FROM detalle_ventas WHERE idVenta = p_idVenta;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;

    -- Reponer stock
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO p_idProducto, p_cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE Productos
        SET Cantidad = Cantidad + p_cantidad
        WHERE idProducto = p_idProducto;
    END LOOP;
    CLOSE cur;

    -- Cambiar estado
    UPDATE ventas
    SET estado = 'Anulado'
    WHERE idVenta = p_idVenta;

    COMMIT;
END //
DELIMITER ;


/*en prueba*/

DELIMITER //
CREATE PROCEDURE sp_venta_completa(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_serie VARCHAR(7),
    IN p_num_documento VARCHAR(10),
    IN p_tipo_documento VARCHAR(10),
    IN p_idUsuario INT,
    IN p_idCliente INT,
    -- Detalles: lista de productos en arrays paralelos
    IN p_productos VARCHAR(255),  -- ej: "PROD1,PROD2"
    IN p_cantidades VARCHAR(255), -- ej: "2,5"
    IN p_precios VARCHAR(255)     -- ej: "10.50,3.20"
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_igv DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    
    DECLARE v_prod VARCHAR(9);
    DECLARE v_cant INT;
    DECLARE v_pre DECIMAL(10,2);
    
    DECLARE v_idx INT DEFAULT 1;
    DECLARE v_nproductos INT;
    DECLARE delim CHAR(1) DEFAULT ',';
    
    -- Contar cuántos productos hay
    SET v_nproductos = 1 + LENGTH(p_productos) - LENGTH(REPLACE(p_productos, delim, ''));

    START TRANSACTION;
    
    -- Calcular subtotal iterando
    WHILE v_idx <= v_nproductos DO
        SET v_prod = SUBSTRING_INDEX(SUBSTRING_INDEX(p_productos, delim, v_idx), delim, -1);
        SET v_cant = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_cantidades, delim, v_idx), delim, -1) AS UNSIGNED);
		SET v_pre = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_precios, delim, v_idx), delim, -1) AS DECIMAL(10,2));
        
        SET v_subtotal = v_subtotal + (v_cant * v_pre);
        SET v_idx = v_idx + 1;
    END WHILE;
    
    SET v_igv = ROUND(v_subtotal * 0.18, 2);
    SET v_total = ROUND(v_subtotal + v_igv, 2);
    
    -- Insertar cabecera
    INSERT INTO ventas (
        fecha, hora, serie, num_documento, tipo_documento,
        subtotal, igv, total, estado, idUsuario, idCliente
    ) VALUES (
        p_fecha, p_hora, p_serie, p_num_documento, p_tipo_documento,
        v_subtotal, v_igv, v_total, 'Habilitado', p_idUsuario, p_idCliente
    );
    
    SET @idVenta = LAST_INSERT_ID();
    
    -- Insertar cada detalle y actualizar stock
    SET v_idx = 1;
    WHILE v_idx <= v_nproductos DO
        SET v_prod = SUBSTRING_INDEX(SUBSTRING_INDEX(p_productos, delim, v_idx), delim, -1);
        SET v_cant = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_cantidades, delim, v_idx), delim, -1) AS UNSIGNED);
        SET v_pre = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_precios, delim, v_idx), delim, -1) AS DECIMAL(10,2));
        
        INSERT INTO detalle_ventas(idVenta, idProducto, cantidad, precio, total)
        VALUES (@idVenta, v_prod, v_cant, v_pre, v_cant * v_pre);
        
        UPDATE Productos
        SET Cantidad = Cantidad - v_cant
        WHERE idProducto = v_prod;
        
        SET v_idx = v_idx + 1;
    END WHILE;
    
    COMMIT;
END //
DELIMITER ;

/*----------------------------Suministro y detalleCompra ----------------------------------*/

DELIMITER //
CREATE PROCEDURE sp_registrar_suministro(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_num_documento VARCHAR(10),
    IN p_tipo_documento VARCHAR(10),
    IN p_subtotal DECIMAL(8,2),
    IN p_igv DECIMAL(8,2),
    IN p_total DECIMAL(8,2),
    IN p_estado VARCHAR(20),
    IN p_idUsuario INT,
    IN p_idProveedor INT
)
BEGIN
    INSERT INTO Suministros (
        fecha, hora, num_documento, tipo_documento,
        subtotal, igv, total, estado, idUsuario, idProveedor
    ) VALUES (
        p_fecha, p_hora, p_num_documento, p_tipo_documento,
        p_subtotal, p_igv, p_total, p_estado, p_idUsuario, p_idProveedor
    );
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_registrar_detalle_suministro(
    IN p_idSuministro INT,
    IN p_idProducto VARCHAR(9),
    IN p_cantidad INT,
    IN p_precio DECIMAL(8,2),
    IN p_total DECIMAL(8,2)
)
BEGIN
    INSERT INTO detalle_compras(idCompra, idProducto, cantidad, precio, total)
    VALUES (p_idSuministro, p_idProducto, p_cantidad, p_precio, p_total);

    -- Actualiza el stock
    UPDATE Productos
    SET Cantidad = Cantidad + p_cantidad
    WHERE idProducto = p_idProducto;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE sp_suministro_completo(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_num_documento VARCHAR(10),
    IN p_tipo_documento VARCHAR(10),
    IN p_idUsuario INT,
    IN p_idProveedor INT,
    -- Detalles
    IN p_productos VARCHAR(255),
    IN p_cantidades VARCHAR(255),
    IN p_precios VARCHAR(255)
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_igv DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);

    DECLARE v_prod VARCHAR(9);
    DECLARE v_cant INT;
    DECLARE v_pre DECIMAL(10,2);

    DECLARE v_idx INT DEFAULT 1;
    DECLARE v_nproductos INT;
    DECLARE delim CHAR(1) DEFAULT ',';

    SET v_nproductos = 1 + LENGTH(p_productos) - LENGTH(REPLACE(p_productos, delim, ''));

    START TRANSACTION;

    WHILE v_idx <= v_nproductos DO
        SET v_prod = SUBSTRING_INDEX(SUBSTRING_INDEX(p_productos, delim, v_idx), delim, -1);
        SET v_cant = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_cantidades, delim, v_idx), delim, -1) AS UNSIGNED);
        SET v_pre = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_precios, delim, v_idx), delim, -1) AS DECIMAL(10,2));

        SET v_subtotal = v_subtotal + (v_cant * v_pre);
        SET v_idx = v_idx + 1;
    END WHILE;

    SET v_igv = ROUND(v_subtotal * 0.18, 2);
    SET v_total = ROUND(v_subtotal + v_igv, 2);

    -- Insertar cabecera
    INSERT INTO Suministros (
        fecha, hora, num_documento, tipo_documento,
        subtotal, igv, total, estado, idUsuario, idProveedor
    ) VALUES (
        p_fecha, p_hora, p_num_documento, p_tipo_documento,
        v_subtotal, v_igv, v_total, 'Habilitado', p_idUsuario, p_idProveedor
    );

    SET @idSuministro = LAST_INSERT_ID();

    -- Insertar detalles y actualizar stock
    SET v_idx = 1;
    WHILE v_idx <= v_nproductos DO
        SET v_prod = SUBSTRING_INDEX(SUBSTRING_INDEX(p_productos, delim, v_idx), delim, -1);
        SET v_cant = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_cantidades, delim, v_idx), delim, -1) AS UNSIGNED);
        SET v_pre = CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p_precios, delim, v_idx), delim, -1) AS DECIMAL(10,2));

        INSERT INTO detalle_compras(idCompra, idProducto, cantidad, precio, total)
        VALUES (@idSuministro, v_prod, v_cant, v_pre, v_cant * v_pre);

        UPDATE Productos
        SET Cantidad = Cantidad + v_cant
        WHERE idProducto = v_prod;

        SET v_idx = v_idx + 1;
    END WHILE;

    COMMIT;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_listar_suministros()
BEGIN
    SELECT 
        s.idSuministro,
        s.fecha,
        s.hora,
        s.num_documento,
        s.tipo_documento,
        s.subtotal,
        s.igv,
        s.total,
        s.estado,
        u.usuario AS Usuario,
        CONCAT(p.Nombre, ' ', p.Apellido) AS Proveedor
    FROM Suministros s
    INNER JOIN Proveedor pr ON s.idProveedor = pr.idProveedor
    INNER JOIN Persona p ON pr.idPersonaProveedor = p.idPersona
    INNER JOIN Usuario u ON s.idUsuario = u.idUsuario;
END //
DELIMITER ;
call sp_buscar_suministro(1);
DELIMITER //
CREATE PROCEDURE sp_buscar_suministro(IN buscar VARCHAR(50))
BEGIN
    SELECT 
        s.idSuministro,
        s.fecha,
        s.hora,
        s.num_documento,
        s.tipo_documento,
        s.subtotal,
        s.igv,
        s.total,
        s.estado,
        u.usuario AS Usuario,
        CONCAT(p.Nombre, ' ', p.Apellido) AS Proveedor
    FROM Suministros s
    INNER JOIN Proveedor pr ON s.idProveedor = pr.idProveedor
    INNER JOIN Persona p ON pr.idPersonaProveedor = p.idPersona
    INNER JOIN Usuario u ON s.idUsuario = u.idUsuario
    WHERE p.Nombre LIKE CONCAT('%', buscar, '%')
       OR p.Apellido LIKE CONCAT('%', buscar, '%')
       OR s.num_documento LIKE CONCAT('%', buscar, '%')
       OR s.fecha LIKE CONCAT('%', buscar, '%');
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_eliminar_suministro(IN p_idSuministro INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE p_idProducto VARCHAR(9);
    DECLARE p_cantidad INT;
    DECLARE cur CURSOR FOR
        SELECT idProducto, cantidad FROM detalle_compras WHERE idCompra = p_idSuministro;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;

    -- Restaurar stock
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO p_idProducto, p_cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;
        UPDATE Productos
        SET Cantidad = Cantidad - p_cantidad
        WHERE idProducto = p_idProducto;
    END LOOP;
    CLOSE cur;

    -- Marcar como anulado
    UPDATE Suministros
    SET estado = 'Anulado'
    WHERE idSuministro = p_idSuministro;

    COMMIT;
END //
DELIMITER ;


DELIMITER //

CREATE PROCEDURE sp_listar_detalle_suministro(IN p_idSuministro INT)
BEGIN
    SELECT 
        dc.idDetalleCompra,
        dc.idCompra AS idSuministro,
        dc.idProducto,
        p.nombre AS nombreProducto,
        dc.cantidad,
        dc.precio,
        dc.total
    FROM 
        detalle_compras dc
    INNER JOIN 
        Productos p ON dc.idProducto = p.idProducto
    WHERE 
        dc.idCompra = p_idSuministro;
END //

DELIMITER ;

/*------------------------Proveedor--------------------------------*/
DELIMITER $$

CREATE PROCEDURE sp_guardar_Proveedor(
    IN p_nombre VARCHAR(30),
    IN p_apellido VARCHAR(30),
    IN p_dni VARCHAR(9),
    IN p_direccion VARCHAR(50),
    IN p_telefono CHAR(9),
    IN p_ruc VARCHAR(11)
)
BEGIN
    DECLARE lastIdPersona INT;

    -- Insertar en Persona
    INSERT INTO Persona (Dni, Nombre, Apellido, Direccion, Telefono)
    VALUES (p_dni, p_nombre, p_apellido, p_direccion, p_telefono);

    SET lastIdPersona = LAST_INSERT_ID();

    -- Insertar en Proveedor
    INSERT INTO Proveedor (ruc, idPersonaProveedor)
    VALUES (p_ruc, lastIdPersona);
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_listar_Proveedores(
    IN buscar VARCHAR(100)
)
BEGIN
    SELECT 
        pr.idProveedor,
        pe.Nombre,
        pe.Apellido,
        pe.Dni,
        pe.Direccion,
        pe.Telefono,
        pr.ruc
    FROM Proveedor pr
    INNER JOIN Persona pe ON pr.idPersonaProveedor = pe.idPersona
    WHERE 
        pe.Nombre LIKE CONCAT('%', buscar, '%') 
        OR pe.Apellido LIKE CONCAT('%', buscar, '%')
        OR pe.Dni LIKE CONCAT('%', buscar, '%')
        OR pr.ruc LIKE CONCAT('%', buscar, '%');
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_editar_Proveedor(
    IN p_idProveedor INT,
    IN p_nombre VARCHAR(30),
    IN p_apellido VARCHAR(30),
    IN p_dni VARCHAR(9),
    IN p_direccion VARCHAR(50),
    IN p_telefono CHAR(9),
    IN p_ruc VARCHAR(11)
)
BEGIN
    DECLARE v_idPersona INT;

    -- Obtener ID persona relacionado al proveedor
    SELECT idPersonaProveedor INTO v_idPersona 
    FROM Proveedor 
    WHERE idProveedor = p_idProveedor;

    -- Actualizar datos en Persona
    UPDATE Persona 
    SET 
        Nombre = p_nombre,
        Apellido = p_apellido,
        Dni = p_dni,
        Direccion = p_direccion,
        Telefono = p_telefono
    WHERE idPersona = v_idPersona;

    -- Actualizar datos en Proveedor
    UPDATE Proveedor 
    SET ruc = p_ruc
    WHERE idProveedor = p_idProveedor;
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE sp_eliminar_Proveedor(
    IN p_idProveedor INT
)
BEGIN
    DECLARE v_idPersona INT;

    -- Obtener ID persona
    SELECT idPersonaProveedor INTO v_idPersona 
    FROM Proveedor 
    WHERE idProveedor = p_idProveedor;

    -- Eliminar Proveedor
    DELETE FROM Proveedor WHERE idProveedor = p_idProveedor;

    -- Eliminar Persona relacionada
    DELETE FROM Persona WHERE idPersona = v_idPersona;
END$$

DELIMITER ;

/*marca y categoria -...-------------------------------*/
-- Listar marcas habilitadas
DELIMITER $$
CREATE PROCEDURE sp_listar_marcas()
BEGIN
    SELECT * FROM Marca WHERE estado = 'Habilitado';
END $$
DELIMITER ;

-- Insertar marca
DELIMITER $$
CREATE PROCEDURE sp_insertar_marca(IN p_nombre VARCHAR(30))
BEGIN
    INSERT INTO Marca (nombre, estado) VALUES (p_nombre, 'Habilitado');
END $$
DELIMITER ;

     -- Pintura (lata)

-- Actualizar marca
DELIMITER $$
CREATE PROCEDURE sp_actualizar_marca(IN p_id INT, IN p_nombre VARCHAR(30))
BEGIN
    UPDATE Marca SET nombre = p_nombre WHERE idMarca = p_id;
END $$
DELIMITER ;

-- "Eliminar" marca (cambia estado a 'Inhabilitado')
DELIMITER $$
CREATE PROCEDURE sp_eliminar_marca(IN p_id INT)
BEGIN
    UPDATE Marca SET estado = 'Inhabilitado' WHERE idMarca = p_id;
END $$
DELIMITER ;

-- Restaurar marca
DELIMITER $$
CREATE PROCEDURE sp_restaurar_marca(IN p_id INT)
BEGIN
    UPDATE Marca SET estado = 'Habilitado' WHERE idMarca = p_id;
END $$
DELIMITER ;


-- Listar categorías habilitadas
DELIMITER $$
CREATE PROCEDURE sp_listar_categorias()
BEGIN
    SELECT * FROM Categoria WHERE estado = 'Habilitado';
END $$
DELIMITER ;

-- Insertar categoría
DELIMITER $$
CREATE PROCEDURE sp_insertar_categoria(IN p_nombre VARCHAR(30))
BEGIN
    INSERT INTO Categoria (nombre, estado) VALUES (p_nombre, 'Habilitado');
END $$
DELIMITER ;

-- Actualizar categoría
DELIMITER $$
CREATE PROCEDURE sp_actualizar_categoria(IN p_id INT, IN p_nombre VARCHAR(30))
BEGIN
    UPDATE Categoria SET nombre = p_nombre WHERE idCategoria = p_id;
END $$
DELIMITER ;

-- "Eliminar" categoría (cambia estado a 'Inhabilitado')
DELIMITER $$
CREATE PROCEDURE sp_eliminar_categoria(IN p_id INT)
BEGIN
    UPDATE Categoria SET estado = 'Inhabilitado' WHERE idCategoria = p_id;
END $$
DELIMITER ;

-- Restaurar categoría
DELIMITER $$
CREATE PROCEDURE sp_restaurar_categoria(IN p_id INT)
BEGIN
    UPDATE Categoria SET estado = 'Habilitado' WHERE idCategoria = p_id;
END $$
DELIMITER ;

CALL sp_listar_marcas();

/*----------------------producto---------------------*/

/* procedimientos para las tablas producto---------------------------------------------------------------------------------------------------------*/
DELIMITER //
CREATE PROCEDURE sp_guardar_Producto(
    IN pidProducto VARCHAR(9),
    IN pnombre VARCHAR(30),
    IN pprecioCompra DECIMAL(8,2),
    IN pprecioVenta DECIMAL(8,2),
    IN pfechaIngreso DATE,
    IN pfechaVencimiento DATE,
    IN pidCategoria INT,
    IN pidMarca INT
)
BEGIN
    INSERT INTO Productos (
        idProducto, nombre, precioCompra, precioVenta, fechaIngreso, fechaVencimiento,
        idCategoria, idMarca, estado
    )
    VALUES (
        pidProducto, pnombre, pprecioCompra, pprecioVenta, pfechaIngreso, pfechaVencimiento,
        pidCategoria, pidMarca, 'activo'
    );
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE sp_editar_Producto(
    IN pidProducto VARCHAR(9),
    IN pnombre VARCHAR(30),
    IN pprecioCompra DECIMAL(8,2),
    IN pprecioVenta DECIMAL(8,2),
    IN pfechaIngreso DATE,
    IN pfechaVencimiento DATE,
    IN pidCategoria INT,
    IN pidMarca INT
)
BEGIN
    UPDATE Productos SET
        nombre = pnombre,
        precioCompra = pprecioCompra,
        precioVenta = pprecioVenta,
        fechaIngreso = pfechaIngreso,
        fechaVencimiento = pfechaVencimiento,
        idCategoria = pidCategoria,
        idMarca = pidMarca
    WHERE idProducto = pidProducto;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE sp_listar_Productos(
    IN pbuscar VARCHAR(50)
)
BEGIN
    SELECT
        p.idProducto,
        p.nombre,
        p.precioCompra,
        p.precioVenta,
        p.fechaIngreso,
        p.fechaVencimiento,
        p.Cantidad,
        c.nombre AS categoria,
        m.nombre AS marca
    FROM Productos p
    LEFT JOIN Categoria c ON p.idCategoria = c.idCategoria
    LEFT JOIN Marca m ON p.idMarca = m.idMarca
    WHERE p.estado = 'activo'
      AND (p.idProducto LIKE CONCAT('%', pbuscar, '%') OR p.nombre LIKE CONCAT('%', pbuscar, '%'));
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE sp_eliminar_Producto(
    IN pidProducto VARCHAR(9)
)
BEGIN
    UPDATE Productos
    SET estado = 'inactivo'
    WHERE idProducto = pidProducto;
END //
DELIMITER ;


/**Extras................................................**/

DELIMITER $$

CREATE PROCEDURE sp_historial_ventas()
BEGIN
    SELECT
        v.idVenta,
        v.fecha,
        v.hora,
        v.serie,
        v.num_documento,
        v.tipo_documento,
        v.subtotal,
        v.igv,
        v.total,
        CONCAT(p.Nombre, ' ', p.Apellido) AS nombreUsuario,
        CONCAT(pc.Nombre, ' ', pc.Apellido) AS nombreCliente
    FROM ventas v
    JOIN Usuario u ON v.idUsuario = u.idUsuario
    JOIN Empleado e ON u.idEmpleado = e.idEmpleado
    JOIN Persona p ON e.idPersonaEmpleado = p.idPersona
    JOIN Cliente c ON v.idCliente = c.idCliente
    JOIN Persona pc ON c.idPersonaCliente = pc.idPersona
    ORDER BY v.fecha DESC, v.hora DESC;
END$$

DELIMITER ;
call sp_historial_compras();
DELIMITER $$

CREATE PROCEDURE sp_historial_compras()
BEGIN
    SELECT
        s.idSuministro,
        s.fecha,
        s.hora,
        s.num_documento,
        s.tipo_documento,
        s.subtotal,
        s.igv,
        s.total,
        CONCAT(p.Nombre, ' ', p.Apellido) AS nombreUsuario,
        CONCAT(pp.Nombre, ' ', pp.Apellido) AS nombreProveedor
    FROM Suministros s
    JOIN Usuario u ON s.idUsuario = u.idUsuario
    JOIN Empleado e ON u.idEmpleado = e.idEmpleado
    JOIN Persona p ON e.idPersonaEmpleado = p.idPersona
    JOIN Proveedor pr ON s.idProveedor = pr.idProveedor
    JOIN Persona pp ON pr.idPersonaProveedor = pp.idPersona
    ORDER BY s.fecha DESC, s.hora DESC;
END$$

DELIMITER ;

/*Extra p2-----------------------------------------------------*/
DELIMITER $$

CREATE PROCEDURE sp_actualizar_estado_general(
    IN p_tabla VARCHAR(30),
    IN p_campoId VARCHAR(30),
    IN p_valorId VARCHAR(20),
    IN p_nuevoEstado VARCHAR(20),
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    DECLARE v_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET p_mensaje = CONCAT('Error al actualizar estado en la tabla ', p_tabla);
    END;

    -- Construimos el SQL en una variable global de sesión
    SET @v_sql = CONCAT(
        'UPDATE ', p_tabla,
        ' SET estado = ''', p_nuevoEstado,
        ''' WHERE ', p_campoId, ' = ''', p_valorId, ''''
    );

    -- Ejecutamos el SQL dinámico
    PREPARE stmt FROM @v_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Verificamos cambios
    SET v_rows = ROW_COUNT();

    IF v_rows > 0 THEN
        SET p_mensaje = CONCAT('Estado actualizado correctamente en ', p_tabla);
    ELSE
        SET p_mensaje = CONCAT('No se encontró registro en ', p_tabla, ' con ID ', p_valorId);
    END IF;
END$$

DELIMITER ;
call sp_listar_todo_deshabilitado();

DELIMITER $$
/*SP para listar todo lo deshabilitado (menos Usuario)*/
CREATE PROCEDURE sp_listar_todo_deshabilitado()
BEGIN
    -- Productos deshabilitados
    SELECT idProducto AS id, nombre, estado, 'Productos' AS tabla
    FROM Productos
    WHERE estado <> 'activo';

    -- Marcas deshabilitadas
    SELECT idMarca AS id, nombre, estado, 'Marca' AS tabla
    FROM Marca
    WHERE estado <> 'Habilitado';

    -- Categorías deshabilitadas
    SELECT idCategoria AS id, nombre, estado, 'Categoria' AS tabla
    FROM Categoria
    WHERE estado <> 'Habilitado';

    -- Suministros deshabilitados
    SELECT idSuministro AS id, num_documento AS nombre, estado, 'Suministros' AS tabla
    FROM Suministros
    WHERE estado <> 'Habilitado';

    -- Ventas anuladas
    SELECT idVenta AS id, num_documento AS nombre, estado, 'Ventas' AS tabla
    FROM ventas
    WHERE estado <> 'Habilitado';
END$$

DELIMITER ;

DELIMITER $$
/*Cambia el idEstado (por ejemplo, 1 = Habilitado, 2 = Deshabilitado, etc.)*/
CREATE PROCEDURE sp_cambiar_estado_usuario(
    IN p_idUsuario INT,
    IN p_nuevoEstado INT,
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET p_mensaje = 'Error al actualizar estado del usuario';
    END;

    IF EXISTS (SELECT 1 FROM Usuario WHERE idUsuario = p_idUsuario) THEN
        UPDATE Usuario
        SET idEstado = p_nuevoEstado
        WHERE idUsuario = p_idUsuario;

        SET p_mensaje = 'Estado del usuario actualizado correctamente.';
    ELSE
        SET p_mensaje = 'Usuario no encontrado.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$
/* SP para listar todos los usuarios con nombre completo del empleado y su estado*/
CREATE PROCEDURE sp_listar_usuarios_con_empleado()
BEGIN
    SELECT 
        u.idUsuario,
        u.usuario,
        CONCAT(p.Nombre, ' ', p.Apellido) AS nombreEmpleado,
        ec.estado AS estadoUsuario,
        r.nombreRol
    FROM Usuario u
    INNER JOIN Empleado e ON u.idEmpleado = e.idEmpleado
    INNER JOIN Persona p ON e.idPersonaEmpleado = p.idPersona
    INNER JOIN EstadoCuenta ec ON u.idEstado = ec.idEstado
    INNER JOIN Rol r ON u.idRol = r.idRol;
END$$

DELIMITER ;

CALL sp_listar_usuarios_con_empleado()

/*****Introduccion de productos ****/

CALL sp_insertar_categoria('Herramientas manuales');    -- Martillo, Pinza, Destornillador, Llave inglesa, Metro, Nivel
CALL sp_insertar_categoria('Fijaciones');               -- Clavo, Tornillo, Perno, Tuerca, Arandela
CALL sp_insertar_categoria('Accesorios de ferretería'); -- Cinta aislante, Alambre (rollo)
CALL sp_insertar_categoria('Herramientas eléctricas');  -- Broca
CALL sp_insertar_categoria('Pintura y acabado');        -- Pintura (lata)

CALL sp_insertar_marca('Tramontina');
CALL sp_insertar_marca('Stanley');
CALL sp_insertar_marca('Bosch');
CALL sp_insertar_marca('3M');
CALL sp_insertar_marca('DeWalt');
CALL sp_insertar_marca('Pretul');
CALL sp_insertar_marca('Makita');


CALL sp_guardar_Producto('13842', 'Clavo', 90.00, 100.00, '2025-07-01', '2099-12-31', 4, 10);
CALL sp_guardar_Producto('94752', 'Tornillo', 45.00, 50.00, '2025-07-01', '2099-12-31', 4, 9);
CALL sp_guardar_Producto('28416', 'Perno', 36.00, 40.00, '2025-07-01', '2099-12-31', 4, 6);
CALL sp_guardar_Producto('71935', 'Tuerca', 54.00, 60.00, '2025-07-01', '2099-12-31', 4, 7);
CALL sp_guardar_Producto('50321', 'Arandela', 27.00, 30.00, '2025-07-01', '2099-12-31', 4, 6);

CALL sp_guardar_Producto('61289', 'Martillo', 18.00, 20.00, '2025-07-01', '2099-12-31', 3, 5);
CALL sp_guardar_Producto('18467', 'Destornillador', 13.00, 15.00, '2025-07-01', '2099-12-31', 3, 9);
CALL sp_guardar_Producto('32674', 'Metro', 45.00, 50.00, '2025-07-01', '2099-12-31', 3, 6);
CALL sp_guardar_Producto('84502', 'Pinza', 27.00, 30.00, '2025-07-01', '2099-12-31', 3, 10);
CALL sp_guardar_Producto('25130', 'Llave inglesa', 18.00, 20.00, '2025-07-01', '2099-12-31', 3, 5);
CALL sp_guardar_Producto('78014', 'Nivel', 13.00, 15.00, '2025-07-01', '2099-12-31', 3, 9);

CALL sp_guardar_Producto('97031', 'Broca', 8.00, 10.00, '2025-07-01', '2099-12-31', 6, 7);

CALL sp_guardar_Producto('69238', 'Cinta aislante', 36.00, 40.00, '2025-07-01', '2099-12-31', 5, 8);
CALL sp_guardar_Producto('49703', 'Pintura (lata)', 8.00, 10.00, '2025-07-01', '2099-12-31', 7, 8);
CALL sp_guardar_Producto('35971', 'Alambre (rollo)', 45.00, 50.00, '2025-07-01', '2099-12-31', 5, 10);

