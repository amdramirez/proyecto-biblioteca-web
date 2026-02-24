-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-07-2025 a las 14:17:32
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `biblioteca`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `cargar_telefono` (IN `p_tipo_telefono` VARCHAR(100))   BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error al insertar en telefono.';
  END;

  INSERT INTO telefono (tipo_telefono)
  VALUES (p_tipo_telefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cargas_direccion` (IN `p_provincia` VARCHAR(100))   BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error al insertar en direccion.';
  END;

  INSERT INTO direccion (provincia)
  VALUES (p_provincia);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_bibliotecario` (IN `p_bibli_nombre` VARCHAR(100), IN `p_bibli_apellido` VARCHAR(100), IN `p_cod_sede` INT, IN `p_id_correo` INT, IN `p_correo_bibli` VARCHAR(100), IN `p_id_telefono` INT, IN `p_num_bibliotecario` VARCHAR(20))   BEGIN
  DECLARE verificacion_sede INT;
  DECLARE verificacion_correo INT;
  DECLARE verificacion_telefono INT;
  DECLARE v_id_bibliotecario INT;

  -- Verificar correo
  SELECT COUNT(*) INTO verificacion_correo
  FROM correo WHERE id_correo = p_id_correo;
  IF verificacion_correo = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de correo no existe';
  END IF;

  -- Verificar teléfono
  SELECT COUNT(*) INTO verificacion_telefono
  FROM telefono WHERE id_telefono = p_id_telefono;
  IF verificacion_telefono = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de teléfono no existe';
  END IF;

  -- Verificar sede
  SELECT COUNT(*) INTO verificacion_sede
  FROM sede WHERE cod_sede = p_cod_sede;
  IF verificacion_sede = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sede no existe';
  END IF;

  -- Insertar bibliotecario
  INSERT INTO bibliotecario (bibli_nombre, bibli_apellido, cod_sede)
  VALUES (p_bibli_nombre, p_bibli_apellido, p_cod_sede);

  SET v_id_bibliotecario = LAST_INSERT_ID();

  -- Insertar teléfono
  INSERT INTO bibliotecario_telefono (id_bibliotecario, id_telefono, num_bibliotecario)
  VALUES (v_id_bibliotecario, p_id_telefono, p_num_bibliotecario);

  -- Insertar correo
  INSERT INTO bibliotecario_correo (id_correo, id_bibliotecario, correo_bibli)
  VALUES (p_id_correo, v_id_bibliotecario, p_correo_bibli);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_carrera` (IN `p_car_nombre` VARCHAR(100), IN `p_car_duracion` INT)   BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: Duplicidad de valores o fallo inesperado.';
  END;

  INSERT INTO carrera(car_nombre, car_duracion)
  VALUES (p_car_nombre, p_car_duracion);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_correo` (IN `p_tipo_correo` VARCHAR(100))   BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error al insertar en correo.';
  END;

  INSERT INTO correo (tipo_correo)
  VALUES (p_tipo_correo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_direccion` (IN `p_provincia` VARCHAR(100))   BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error al insertar en direccion.';
  END;

  INSERT INTO dirección (provincia)
  VALUES (p_provincia);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_editorial` (IN `p_Edi_Nombre` VARCHAR(100), IN `p_Id_Telefono` INT, IN `p_Num_Editorial` VARCHAR(20), IN `p_Id_Correo` INT, IN `p_Correo_Editorial` VARCHAR(100))   BEGIN
  DECLARE verificacion_correo INT;
  DECLARE verificacion_telefono INT;
  DECLARE v_cod_editorial INT;

  -- Verificar si el correo existe
  SELECT COUNT(*) INTO verificacion_correo
  FROM correo
  WHERE id_correo = p_Id_Correo;

  IF verificacion_correo = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El correo especificado no existe';
  END IF;

  -- Verificar si el tipo de teléfono existe
  SELECT COUNT(*) INTO verificacion_telefono
  FROM telefono
  WHERE id_telefono = p_Id_Telefono;

  IF verificacion_telefono = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El tipo de teléfono especificado no existe';
  END IF;

  -- Insertar en editorial y recuperar el ID generado
  INSERT INTO editorial (edi_nombre)
  VALUES (p_Edi_Nombre);

  SET v_cod_editorial = LAST_INSERT_ID();

  INSERT INTO editorial_telefono (cod_editorial, id_telefono, num_editorial)
  VALUES (v_cod_editorial, p_Id_Telefono, p_Num_Editorial);

  INSERT INTO editorial_correo (id_correo, cod_editorial, correo_editorial)
  VALUES (p_Id_Correo, v_cod_editorial, p_Correo_Editorial);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_libro` (IN `p_lib_nombre` VARCHAR(100), IN `p_lib_año_publicacion` INT, IN `p_lib_edicion` INT, IN `p_lib_isbn` VARCHAR(30), IN `p_cod_sede` INT, IN `p_cod_editorial` INT, IN `p_Au_Nombre` VARCHAR(100), IN `p_Au_Apellido` VARCHAR(100), IN `p_cantidad_libros` INT)   BEGIN
  DECLARE v_autor_id INT;
  DECLARE v_libro_id INT;
  DECLARE verificacion_sede INT;

  -- Verificar si la sede existe
  SELECT COUNT(*) INTO verificacion_sede
  FROM sede WHERE cod_sede = p_cod_sede;
  IF verificacion_sede = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La sede especificada no existe';
  END IF;

  -- Verificar si el autor existe
  SELECT cod_autor INTO v_autor_id
  FROM autor
  WHERE au_nombre = p_Au_Nombre AND au_apellido = p_Au_Apellido
  LIMIT 1;

  -- Si el autor no existe, insertarlo
  IF v_autor_id IS NULL THEN
    INSERT INTO autor (au_nombre, au_apellido)
    VALUES (p_Au_Nombre, p_Au_Apellido);
    SET v_autor_id = LAST_INSERT_ID();
  END IF;

  -- Insertar libro
  INSERT INTO libro (
    lib_nombre,
    lib_año_publicacion,
    lib_edicion,
    lib_isbn,
    cod_sede,
    cod_editorial,
    cod_autor
  )
  VALUES (
    p_lib_nombre,
    p_lib_año_publicacion,
    p_lib_edicion,
    p_lib_isbn,
    p_cod_sede,
    p_cod_editorial,
    v_autor_id
  );

  SET v_libro_id = LAST_INSERT_ID();

  -- Insertar en inventario
  INSERT INTO inventario (cod_libro, cod_sede, cantidad_libros)
  VALUES (v_libro_id, p_cod_sede, p_cantidad_libros);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_oferta` (IN `p_Cod_Sede` INT, IN `p_Cod_Carrera` INT, IN `p_cantidad_cupos` INT)   BEGIN
  DECLARE verificacion_sede INT;
  DECLARE verificacion_carrera INT;

  -- Verificar si la sede existe
  SELECT COUNT(*) INTO verificacion_sede
  FROM sede
  WHERE cod_sede = p_Cod_Sede;

  IF verificacion_sede = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: La sede especificada no existe';
  END IF;

  -- Verificar si la carrera existe
  SELECT COUNT(*) INTO verificacion_carrera
  FROM carrera
  WHERE cod_carrera = p_Cod_Carrera;

  IF verificacion_carrera = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Error: La carrera especificada no existe';
  END IF;

  -- Insertar en oferta
  INSERT INTO oferta (cod_sede, cod_carrera, cantidad_cupos)
  VALUES (p_Cod_Sede, p_Cod_Carrera, p_cantidad_cupos);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_reservar` (IN `p_cod_libro` INT, IN `p_usu_id` INT)   BEGIN
    DECLARE verificacion_usuario INT DEFAULT 0;
    DECLARE verificacion_libro INT DEFAULT 0;
    DECLARE cantidad INT DEFAULT 0;
    DECLARE v_sede INT;
    DECLARE v_cantidad_reservas INT DEFAULT 0;
    DECLARE V_fecha_devolucion DATE;

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO verificacion_usuario
    FROM usuario
    WHERE usu_id = p_usu_id;

    IF verificacion_usuario = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario especificado no existe';
    END IF;

    -- Verificar cantidad de reservas activas
    SELECT COUNT(*) INTO v_cantidad_reservas
    FROM reservar
    WHERE usu_id = p_usu_id;

    IF v_cantidad_reservas > 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario ha alcanzado su límite de 5 reservas';
    END IF;

    -- Verificar si el libro existe
    SELECT COUNT(*) INTO verificacion_libro
    FROM libro
    WHERE cod_libro = p_cod_libro;

    IF verificacion_libro = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El libro especificado no existe';
    END IF;

    -- Obtener la sede del usuario
    SELECT cod_sede INTO v_sede
    FROM usuario
    WHERE usu_id = p_usu_id;

    -- Verificar disponibilidad en inventario
    SELECT cantidad_libros INTO cantidad
    FROM inventario
    WHERE cod_libro = p_cod_libro AND cod_sede = v_sede;

    IF cantidad IS NULL OR cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficientes libros disponibles para la reserva';
    END IF;

    -- Calcular fecha de devolución
    SET V_fecha_devolucion = DATE_ADD(CURDATE(), INTERVAL 7 DAY);

    -- Insertar reserva
    INSERT INTO reservar (fecha_devolucion, fecha_prestamo, cod_libro, usu_id)
    VALUES (V_fecha_devolucion, CURDATE(), p_cod_libro, p_usu_id);

    -- Actualizar inventario
    UPDATE inventario
    SET cantidad_libros = cantidad_libros - 1
    WHERE cod_libro = p_cod_libro AND cod_sede = v_sede;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Carga_sede` (IN `p_Sed_Nombre` VARCHAR(100), IN `p_ID_Direccion` INT, IN `p_Id_Telefono` INT, IN `p_Num_Sede` INT, IN `p_Id_Correo` INT, IN `p_sed_correo` VARCHAR(100))   BEGIN
    DECLARE v_cod_sede INT;
    DECLARE v_direccion_existe INT;
    DECLARE v_telefono_existe INT;
    DECLARE v_correo_existe INT;

    -- Verificar existencia de dirección
    SELECT COUNT(*) INTO v_direccion_existe
    FROM dirección
    WHERE id_direccion = p_ID_Direccion;
    
    IF v_direccion_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La dirección especificada no existe';
    END IF;

    -- Verificar existencia de teléfono
    SELECT COUNT(*) INTO v_telefono_existe
    FROM telefono
    WHERE id_telefono = p_Id_Telefono;
    
    IF v_telefono_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El teléfono especificado no existe';
    END IF;

    -- Verificar existencia de correo
    SELECT COUNT(*) INTO v_correo_existe
    FROM correo
    WHERE id_correo = p_Id_Correo;
    
    IF v_correo_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El correo especificado no existe';
    END IF;

    -- Insertar en sede
    INSERT INTO sede (sed_nombre, id_direccion)
    VALUES (p_Sed_Nombre, p_ID_Direccion);

    -- Obtener cod_sede autogenerado
    SET v_cod_sede = LAST_INSERT_ID();

    -- Insertar en sede_telefono
    INSERT INTO sede_telefono (cod_sede, id_telefono, num_sede)
    VALUES (v_cod_sede, p_Id_Telefono, p_Num_Sede);

    -- Insertar en sede_correo
    INSERT INTO sede_correo (id_correo, cod_sede, sed_correo)
    VALUES (p_Id_Correo, v_cod_sede, p_sed_correo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `carga_usuario` (IN `p_usu_nombre` VARCHAR(100), IN `p_usu_apellido` VARCHAR(100), IN `p_usu_fecha_naci` DATE, IN `p_cod_carrera` INT, IN `p_cod_sede` INT, IN `p_id_telefono` INT, IN `p_id_correo` INT, IN `p_num_usuario` BIGINT, IN `p_correo_usuario` VARCHAR(100))   BEGIN
  DECLARE verificacion_carrera INT;
  DECLARE verificacion_sede INT;
  DECLARE verificacion_telefono INT;
  DECLARE verificacion_correo INT;
  DECLARE v_id INT;
  DECLARE v_edad INT;

  -- Verificar existencia
  SELECT COUNT(*) INTO verificacion_carrera FROM carrera WHERE cod_carrera = p_cod_carrera;
  IF verificacion_carrera = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La carrera especificada no existe';
  END IF;

  SELECT COUNT(*) INTO verificacion_sede FROM sede WHERE cod_sede = p_cod_sede;
  IF verificacion_sede = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La sede especificada no existe';
  END IF;

  SELECT COUNT(*) INTO verificacion_telefono FROM telefono WHERE id_telefono = p_id_telefono;
  IF verificacion_telefono = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El tipo de teléfono no existe';
  END IF;

  SELECT COUNT(*) INTO verificacion_correo FROM correo WHERE id_correo = p_id_correo;
  IF verificacion_correo = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El tipo de correo no existe';
  END IF;

  -- Calcular edad
  SET v_edad = TIMESTAMPDIFF(YEAR, p_usu_fecha_naci, CURDATE());

  -- Insertar usuario
  INSERT INTO usuario (usu_nombre, usu_apellido, usu_fecha_naci, usu_edad, fecha_registro, cod_carrera, cod_sede)
  VALUES (p_usu_nombre, p_usu_apellido, p_usu_fecha_naci, v_edad, CURDATE(), p_cod_carrera, p_cod_sede);

  -- Obtener el ID generado automáticamente
  SET v_id = LAST_INSERT_ID();

  -- Insertar teléfono y correo
  INSERT INTO usuario_telefono (usu_id, id_telefono, num_usuario)
  VALUES (v_id, p_id_telefono, p_num_usuario);

  INSERT INTO usuario_correo (id_correo, usu_id, correo_usuario)
  VALUES (p_id_correo, v_id, p_correo_usuario);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `devolucion_prestamo` (IN `p_cod_reserva` INT)   BEGIN
    DECLARE v_libro INT;
    DECLARE v_usuario INT;
    DECLARE v_sede INT;
    DECLARE verificacion_reserva INT;

    -- Verificar existencia de la reserva
    SELECT COUNT(*) INTO verificacion_reserva
    FROM reservar
    WHERE cod_reserva = p_cod_reserva;

    IF verificacion_reserva = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La reserva especificada no existe';
    END IF;

    -- Obtener cod_libro y id_usuario
    SELECT cod_libro, usu_id INTO v_libro, v_usuario
    FROM reservar
    WHERE cod_reserva = p_cod_reserva;

    -- Obtener sede del usuario
    SELECT cod_sede INTO v_sede
    FROM usuario
    WHERE usu_id = v_usuario;

    -- Devolver el libro al inventario
    UPDATE inventario
    SET cantidad_libros = cantidad_libros + 1
    WHERE cod_sede = v_sede AND cod_libro = v_libro;

    -- Eliminar la reserva
    DELETE FROM reservar WHERE cod_reserva = p_cod_reserva;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `renovar_reserva` (IN `p_cod_reserva` INT)   BEGIN
    DECLARE v_fecha_devolucion DATE;

    -- Verificar si la reserva existe
    SELECT fecha_devolucion INTO v_fecha_devolucion
    FROM reservar
    WHERE cod_reserva = p_cod_reserva;

    -- Añadir 7 días a la fecha actual de devolución
    SET v_fecha_devolucion = DATE_ADD(v_fecha_devolucion, INTERVAL 7 DAY);

    -- Actualizar la nueva fecha de devolución
    UPDATE reservar
    SET fecha_devolucion = v_fecha_devolucion
    WHERE cod_reserva = p_cod_reserva;

END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `calcular_edad` (`p_fecha_nacimiento` DATE) RETURNS INT(11) DETERMINISTIC BEGIN
  DECLARE v_edad INT;
  SET v_edad = TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
  RETURN v_edad;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_reserva`
--

CREATE TABLE `auditoria_reserva` (
  `id_aud_usuario` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `aud_id_libro` int(11) DEFAULT NULL,
  `aud_id_reserva` int(11) DEFAULT NULL,
  `aud_fecha_devolucion` date DEFAULT NULL,
  `aud_fecha_prestamo` date DEFAULT NULL,
  `accion` varchar(15) DEFAULT NULL,
  `usuario_encargado` varchar(15) DEFAULT NULL,
  `fecha_evento` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_usuario`
--

CREATE TABLE `auditoria_usuario` (
  `id_au_usuario` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `aud_usu_nombre` varchar(25) DEFAULT NULL,
  `aud_usu_apellido` varchar(25) DEFAULT NULL,
  `aud_usu_fecha_naci` date DEFAULT NULL,
  `aud_usu_edad` int(11) DEFAULT NULL,
  `aud_usu_cod_carrera` int(11) DEFAULT NULL,
  `aud_usu_cod_sede` int(11) DEFAULT NULL,
  `usuario_encargado` varchar(15) DEFAULT NULL,
  `accion` varchar(15) DEFAULT NULL,
  `fecha_evento` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria_usuario`
--

INSERT INTO `auditoria_usuario` (`id_au_usuario`, `id_usuario`, `aud_usu_nombre`, `aud_usu_apellido`, `aud_usu_fecha_naci`, `aud_usu_edad`, `aud_usu_cod_carrera`, `aud_usu_cod_sede`, `usuario_encargado`, `accion`, `fecha_evento`) VALUES
(1, 4, 'jose', 'centella', '2004-05-19', 21, 9, 0, 'root@localhost', 'INSERT', '2025-07-18 06:21:41');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

CREATE TABLE `autor` (
  `cod_autor` int(11) NOT NULL,
  `au_nombre` varchar(25) NOT NULL,
  `au_apellido` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `autor`
--

INSERT INTO `autor` (`cod_autor`, `au_nombre`, `au_apellido`) VALUES
(1, 'Gabriel', 'Garcia'),
(2, 'Isabel', 'Allende'),
(3, 'Mario', 'Vargas'),
(4, 'Carlos', 'Zafon'),
(5, 'Paulo', 'Coelho');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bibliotecario`
--

CREATE TABLE `bibliotecario` (
  `id_bibliotecario` int(11) NOT NULL,
  `bibli_nombre` varchar(25) NOT NULL,
  `bibli_apellido` varchar(25) NOT NULL,
  `cod_sede` int(11) NOT NULL,
  `bibli_contraseña` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bibliotecario`
--

INSERT INTO `bibliotecario` (`id_bibliotecario`, `bibli_nombre`, `bibli_apellido`, `cod_sede`, `bibli_contraseña`) VALUES
(1, 'Ana', 'Martinez', 0, 'wsrg421GH'),
(2, 'Luis', 'Gonzalez', 2, '4GFK49');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bibliotecario_correo`
--

CREATE TABLE `bibliotecario_correo` (
  `id_correo` int(11) NOT NULL,
  `id_bibliotecario` int(11) NOT NULL,
  `correo_bibli` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bibliotecario_correo`
--

INSERT INTO `bibliotecario_correo` (`id_correo`, `id_bibliotecario`, `correo_bibli`) VALUES
(4, 1, 'Ana.Martinez@correo.com'),
(5, 2, 'Luis.Gonzalez@correo.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bibliotecario_telefono`
--

CREATE TABLE `bibliotecario_telefono` (
  `id_bibliotecario` int(11) NOT NULL,
  `id_telefono` int(11) NOT NULL,
  `num_bibliotecario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `bibliotecario_telefono`
--

INSERT INTO `bibliotecario_telefono` (`id_bibliotecario`, `id_telefono`, `num_bibliotecario`) VALUES
(1, 1, 664530453),
(2, 2, 64534234);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrera`
--

CREATE TABLE `carrera` (
  `cod_carrera` int(11) NOT NULL,
  `car_nombre` varchar(25) NOT NULL,
  `car_duracion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `carrera`
--

INSERT INTO `carrera` (`cod_carrera`, `car_nombre`, `car_duracion`) VALUES
(9, 'Sistemas Computacionales', 7),
(10, 'Medicina', 8),
(11, 'Admin. de Empresas', 4),
(12, 'Derecho', 4),
(13, 'Arquitectura', 6),
(14, 'Psicología', 5),
(15, 'Desarrollo de Software', 5),
(16, 'Ingeniería Civil', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id_categoria`, `nombre_categoria`) VALUES
(1, 'Novela'),
(2, 'Literatura Contemporánea'),
(3, 'Realismo Mágico'),
(4, 'Ficción Histórica'),
(5, 'Autoayuda');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `correo`
--

CREATE TABLE `correo` (
  `id_correo` int(11) NOT NULL,
  `tipo_correo` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `correo`
--

INSERT INTO `correo` (`id_correo`, `tipo_correo`) VALUES
(4, 'Personal'),
(5, 'Administrativo'),
(6, 'Educativo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `dirección`
--

CREATE TABLE `dirección` (
  `id_direccion` int(11) NOT NULL,
  `provincia` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `dirección`
--

INSERT INTO `dirección` (`id_direccion`, `provincia`) VALUES
(2, 'Panamá'),
(3, 'Panamá Oeste'),
(4, 'Darién');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editorial`
--

CREATE TABLE `editorial` (
  `cod_editorial` int(11) NOT NULL,
  `edi_nombre` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `editorial`
--

INSERT INTO `editorial` (`cod_editorial`, `edi_nombre`) VALUES
(1, 'Editorial Sudamericana'),
(2, 'Editorial Mondadori'),
(3, 'Editorial Planeta'),
(4, 'Editorial Seix Barral'),
(5, 'Editorial Alfaguara');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editorial_correo`
--

CREATE TABLE `editorial_correo` (
  `id_correo` int(11) NOT NULL,
  `cod_editorial` int(11) NOT NULL,
  `correo_editorial` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `editorial_correo`
--

INSERT INTO `editorial_correo` (`id_correo`, `cod_editorial`, `correo_editorial`) VALUES
(4, 1, 'Sudamericana@correo.com'),
(4, 4, 'SeixBarralalma@correo.com'),
(5, 2, 'Mondadori@correo.com'),
(5, 5, 'Alfaguara@correo.com'),
(6, 3, 'Planeta@correo.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `editorial_telefono`
--

CREATE TABLE `editorial_telefono` (
  `cod_editorial` int(11) NOT NULL,
  `id_telefono` int(11) NOT NULL,
  `num_editorial` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `editorial_telefono`
--

INSERT INTO `editorial_telefono` (`cod_editorial`, `id_telefono`, `num_editorial`) VALUES
(1, 1, 2567894),
(2, 2, 8717867),
(3, 3, 6148644),
(4, 1, 6897819),
(5, 2, 6617891);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `cod_libro` int(11) NOT NULL,
  `cod_sede` int(11) NOT NULL,
  `cantidad_libros` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`cod_libro`, `cod_sede`, `cantidad_libros`) VALUES
(1, 2, 10),
(2, 3, 25),
(3, 4, 47),
(4, 0, 82),
(5, 2, 26),
(6, 3, 32),
(7, 4, 32),
(8, 0, 74),
(9, 2, 57),
(10, 3, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro`
--

CREATE TABLE `libro` (
  `cod_libro` int(11) NOT NULL,
  `lib_año_publicacion` int(11) NOT NULL,
  `lib_edicion` int(11) NOT NULL,
  `lib_nombre` varchar(50) NOT NULL,
  `lib_isbn` varchar(50) NOT NULL,
  `cod_sede` int(11) NOT NULL,
  `cod_editorial` int(11) NOT NULL,
  `cod_autor` int(11) NOT NULL,
  `url_portada` varchar(255) NOT NULL,
  `id_categoria` int(11) DEFAULT NULL,
  `lib_descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libro`
--

INSERT INTO `libro` (`cod_libro`, `lib_año_publicacion`, `lib_edicion`, `lib_nombre`, `lib_isbn`, `cod_sede`, `cod_editorial`, `cod_autor`, `url_portada`, `id_categoria`, `lib_descripcion`) VALUES
(1, 1967, 1, 'Cien años de soledad', '978-3-16-148410-0', 2, 1, 1, 'https://ellector.com.pa/cdn/shop/products/portada_cien-anos-de-soledad-50aniv-td_gabriel-garcia-marquez_201706130024.jpg?v=1674332754', 3, 'Esta obra maestra de Gabriel García Márquez narra la historia de la familia Buendía en el mítico pueblo de Macondo, entrelazando generaciones con elementos de realismo mágico que exploran la soledad, el poder y el destino.'),
(2, 1985, 1, 'El amor en los tiempos del cólera', '978-3-16-148411-7', 3, 1, 1, 'https://ellector.com.pa/cdn/shop/files/9786070757686.jpg?v=1733952569&width=739', 3, 'Una historia profundamente emotiva sobre un amor que sobrevive más de medio siglo, desafiando el paso del tiempo, las convenciones sociales y las enfermedades del cuerpo y del alma.'),
(3, 1987, 1, 'Eva Luna', '978-3-16-148422-3', 4, 2, 2, 'https://ellector.com.pa/cdn/shop/files/eva-luna.jpg?v=1715878515', 2, 'Isabel Allende construye una heroína inolvidable en esta novela que celebra el poder de la imaginación y la palabra, ambientada en un mundo turbulento marcado por luchas políticas y sociales.'),
(4, 2022, 1, 'Violeta', '978-3-16-148429-2', 0, 2, 2, 'https://ellector.com.pa/cdn/shop/products/9789500766647.jpg?v=1699135647', 4, 'A través de las memorias de su protagonista, esta novela recorre cien años de historia latinoamericana, mostrando las transformaciones sociales desde los ojos de una mujer apasionada y rebelde.'),
(5, 1963, 1, 'La ciudad y los perros', '978-3-16-148430-8', 2, 3, 3, 'https://www.crisol.com.pe/media/catalog/product/cache/f6d2c62455a42b0d712f6c919e880845/9/7/9786125020727_xfkcnfnexyuo1x3z.jpg', 1, 'Un relato crudo y descarnado sobre la vida en un colegio militar peruano, donde la violencia, la hipocresía y el abuso reflejan los males estructurales de una sociedad autoritaria.'),
(6, 1969, 1, 'Conversación en la catedral', '978-3-16-148432-2', 3, 3, 3, 'https://elcomercio.pe/resizer/a8PxNvsL6x8vWSDzEJzgsg4Ceb8=/1200x675/smart/filters:format(jpeg):quality(75)/arc-anglerfish-arc2-prod-elcomercio.s3.amazonaws.com/public/WATFICHTKBCCVORPA47ABNXGEE.jpg', 1, 'En un Lima corrupto y desencantado, dos personajes dialogan sobre sus vidas y frustraciones, revelando un retrato complejo y profundo del Perú bajo una dictadura.'),
(7, 2016, 1, 'El laberinto de los espíritus', '978-3-16-148443-8', 4, 2, 4, 'https://www.planetadelibros.com/usuaris/libros/fotos/222/original/portada_el-laberinto-de-los-espiritus_carlos-ruiz-zafon_201608291240.jpg', 2, 'Con un ritmo de thriller y un trasfondo literario, esta novela culmina la tetralogía de Zafón desentrañando misterios familiares, políticos y editoriales en una Barcelona oscura y fascinante.'),
(8, 1999, 1, 'Marina', '978-3-16-148445-2', 0, 2, 4, 'https://www.planetadelibros.com/usuaris/libros/fotos/222/original/portada_el-laberinto-de-los-espiritus_carlos-ruiz-zafon_201608291240.jpg', 1, 'Una historia de amor juvenil, misterio y horror que entrelaza los secretos del pasado con el presente en una Barcelona envuelta en niebla, donde la belleza convive con lo siniestro.'),
(9, 1988, 1, 'El alquimista', '978-3-16-148450-6', 2, 2, 5, 'https://ellector.com.pa/cdn/shop/files/9786073158602.jpg?v=1701545865', 5, 'Paulo Coelho ofrece una parábola espiritual sobre la importancia de perseguir los sueños personales y aprender de los signos del universo, con un joven pastor como protagonista.'),
(10, 1998, 1, 'Veronika decide morir', '978-3-16-148453-7', 3, 2, 5, 'https://www.planetadelibros.com/usuaris/libros/fotos/329/original/portada_veronika-decide-morir_paulo-coelho_202012141708.jpg', 5, 'Una joven aparentemente exitosa intenta suicidarse y despierta en un hospital psiquiátrico, donde descubrirá que la vida, aún en sus formas más inusuales, merece ser vivida.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `oferta`
--

CREATE TABLE `oferta` (
  `cod_sede` int(11) NOT NULL,
  `cod_carrera` int(11) NOT NULL,
  `cantidad_cupos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `oferta`
--

INSERT INTO `oferta` (`cod_sede`, `cod_carrera`, `cantidad_cupos`) VALUES
(2, 9, 100),
(2, 11, 176),
(3, 10, 150),
(4, 12, 870),
(4, 13, 342);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reservar`
--

CREATE TABLE `reservar` (
  `cod_reserva` int(11) NOT NULL,
  `fecha_devolucion` date NOT NULL,
  `fecha_prestamo` date NOT NULL,
  `cod_libro` int(11) NOT NULL,
  `usu_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `reservar`
--

INSERT INTO `reservar` (`cod_reserva`, `fecha_devolucion`, `fecha_prestamo`, `cod_libro`, `usu_id`) VALUES
(5, '2025-07-25', '2025-07-18', 8, 4);

--
-- Disparadores `reservar`
--
DELIMITER $$
CREATE TRIGGER `t_inventario_bajo` BEFORE INSERT ON `reservar` FOR EACH ROW BEGIN
  DECLARE v_cantidad_libros INT;

  SELECT cantidad_libros
  INTO v_cantidad_libros
  FROM inventario
  WHERE cod_libro = NEW.cod_libro AND cod_sede = (
    SELECT cod_sede FROM usuario WHERE usu_id = NEW.usu_id
  );

  IF v_cantidad_libros < 1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No se pueden realizar más reservas. El inventario del libro está por debajo del umbral mínimo.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sede`
--

CREATE TABLE `sede` (
  `cod_sede` int(11) NOT NULL,
  `sed_nombre` varchar(25) NOT NULL,
  `id_direccion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sede`
--

INSERT INTO `sede` (`cod_sede`, `sed_nombre`, `id_direccion`) VALUES
(0, 'Sede Central', 2),
(2, 'Sede Este', 4),
(3, 'Sede Oeste', 3),
(4, 'Sede Norte', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sede_correo`
--

CREATE TABLE `sede_correo` (
  `id_correo` int(11) NOT NULL,
  `cod_sede` int(11) NOT NULL,
  `sed_correo` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sede_correo`
--

INSERT INTO `sede_correo` (`id_correo`, `cod_sede`, `sed_correo`) VALUES
(5, 0, 'Sedecentral@correo.com'),
(5, 2, 'Sedeeste@correo.com'),
(5, 3, 'Sedeoeste@correo.com'),
(5, 4, 'Sedenorte@correo.com');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sede_telefono`
--

CREATE TABLE `sede_telefono` (
  `cod_sede` int(11) NOT NULL,
  `id_telefono` int(11) NOT NULL,
  `num_sede` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sede_telefono`
--

INSERT INTO `sede_telefono` (`cod_sede`, `id_telefono`, `num_sede`) VALUES
(0, 2, 8195195),
(2, 2, 15681688),
(3, 2, 98488891),
(4, 2, 1198498);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefono`
--

CREATE TABLE `telefono` (
  `id_telefono` int(11) NOT NULL,
  `tipo_telefono` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `telefono`
--

INSERT INTO `telefono` (`id_telefono`, `tipo_telefono`) VALUES
(1, 'Movil'),
(2, 'Fijo'),
(3, 'Familiar más cercano');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `usu_id` int(11) NOT NULL,
  `usu_nombre` varchar(25) NOT NULL,
  `usu_apellido` varchar(25) NOT NULL,
  `usu_fecha_naci` date NOT NULL,
  `usu_edad` int(11) NOT NULL,
  `fecha_registro` date NOT NULL,
  `cod_carrera` int(11) NOT NULL,
  `cod_sede` int(11) NOT NULL,
  `usu_contraseña` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`usu_id`, `usu_nombre`, `usu_apellido`, `usu_fecha_naci`, `usu_edad`, `fecha_registro`, `cod_carrera`, `cod_sede`, `usu_contraseña`) VALUES
(1, 'Juan', 'Pérez', '1999-03-15', 26, '2025-07-16', 9, 2, '123tjopp'),
(2, 'María', 'González', '2000-11-11', 24, '2025-07-16', 10, 3, 'rytg24yl*5'),
(3, 'Carlos', 'Ramírez', '2001-08-22', 23, '2025-07-16', 11, 4, ''),
(4, 'jose', 'centella', '2004-05-19', 21, '2025-07-18', 9, 0, '1234');

--
-- Disparadores `usuario`
--
DELIMITER $$
CREATE TRIGGER `t_auditoria_usuario` AFTER INSERT ON `usuario` FOR EACH ROW BEGIN
  INSERT INTO auditoria_usuario (
    id_usuario,
    aud_usu_nombre,
    aud_usu_apellido,
    aud_usu_fecha_naci,
    aud_usu_edad,
    aud_usu_cod_carrera,
    aud_usu_cod_sede,
    usuario_encargado,
    accion,
    fecha_evento
  )
  VALUES (
    NEW.usu_id,
    NEW.usu_nombre,
    NEW.usu_apellido,
    NEW.usu_fecha_naci,
    NEW.usu_edad,
    NEW.cod_carrera,
    NEW.cod_sede,
    CURRENT_USER(),
    'INSERT',
    NOW()
  );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_deletear_usuario` AFTER DELETE ON `usuario` FOR EACH ROW BEGIN
  UPDATE oferta
  SET cantidad_cupos = cantidad_cupos - 1
  WHERE cod_sede = OLD.cod_sede AND cod_carrera = OLD.cod_carrera;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_insertar_usuario` AFTER INSERT ON `usuario` FOR EACH ROW BEGIN
  UPDATE oferta
  SET cantidad_cupos = cantidad_cupos + 1
  WHERE cod_sede = NEW.cod_sede AND cod_carrera = NEW.cod_carrera;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_correo`
--

CREATE TABLE `usuario_correo` (
  `id_correo` int(11) NOT NULL,
  `usu_id` int(11) NOT NULL,
  `correo_usuario` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_correo`
--

INSERT INTO `usuario_correo` (`id_correo`, `usu_id`, `correo_usuario`) VALUES
(5, 2, 'maria.gonzalez@correo.com'),
(6, 3, 'carlos.ramirez@correo.com'),
(6, 4, 'Jose.centella1@utp.ac.pa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_telefono`
--

CREATE TABLE `usuario_telefono` (
  `usu_id` int(11) NOT NULL,
  `id_telefono` int(11) NOT NULL,
  `num_usuario` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_telefono`
--

INSERT INTO `usuario_telefono` (`usu_id`, `id_telefono`, `num_usuario`) VALUES
(2, 2, 61981984),
(3, 3, 60094864),
(4, 1, 69321644);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_bibliotecarios_info`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_bibliotecarios_info` (
`id_bibliotecario` int(11)
,`bibli_nombre` varchar(25)
,`bibli_apellido` varchar(25)
,`telefono` int(11)
,`correo` varchar(30)
,`sede` varchar(25)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_librosdisponibles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_librosdisponibles` (
`cod_libro` int(11)
,`ano_publicacion` int(11)
,`edicion` int(11)
,`titulo` varchar(50)
,`ISBN` varchar(50)
,`sede` varchar(25)
,`editorial` varchar(25)
,`autor` varchar(51)
,`cantidad` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_reservas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_reservas` (
`cod_reserva` int(11)
,`fecha_prestamo` date
,`fecha_devolucion` date
,`titulo_libro` varchar(50)
,`usuario` varchar(51)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_usuarios_contacto`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_usuarios_contacto` (
`usu_id` int(11)
,`usu_nombre` varchar(25)
,`usu_apellido` varchar(25)
,`usu_fecha_naci` date
,`usu_edad` int(11)
,`telefono` int(11)
,`correo` varchar(30)
,`sede` varchar(25)
,`carrera` varchar(25)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_bibliotecarios_info`
--
DROP TABLE IF EXISTS `v_bibliotecarios_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_bibliotecarios_info`  AS SELECT `b`.`id_bibliotecario` AS `id_bibliotecario`, `b`.`bibli_nombre` AS `bibli_nombre`, `b`.`bibli_apellido` AS `bibli_apellido`, `bt`.`num_bibliotecario` AS `telefono`, `bc`.`correo_bibli` AS `correo`, `s`.`sed_nombre` AS `sede` FROM (((`bibliotecario` `b` left join `bibliotecario_telefono` `bt` on(`b`.`id_bibliotecario` = `bt`.`id_bibliotecario`)) left join `bibliotecario_correo` `bc` on(`b`.`id_bibliotecario` = `bc`.`id_bibliotecario`)) left join `sede` `s` on(`b`.`cod_sede` = `s`.`cod_sede`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_librosdisponibles`
--
DROP TABLE IF EXISTS `v_librosdisponibles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_librosdisponibles`  AS SELECT `l`.`cod_libro` AS `cod_libro`, `l`.`lib_año_publicacion` AS `ano_publicacion`, `l`.`lib_edicion` AS `edicion`, `l`.`lib_nombre` AS `titulo`, `l`.`lib_isbn` AS `ISBN`, `s`.`sed_nombre` AS `sede`, `e`.`edi_nombre` AS `editorial`, concat(`a`.`au_nombre`,' ',`a`.`au_apellido`) AS `autor`, `i`.`cantidad_libros` AS `cantidad` FROM ((((`libro` `l` left join `sede` `s` on(`l`.`cod_sede` = `s`.`cod_sede`)) left join `editorial` `e` on(`l`.`cod_editorial` = `e`.`cod_editorial`)) left join `autor` `a` on(`l`.`cod_autor` = `a`.`cod_autor`)) left join `inventario` `i` on(`l`.`cod_libro` = `i`.`cod_libro`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_reservas`
--
DROP TABLE IF EXISTS `v_reservas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_reservas`  AS SELECT `r`.`cod_reserva` AS `cod_reserva`, `r`.`fecha_prestamo` AS `fecha_prestamo`, `r`.`fecha_devolucion` AS `fecha_devolucion`, `l`.`lib_nombre` AS `titulo_libro`, concat(`u`.`usu_nombre`,' ',`u`.`usu_apellido`) AS `usuario` FROM ((`reservar` `r` join `libro` `l` on(`r`.`cod_libro` = `l`.`cod_libro`)) join `usuario` `u` on(`r`.`usu_id` = `u`.`usu_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_usuarios_contacto`
--
DROP TABLE IF EXISTS `v_usuarios_contacto`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_usuarios_contacto`  AS SELECT `u`.`usu_id` AS `usu_id`, `u`.`usu_nombre` AS `usu_nombre`, `u`.`usu_apellido` AS `usu_apellido`, `u`.`usu_fecha_naci` AS `usu_fecha_naci`, `u`.`usu_edad` AS `usu_edad`, `ut`.`num_usuario` AS `telefono`, `uc`.`correo_usuario` AS `correo`, `s`.`sed_nombre` AS `sede`, `c`.`car_nombre` AS `carrera` FROM ((((`usuario` `u` left join `usuario_telefono` `ut` on(`u`.`usu_id` = `ut`.`usu_id`)) left join `usuario_correo` `uc` on(`u`.`usu_id` = `uc`.`usu_id`)) left join `sede` `s` on(`u`.`cod_sede` = `s`.`cod_sede`)) left join `carrera` `c` on(`u`.`cod_carrera` = `c`.`cod_carrera`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_reserva`
--
ALTER TABLE `auditoria_reserva`
  ADD PRIMARY KEY (`id_aud_usuario`);

--
-- Indices de la tabla `auditoria_usuario`
--
ALTER TABLE `auditoria_usuario`
  ADD PRIMARY KEY (`id_au_usuario`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`cod_autor`);

--
-- Indices de la tabla `bibliotecario`
--
ALTER TABLE `bibliotecario`
  ADD PRIMARY KEY (`id_bibliotecario`);

--
-- Indices de la tabla `bibliotecario_correo`
--
ALTER TABLE `bibliotecario_correo`
  ADD PRIMARY KEY (`id_correo`,`id_bibliotecario`),
  ADD KEY `correo_biblio` (`id_bibliotecario`);

--
-- Indices de la tabla `bibliotecario_telefono`
--
ALTER TABLE `bibliotecario_telefono`
  ADD PRIMARY KEY (`id_bibliotecario`,`id_telefono`),
  ADD KEY `bibliotecario_telefono_id` (`id_telefono`);

--
-- Indices de la tabla `carrera`
--
ALTER TABLE `carrera`
  ADD PRIMARY KEY (`cod_carrera`);

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `correo`
--
ALTER TABLE `correo`
  ADD PRIMARY KEY (`id_correo`);

--
-- Indices de la tabla `dirección`
--
ALTER TABLE `dirección`
  ADD PRIMARY KEY (`id_direccion`);

--
-- Indices de la tabla `editorial`
--
ALTER TABLE `editorial`
  ADD PRIMARY KEY (`cod_editorial`);

--
-- Indices de la tabla `editorial_correo`
--
ALTER TABLE `editorial_correo`
  ADD PRIMARY KEY (`id_correo`,`cod_editorial`),
  ADD KEY `correo_edi` (`cod_editorial`),
  ADD KEY `id_correo` (`id_correo`),
  ADD KEY `id_correo_2` (`id_correo`);

--
-- Indices de la tabla `editorial_telefono`
--
ALTER TABLE `editorial_telefono`
  ADD PRIMARY KEY (`cod_editorial`,`id_telefono`),
  ADD KEY `editorial_telefono_id` (`id_telefono`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`cod_libro`,`cod_sede`),
  ADD KEY `inv_sede` (`cod_sede`);

--
-- Indices de la tabla `libro`
--
ALTER TABLE `libro`
  ADD PRIMARY KEY (`cod_libro`),
  ADD KEY `libro_autor` (`cod_autor`),
  ADD KEY `libro_sede` (`cod_sede`),
  ADD KEY `libro_editorial` (`cod_editorial`),
  ADD KEY `fk_categoria_libro` (`id_categoria`);

--
-- Indices de la tabla `oferta`
--
ALTER TABLE `oferta`
  ADD PRIMARY KEY (`cod_sede`,`cod_carrera`),
  ADD KEY `oferta_carrera` (`cod_carrera`);

--
-- Indices de la tabla `reservar`
--
ALTER TABLE `reservar`
  ADD PRIMARY KEY (`cod_reserva`),
  ADD KEY `reserva_libro` (`cod_libro`),
  ADD KEY `reserva_usu` (`usu_id`);

--
-- Indices de la tabla `sede`
--
ALTER TABLE `sede`
  ADD PRIMARY KEY (`cod_sede`),
  ADD KEY `sede_direccion` (`id_direccion`);

--
-- Indices de la tabla `sede_correo`
--
ALTER TABLE `sede_correo`
  ADD PRIMARY KEY (`id_correo`,`cod_sede`),
  ADD KEY `sede_correo` (`cod_sede`);

--
-- Indices de la tabla `sede_telefono`
--
ALTER TABLE `sede_telefono`
  ADD PRIMARY KEY (`cod_sede`,`id_telefono`),
  ADD KEY `sede_telefono_id` (`id_telefono`);

--
-- Indices de la tabla `telefono`
--
ALTER TABLE `telefono`
  ADD PRIMARY KEY (`id_telefono`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`usu_id`),
  ADD KEY `usu_carrera` (`cod_carrera`),
  ADD KEY `usu_sede` (`cod_sede`);

--
-- Indices de la tabla `usuario_correo`
--
ALTER TABLE `usuario_correo`
  ADD PRIMARY KEY (`id_correo`,`usu_id`),
  ADD KEY `usu_correo` (`usu_id`);

--
-- Indices de la tabla `usuario_telefono`
--
ALTER TABLE `usuario_telefono`
  ADD PRIMARY KEY (`usu_id`,`id_telefono`),
  ADD KEY `usuario_telefono_id` (`id_telefono`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_reserva`
--
ALTER TABLE `auditoria_reserva`
  MODIFY `id_aud_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auditoria_usuario`
--
ALTER TABLE `auditoria_usuario`
  MODIFY `id_au_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `autor`
--
ALTER TABLE `autor`
  MODIFY `cod_autor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `bibliotecario`
--
ALTER TABLE `bibliotecario`
  MODIFY `id_bibliotecario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `carrera`
--
ALTER TABLE `carrera`
  MODIFY `cod_carrera` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `correo`
--
ALTER TABLE `correo`
  MODIFY `id_correo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `dirección`
--
ALTER TABLE `dirección`
  MODIFY `id_direccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `editorial`
--
ALTER TABLE `editorial`
  MODIFY `cod_editorial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `libro`
--
ALTER TABLE `libro`
  MODIFY `cod_libro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `reservar`
--
ALTER TABLE `reservar`
  MODIFY `cod_reserva` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `sede`
--
ALTER TABLE `sede`
  MODIFY `cod_sede` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `telefono`
--
ALTER TABLE `telefono`
  MODIFY `id_telefono` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `usu_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `bibliotecario_correo`
--
ALTER TABLE `bibliotecario_correo`
  ADD CONSTRAINT `bibliotecario_correo_id` FOREIGN KEY (`id_correo`) REFERENCES `correo` (`id_correo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `correo_biblio` FOREIGN KEY (`id_bibliotecario`) REFERENCES `bibliotecario` (`id_bibliotecario`);

--
-- Filtros para la tabla `bibliotecario_telefono`
--
ALTER TABLE `bibliotecario_telefono`
  ADD CONSTRAINT `bibliotecario_telefono_id` FOREIGN KEY (`id_telefono`) REFERENCES `telefono` (`id_telefono`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tel_biblio` FOREIGN KEY (`id_bibliotecario`) REFERENCES `bibliotecario` (`id_bibliotecario`);

--
-- Filtros para la tabla `editorial_correo`
--
ALTER TABLE `editorial_correo`
  ADD CONSTRAINT `cod_correo` FOREIGN KEY (`id_correo`) REFERENCES `correo` (`id_correo`),
  ADD CONSTRAINT `correo_edi` FOREIGN KEY (`cod_editorial`) REFERENCES `editorial` (`cod_editorial`);

--
-- Filtros para la tabla `editorial_telefono`
--
ALTER TABLE `editorial_telefono`
  ADD CONSTRAINT `editorial_telefono_id` FOREIGN KEY (`id_telefono`) REFERENCES `telefono` (`id_telefono`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tel_edi` FOREIGN KEY (`cod_editorial`) REFERENCES `editorial` (`cod_editorial`);

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `inv_libro` FOREIGN KEY (`cod_libro`) REFERENCES `libro` (`cod_libro`),
  ADD CONSTRAINT `inv_sede` FOREIGN KEY (`cod_sede`) REFERENCES `sede` (`cod_sede`);

--
-- Filtros para la tabla `libro`
--
ALTER TABLE `libro`
  ADD CONSTRAINT `fk_categoria_libro` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`),
  ADD CONSTRAINT `libro_autor` FOREIGN KEY (`cod_autor`) REFERENCES `autor` (`cod_autor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `libro_editorial` FOREIGN KEY (`cod_editorial`) REFERENCES `editorial` (`cod_editorial`),
  ADD CONSTRAINT `libro_sede` FOREIGN KEY (`cod_sede`) REFERENCES `sede` (`cod_sede`);

--
-- Filtros para la tabla `oferta`
--
ALTER TABLE `oferta`
  ADD CONSTRAINT `oferta_carrera` FOREIGN KEY (`cod_carrera`) REFERENCES `carrera` (`cod_carrera`),
  ADD CONSTRAINT `oferta_sede` FOREIGN KEY (`cod_sede`) REFERENCES `sede` (`cod_sede`);

--
-- Filtros para la tabla `reservar`
--
ALTER TABLE `reservar`
  ADD CONSTRAINT `reserva_libro` FOREIGN KEY (`cod_libro`) REFERENCES `libro` (`cod_libro`),
  ADD CONSTRAINT `reserva_usu` FOREIGN KEY (`usu_id`) REFERENCES `usuario` (`usu_id`);

--
-- Filtros para la tabla `sede`
--
ALTER TABLE `sede`
  ADD CONSTRAINT `sede_direccion` FOREIGN KEY (`id_direccion`) REFERENCES `dirección` (`id_direccion`);

--
-- Filtros para la tabla `sede_correo`
--
ALTER TABLE `sede_correo`
  ADD CONSTRAINT `fk_sede_correo_id` FOREIGN KEY (`id_correo`) REFERENCES `correo` (`id_correo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sede_correo` FOREIGN KEY (`cod_sede`) REFERENCES `sede` (`cod_sede`);

--
-- Filtros para la tabla `sede_telefono`
--
ALTER TABLE `sede_telefono`
  ADD CONSTRAINT `sede_telefono_id` FOREIGN KEY (`id_telefono`) REFERENCES `telefono` (`id_telefono`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `tel_sede` FOREIGN KEY (`cod_sede`) REFERENCES `sede` (`cod_sede`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usu_carrera` FOREIGN KEY (`cod_carrera`) REFERENCES `carrera` (`cod_carrera`),
  ADD CONSTRAINT `usu_sede` FOREIGN KEY (`cod_sede`) REFERENCES `sede` (`cod_sede`);

--
-- Filtros para la tabla `usuario_correo`
--
ALTER TABLE `usuario_correo`
  ADD CONSTRAINT `usu_correo` FOREIGN KEY (`usu_id`) REFERENCES `usuario` (`usu_id`),
  ADD CONSTRAINT `usuario_correo_id` FOREIGN KEY (`id_correo`) REFERENCES `correo` (`id_correo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario_telefono`
--
ALTER TABLE `usuario_telefono`
  ADD CONSTRAINT `usu_telefono` FOREIGN KEY (`usu_id`) REFERENCES `usuario` (`usu_id`),
  ADD CONSTRAINT `usuario_telefono_id` FOREIGN KEY (`id_telefono`) REFERENCES `telefono` (`id_telefono`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
