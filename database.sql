-- ============================================================
-- TIA OLEO 4 - Base de datos (XAMPP / MariaDB 10.4)
-- ============================================================
-- Archivo unico y autocontenido: crea la BD completa desde cero
-- (21 tablas + catalogo de 37 productos). Instalacion:
--   phpMyAdmin -> Importar, o por consola:
--   C:\xampp\mysql\bin\mysql.exe -u root < database.sql
--
-- Diseno escalable: tablas 1:N en vez de columnas sueltas
-- (producto_imagenes, no imagen2/imagen3...), historial en vez
-- de sobrescribir (kardex, pedido_historial) y config clave-valor.
-- ============================================================

CREATE DATABASE IF NOT EXISTS tia_oleo4
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tia_oleo4;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS chatbot_consultas, config_tienda, resenas, pedido_historial,
  pedido_items, pedidos, cotizacion_items, cotizaciones, inventario_movimientos, producto_imagenes,
  productos, proveedores, marcas, gramajes, durezas, tipos_cerda, tipos_pintura,
  usuarios, roles, calidades, categorias;

-- Roles y usuarios (base para login admin/cliente a futuro)
CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO roles (nombre) VALUES ('administrador'), ('cliente');

CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rol_id INT NOT NULL DEFAULT 2,
  nombre VARCHAR(120) NOT NULL,
  telefono VARCHAR(30) DEFAULT '',
  email VARCHAR(150) UNIQUE,
  password_hash VARCHAR(255) NOT NULL COMMENT 'password_hash() de PHP, nunca texto plano',
  direccion VARCHAR(255) DEFAULT '',
  activo TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_usu_rol FOREIGN KEY (rol_id) REFERENCES roles(id),
  INDEX idx_usu_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- admin@tiaoleo.pe / admin123 (cambiala luego)
INSERT INTO usuarios (rol_id, nombre, telefono, email, password_hash) VALUES
(1, 'Administrador', '993706366', 'admin@tiaoleo.pe', '$2y$10$ptEcrQ2QajeFSxRBxxmH6eBD9PF91vt4RupLYQux/At/cjzdO7S7W');

-- Tipos de calidad: 1 Escolar, 2 Artistica, 3 Profesional
CREATE TABLE calidades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255) NOT NULL,
  nivel TINYINT NOT NULL DEFAULT 1,
  color VARCHAR(20) NOT NULL DEFAULT '#6e6b68'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO calidades (nombre, descripcion, nivel, color) VALUES
('Escolar', 'Ideal para colegio y manualidades. Buena relacion precio-calidad.', 1, '#2a9d8f'),
('Artística', 'Para estudiantes y aficionados exigentes. Mejor pigmento y papel.', 2, '#c8553d'),
('Profesional', 'Para artistas y talleres. Maxima pigmentacion, duracion y acabado.', 3, '#7b2d8b');

CREATE TABLE categorias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  slug VARCHAR(50) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO categorias (slug, nombre) VALUES
('papeles', 'Papeles y Blocs'),
('cuadernos', 'Cuadernos y Croqueras'),
('pinturas', 'Pinturas'),
('pinceles', 'Pinceles y Marcadores'),
('lapices', 'Lápices de Colores'),
('lienzos', 'Lienzos y Bastidores'),
('grafito', 'Grafito y Dibujo'),
('accesorios', 'Accesorios y Herramientas');

CREATE TABLE marcas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  pais VARCHAR(60) DEFAULT '',
  descripcion VARCHAR(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO marcas (nombre, pais) VALUES
('Artesco', 'Perú'), ('Faber-Castell', 'Alemania'), ('Vinifan', 'Perú'),
('Stabilo', 'Alemania'), ('Tía Óleo', 'Perú');

CREATE TABLE proveedores (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  ruc VARCHAR(20) DEFAULT '',
  telefono VARCHAR(30) DEFAULT '',
  email VARCHAR(150) DEFAULT '',
  activo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO proveedores (nombre, ruc, telefono) VALUES
('Distribuidora Artesco S.A.', '20100000001', '01-2345678'),
('Importaciones Andinas EIRL', '20600000002', '054-123456');

-- Tablas de consulta para clasificar (v5): se agregan valores sin ALTER
CREATE TABLE gramajes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  valor INT NOT NULL UNIQUE COMMENT 'gramos por m2'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO gramajes (valor) VALUES (60),(75),(80),(90),(100),(120),(150),(180),(200),(250),(300),(350);

CREATE TABLE durezas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(10) NOT NULL UNIQUE COMMENT 'escala del grafito',
  descripcion VARCHAR(120) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO durezas (codigo, descripcion) VALUES
('2H', 'Muy dura, trazo claro'), ('H', 'Dura'), ('HB', 'Media, escritura diaria'),
('B', 'Blanda'), ('2B', 'Blanda, sombreado'), ('4B', 'Muy blanda'),
('6B', 'Extra blanda'), ('8B', 'Máxima suavidad'), ('Media', 'Carboncillo medio'),
('Surtido', 'Set con varias durezas');

CREATE TABLE tipos_cerda (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO tipos_cerda (nombre) VALUES
('Nylon'), ('Sintética'), ('Pelo natural (marta)'), ('Pelo de cabra'), ('Mixta');

CREATE TABLE tipos_pintura (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO tipos_pintura (nombre) VALUES
('Acrílico'), ('Óleo'), ('Témpera'), ('Acuarela');

-- Productos: detalle_venta especifica EXACTAMENTE lo que se vende
CREATE TABLE productos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  categoria_id INT NOT NULL,
  calidad_id INT NOT NULL,
  marca_id INT NULL,
  proveedor_id INT NULL,
  gramaje_id INT NULL COMMENT 'papeles, cuadernos y lienzos',
  dureza_id INT NULL COMMENT 'lapices de grafito',
  cerda_id INT NULL COMMENT 'pinceles',
  tipo_pintura_id INT NULL COMMENT 'oleo, acrilico, tempera, acuarela',
  nombre VARCHAR(150) NOT NULL,
  descripcion VARCHAR(255) NOT NULL,
  detalle_venta VARCHAR(500) NOT NULL,
  contenido VARCHAR(120) NOT NULL DEFAULT '',
  cantidad INT NOT NULL DEFAULT 1 COMMENT 'cuantas piezas trae la venta',
  unidad VARCHAR(30) NOT NULL DEFAULT 'unidad',
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 20,
  imagen VARCHAR(255) NOT NULL COMMENT 'Compatibilidad: la principal vive en producto_imagenes',
  destacado TINYINT(1) NOT NULL DEFAULT 0,
  activo TINYINT(1) NOT NULL DEFAULT 1,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prod_cat FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  CONSTRAINT fk_prod_cal FOREIGN KEY (calidad_id) REFERENCES calidades(id),
  CONSTRAINT fk_prod_marca FOREIGN KEY (marca_id) REFERENCES marcas(id),
  CONSTRAINT fk_prod_prov FOREIGN KEY (proveedor_id) REFERENCES proveedores(id),
  CONSTRAINT fk_prod_gramaje FOREIGN KEY (gramaje_id) REFERENCES gramajes(id),
  CONSTRAINT fk_prod_dureza FOREIGN KEY (dureza_id) REFERENCES durezas(id),
  CONSTRAINT fk_prod_cerda FOREIGN KEY (cerda_id) REFERENCES tipos_cerda(id),
  CONSTRAINT fk_prod_tpint FOREIGN KEY (tipo_pintura_id) REFERENCES tipos_pintura(id),
  INDEX idx_prod_cat (categoria_id), INDEX idx_prod_cal (calidad_id), INDEX idx_prod_marca (marca_id), INDEX idx_prod_gramaje (gramaje_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- (categoria, calidad, marca, proveedor, gramaje, dureza, cerda, tipo_pintura, nombre, descripcion, detalle_venta, contenido, cantidad, unidad, precio, stock, imagen, destacado)
INSERT INTO productos (categoria_id, calidad_id, marca_id, proveedor_id, gramaje_id, dureza_id, cerda_id, tipo_pintura_id, nombre, descripcion, detalle_venta, contenido, cantidad, unidad, precio, stock, imagen, destacado) VALUES
(1, 2, 1, 1, 11, NULL, NULL, NULL, 'Bloc para Pintar con Acrílicos', 'Papel canvas-textura para pinturas acrílicas y técnicas mixtas.', 'Se vende: 1 bloc A3 de 20 hojas, papel 300 g/m2 con textura lienzo. Apto acrílico, óleo ligero y mixta.', '1 bloc x 20 hojas A3', 20, 'hojas', 46.00, 25, 'img/01-bloc-papel-canvas.jpg', 1),
(1, 1, 3, 1, 4, NULL, NULL, NULL, 'Block de Dibujo', 'Papel de calidad superior para dibujo con lápiz, carbón y técnica mixta.', 'Se vende: 1 block A4 de 40 hojas, papel bond 90 g/m2. Ideal lápiz, carbón y tinta.', '1 block x 40 hojas A4', 40, 'hojas', 18.00, 40, 'img/02-block-dibujo.jpg', 0),
(1, 1, 3, 1, 1, NULL, NULL, NULL, 'Block de Papel Calco', 'Papel calco de alta transparencia para calcar dibujos y diseños.', 'Se vende: 1 block A4 de 50 hojas de papel calco translúcido 60 g/m2.', '1 block x 50 hojas A4', 50, 'hojas', 15.00, 35, 'img/06-block-papel-calco.jpg', 0),
(1, 3, 2, 2, 9, NULL, NULL, NULL, 'Block de Papel Calidad Superior', 'Papel profesional con textura ideal para dibujo y técnica mixta.', 'Se vende: 1 block A3 de 25 hojas, papel 200 g/m2 libre de ácido. Para dibujo, tinta y marcador.', '1 block x 25 hojas A3', 25, 'hojas', 35.00, 20, 'img/10-block-papel-calidad-superior.jpg', 0),
(1, 3, 2, 2, 8, NULL, NULL, NULL, 'Block de Dibujo Calidad Superior', 'Papel blanco de superficie satinada, ideal para rotuladores y lápices.', 'Se vende: 1 block A4 de 30 hojas satinadas 180 g/m2. No traspasa el rotulador.', '1 block x 30 hojas A4', 30, 'hojas', 30.00, 22, 'img/20-block-dibujo-calidad.png', 0),
(2, 1, 5, 1, 2, NULL, NULL, NULL, 'Croquera Blank Book', 'Cuaderno en blanco para notas, bocetos y creatividad libre.', 'Se vende: 1 croquera A5 de 80 hojas bond 75 g/m2, tapa blanda. Para boceto y notas.', '1 croquera x 80 hojas A5', 80, 'hojas', 25.00, 30, 'img/07-croquera-blank-book.jpg', 0),
(2, 2, 5, 1, 5, NULL, NULL, NULL, 'Croquera Cuadrada - Forest Green', 'Cuaderno cuadrado con tapa verde bosque, perfecto para bocetos.', 'Se vende: 1 croquera cuadrada 20x20 cm de 60 hojas 100 g/m2, tapa dura verde bosque.', '1 croquera 20x20 cm', 60, 'hojas', 28.00, 24, 'img/08-croquera-cuadrada-forest.jpg', 0),
(2, 2, 5, 1, 5, NULL, NULL, NULL, 'Croquera Diseño Moda', 'Cuaderno especial para bocetos de diseño de moda y croquis.', 'Se vende: 1 croquera A4 de 50 hojas con plantillas de figurín para moda + hojas libres.', '1 croquera x 50 hojas A4', 50, 'hojas', 32.00, 18, 'img/09-croquera-diseno-moda.png', 0),
(2, 3, 5, 1, 7, NULL, NULL, NULL, 'Croquera Hoja Negra Premium', 'Cuaderno sketchbook con hojas negras premium para lápices claros.', 'Se vende: 1 croquera A5 de 40 hojas negras 150 g/m2. Ideal gel blanco, pastel y metálicos.', '1 croquera x 40 hojas negras', 40, 'hojas', 40.00, 15, 'img/11-croquera-hoja-negra.png', 1),
(2, 1, 3, 1, 3, NULL, NULL, NULL, 'Croquera Mediana Negra', 'Cuaderno de tamaño mediano con tapa negra, ideal para llevar.', 'Se vende: 1 croquera A5 de 60 hojas bond 80 g/m2, tapa negra cosida.', '1 croquera x 60 hojas A5', 60, 'hojas', 22.00, 32, 'img/13-croquera-mediana-negra.jpg', 0),
(2, 3, 5, 1, 10, NULL, NULL, NULL, 'Croquera Premium 24 Hojas', 'Sketchbook premium con 24 hojas de papel de alta calidad.', 'Se vende: 1 sketchbook A4 de 24 hojas 250 g/m2, tapa dura. Soporta acuarela ligera y marcador.', '1 sketchbook x 24 hojas A4', 24, 'hojas', 36.00, 16, 'img/14-croquera-premium.jpg', 1),
(2, 2, 1, 1, 4, NULL, NULL, NULL, 'Croquera Sketch', 'Cuaderno de croquis con hojas de calidad para artistas y diseñadores.', 'Se vende: 1 croquera A5 de 100 hojas 90 g/m2 con espiral metálico.', '1 croquera x 100 hojas A5', 100, 'hojas', 26.00, 28, 'img/18-croquera-sketch.png', 0),
(3, 1, 1, 1, NULL, NULL, NULL, 4, 'Acuarelas Lavables Multi Colores', 'Set de acuarelas lavables con gama de colores vibrantes.', 'Se vende: 1 estuche con 12 pastillas de acuarela lavable + 1 pincel de regalo. No tóxico.', '12 pastillas + pincel', 12, 'pastillas', 38.00, 26, 'img/04-acuarelas-lavables.png', 0),
(3, 2, 1, 1, NULL, NULL, NULL, 1, 'Set 12 Pinturas Acrílicas - Colores Pasteles', '12 tubos de pintura acrílica en tonos pastel. Incluye 2 pinceles.', 'Se vende: 12 tubos x 12 ml en tonos pastel + 2 pinceles planos (N° 4 y 8). Cubritiva y de secado rápido.', '12 tubos x 12 ml + 2 pinceles', 12, 'tubos', 55.00, 20, 'img/05-pinturas-acrilicas-pasteles.png', 1),
(3, 2, 1, 1, NULL, NULL, NULL, 1, 'Set 12 Pinturas Acrílicas', 'Set completo de 12 pinturas acrílicas con colores surtidos.', 'Se vende: 12 tubos x 12 ml colores surtidos básicos + guía de mezcla de color impresa.', '12 tubos x 12 ml', 12, 'tubos', 48.00, 21, 'img/19-set-12-pinturas-acrilicas.jpg', 0),
(4, 2, 1, 1, NULL, NULL, 1, NULL, 'Set 12 Pinceles para Acuarela y Acrílicos', 'Pinceles de nylon profesional. Férula de doble rizo.', 'Se vende: 12 pinceles surtidos (redondos 0-8, planos 2-10, lengua de gato y abanico), mango madera.', '12 pinceles surtidos', 12, 'pinceles', 42.00, 19, 'img/03-set-pinceles-acuarela.jpg', 1),
(4, 1, 1, 1, NULL, NULL, 2, NULL, 'Set 12 Pinceles para Acrílicos', 'Pinceles de cerda sintética para acrílica, varias puntas.', 'Se vende: 12 pinceles sintéticos planos y redondos para acrílico y tempera.', '12 pinceles surtidos', 12, 'pinceles', 35.00, 23, 'img/15-set-12-pinceles.jpg', 0),
(4, 2, 4, 2, NULL, NULL, NULL, NULL, 'Set 18 Marcadores Doble Punta - Rainbow', 'Marcadores doble punta para detalle y cobertura amplia.', 'Se vende: 18 marcadores doble punta (fina 1 mm + biselada 6 mm), tinta al alcohol, colores arcoíris.', '18 marcadores doble punta', 18, 'marcadores', 68.00, 14, 'img/12-set-marcadores-doble-punta.jpg', 1),
(5, 2, 2, 2, NULL, NULL, NULL, NULL, 'Set 30 Lápices Colores', '30 lápices de colores con pigmentos de alto rendimiento.', 'Se vende: 30 lápices hexagonales mina 3.3 mm, mina resistente, fáciles de mezclar.', '30 lápices', 30, 'lápices', 50.00, 17, 'img/16-set-30-lapices-colores.png', 0),
(5, 3, 2, 2, NULL, NULL, NULL, NULL, 'Caja de 50 Lápices Deluxe', '50 lápices de colores en caja de metal. Suaves y mezclables.', 'Se vende: 50 lápices triangulares mina 4 mm en caja metálica + 2 lápices grafito de regalo.', '50 lápices + caja metal', 50, 'lápices', 95.00, 10, 'img/17-caja-50-lapices-deluxe.jpg', 1);

-- Productos nuevos v5 (lienzos, grafito, accesorios y mas clasificados)
INSERT INTO productos (categoria_id, calidad_id, marca_id, proveedor_id, gramaje_id, dureza_id, cerda_id, tipo_pintura_id, nombre, descripcion, detalle_venta, contenido, cantidad, unidad, precio, stock, imagen, destacado) VALUES
(1, 2, 1, 1, 11, NULL, NULL, NULL, 'Block Acuarela 300 g/m²', 'Papel de algodón para acuarela, no se ondula.', 'Se vende: 1 bloc A4 de 20 hojas, papel acuarela 300 g/m2 grano fino.', '1 bloc x 20 hojas A4', 20, 'hojas', 42.00, 18, '', 0),
(1, 1, 3, 1, 6, NULL, NULL, NULL, 'Papel Kraft en Rollo 10 m', 'Papel kraft multiuso para forrar, manualidades y embalaje.', 'Se vende: 1 rollo de papel kraft 120 g/m2 de 10 metros x 60 cm.', '1 rollo x 10 m', 1, 'rollo', 24.00, 20, '', 0),
(2, 3, 5, 1, 11, NULL, NULL, NULL, 'Cuaderno Acuarela A5 300 g', 'Cuaderno cosido para acuarela y tinta con lavados.', 'Se vende: 1 cuaderno A5 de 30 hojas de 300 g/m2, tapa dura.', '1 cuaderno x 30 hojas A5', 30, 'hojas', 38.00, 14, '', 0),
(2, 1, 3, 1, 6, NULL, NULL, NULL, 'Block Bosquejo 120 g A4', 'Block económico para practicar bocetos a diario.', 'Se vende: 1 block A4 de 50 hojas bond 120 g/m2.', '1 block x 50 hojas A4', 50, 'hojas', 16.00, 30, '', 0),
(3, 3, 2, 2, NULL, NULL, NULL, 2, 'Set 12 Óleos Profesionales', 'Óleos de alta pigmentación para lienzo y madera.', 'Se vende: 12 tubos x 12 ml de óleo profesional + guía de medios.', '12 tubos x 12 ml', 12, 'tubos', 85.00, 12, '', 1),
(3, 1, 1, 1, NULL, NULL, NULL, 3, 'Set 6 Témperas Escolares', 'Témperas lavables para colegio y manualidades.', 'Se vende: 6 potes x 30 ml de témpera lavable no tóxica.', '6 potes x 30 ml', 6, 'potes', 28.00, 22, '', 0),
(3, 2, 1, 1, NULL, NULL, NULL, 4, 'Acuarelas en Tubo x12', 'Acuarelas en tubo para mezclas intensas y lavados.', 'Se vende: 12 tubos x 12 ml de acuarela extrafina.', '12 tubos x 12 ml', 12, 'tubos', 52.00, 16, '', 0),
(4, 3, 1, 1, NULL, NULL, 3, NULL, 'Set 5 Pinceles Pelo Natural', 'Pinceles de marta para acuarela y detalle fino.', 'Se vende: 5 pinceles de pelo natural redondos N° 0 al 8.', '5 pinceles surtidos', 5, 'pinceles', 58.00, 10, '', 0),
(4, 2, 1, 1, NULL, NULL, 2, NULL, 'Set 8 Pinceles Sintéticos Planos', 'Pinceles planos sintéticos para acrílico y óleo.', 'Se vende: 8 pinceles planos sintéticos N° 2 al 12.', '8 pinceles planos', 8, 'pinceles', 32.00, 18, '', 0),
(7, 2, 2, 2, NULL, 10, NULL, NULL, 'Set 12 Lápices Grafito Surtidos', 'Set completo de grafitos de 2H a 8B.', 'Se vende: 12 lápices de grafito graduados 2H, H, HB, B, 2B, 4B, 6B y 8B.', '12 lápices 2H–8B', 12, 'lápices', 45.00, 15, '', 0),
(7, 1, 2, 2, NULL, 5, NULL, NULL, 'Lápices Grafito 2B x3', 'Lápices 2B para sombreado y boceto suave.', 'Se venden: 3 lápices de grafito dureza 2B.', '3 lápices 2B', 3, 'lápices', 12.00, 30, '', 0),
(7, 2, 5, 1, NULL, 9, NULL, NULL, 'Set 6 Carboncillos', 'Carboncillos para dibujo expresivo y retrato.', 'Se venden: 6 carboncillos de dureza media en caja.', '6 carboncillos', 6, 'carboncillos', 22.00, 18, '', 0),
(6, 2, 5, 1, 12, NULL, NULL, NULL, 'Bastidor Lienzo 30×40', 'Lienzo de algodón imprimado sobre bastidor de pino.', 'Se vende: 1 bastidor de 30×40 cm, lienzo 350 g/m2 listo para pintar.', '1 bastidor 30×40 cm', 1, 'bastidor', 35.00, 15, '', 1),
(6, 1, 5, 1, 10, NULL, NULL, NULL, 'Cartón Entelado A4 x3', 'Cartones entelados para practicar óleo y acrílico.', 'Se venden: 3 cartones entelados A4 de 250 g/m2.', '3 cartones A4', 3, 'cartones', 20.00, 24, '', 0),
(8, 2, 1, 1, NULL, NULL, NULL, NULL, 'Set 5 Espátulas', 'Espátulas de acero para mezclar y empastar.', 'Se venden: 5 espátulas de acero flexible con mango de madera.', '5 espátulas de acero', 5, 'espátulas', 30.00, 16, '', 0),
(8, 1, 5, 1, NULL, NULL, NULL, NULL, 'Paleta de Madera Ovalada', 'Paleta clásica para mezclar óleo y acrílico.', 'Se vende: 1 paleta ovalada de madera 30×40 cm con orificio.', '1 paleta 30×40 cm', 1, 'paleta', 25.00, 20, '', 0),
(8, 2, 5, 1, NULL, NULL, NULL, NULL, 'Caballete de Mesa 40 cm', 'Caballete de pino para formatos medianos.', 'Se vende: 1 caballete de mesa de pino de 40 cm, plegable.', '1 caballete de pino', 1, 'caballete', 48.00, 10, '', 0);

-- Imagenes 1:N (agrega mas fotos por producto sin alterar nada)
CREATE TABLE producto_imagenes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  url VARCHAR(255) NOT NULL,
  es_principal TINYINT(1) NOT NULL DEFAULT 0,
  orden INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_img_prod FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  INDEX idx_img_prod (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO producto_imagenes (producto_id, url, es_principal, orden)
SELECT id, imagen, 1, 0 FROM productos WHERE imagen <> '';

-- Kardex auditable
CREATE TABLE inventario_movimientos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  pedido_id INT NULL,
  tipo ENUM('entrada','salida','ajuste') NOT NULL,
  cantidad INT NOT NULL,
  stock_antes INT NOT NULL,
  stock_despues INT NOT NULL,
  motivo VARCHAR(255) DEFAULT '',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_mov_prod FOREIGN KEY (producto_id) REFERENCES productos(id),
  CONSTRAINT fk_mov_ped FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE SET NULL,
  INDEX idx_mov_prod (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cotizaciones del admin para clientes
CREATE TABLE cotizaciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NULL COMMENT 'admin que la creo',
  cliente_nombre VARCHAR(120) NOT NULL,
  cliente_telefono VARCHAR(30) DEFAULT '',
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  estado ENUM('pendiente','aprobada','rechazada') NOT NULL DEFAULT 'pendiente',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cot_usu FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL,
  INDEX idx_cot_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cotizacion_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cotizacion_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_citem_cot FOREIGN KEY (cotizacion_id) REFERENCES cotizaciones(id) ON DELETE CASCADE,
  CONSTRAINT fk_citem_prod FOREIGN KEY (producto_id) REFERENCES productos(id),
  INDEX idx_citem_cot (cotizacion_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO inventario_movimientos (producto_id, tipo, cantidad, stock_antes, stock_despues, motivo)
SELECT id, 'entrada', stock, 0, stock, 'Carga inicial del sistema' FROM productos;

-- Pedidos con desglose (subtotal/descuento) y relaciones opcionales
CREATE TABLE pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NULL,
  cliente_nombre VARCHAR(120) NOT NULL,
  cliente_telefono VARCHAR(30) NOT NULL,
  cliente_direccion VARCHAR(255) DEFAULT '',
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  estado ENUM('pendiente','confirmado','entregado','anulado') NOT NULL DEFAULT 'pendiente',
  canal VARCHAR(20) NOT NULL DEFAULT 'web',
  metodo_pago VARCHAR(30) NOT NULL DEFAULT 'whatsapp',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ped_usu FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedido_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_item_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
  CONSTRAINT fk_item_prod FOREIGN KEY (producto_id) REFERENCES productos(id),
  INDEX idx_pedido (pedido_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedido_historial (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id INT NOT NULL,
  estado_anterior VARCHAR(20) DEFAULT '',
  estado_nuevo VARCHAR(20) NOT NULL,
  comentario VARCHAR(255) DEFAULT '',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hist_ped FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
  INDEX idx_hist_ped (pedido_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Resenas
CREATE TABLE resenas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  cliente_nombre VARCHAR(120) NOT NULL,
  puntaje TINYINT NOT NULL CHECK (puntaje BETWEEN 1 AND 5),
  comentario VARCHAR(500) DEFAULT '',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_res_prod FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
  INDEX idx_res_prod (producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO resenas (producto_id, cliente_nombre, puntaje, comentario) VALUES
(5, 'María Q.', 5, 'Los pasteles pintan hermoso, llegaron bien embalados.'),
(20, 'Diego A.', 5, 'La caja metálica es un golazo para el taller.'),
(14, 'Lucía F.', 4, 'Buen papel, aguanta la acuarela ligera.'),
(1, 'Carlos M.', 5, 'Ideal para mis cuadros en acrílico.');

-- Log del chatbot (analitica: que palabra se pregunta mas)
CREATE TABLE chatbot_consultas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  palabra_clave VARCHAR(60) NOT NULL DEFAULT 'sin-coincidencia',
  mensaje VARCHAR(200) NOT NULL,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_chat_clave (palabra_clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Config clave-valor (cambia datos sin tocar codigo)
CREATE TABLE config_tienda (
  clave VARCHAR(60) PRIMARY KEY,
  valor VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO config_tienda (clave, valor) VALUES
('nombre_tienda', 'Tía Óleo 4'),
('whatsapp', '51993706366'),
('moneda_base', 'PEN'),
('direccion', 'Sabandia 418 - Characato - Arequipa');

SET FOREIGN_KEY_CHECKS = 1;
