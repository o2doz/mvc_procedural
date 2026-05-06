-- Script de création de la base JNR Puff
-- À exécuter dans une base nommée `jnr_puff` (utf8mb4).

CREATE TABLE categories (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name        VARCHAR(120) NOT NULL,
    flavor      VARCHAR(80)  NOT NULL,
    nicotine_mg DECIMAL(4,2) NOT NULL DEFAULT 0,
    puffs       INT          NOT NULL DEFAULT 0,
    price       DECIMAL(6,2) NOT NULL,
    stock       INT          NOT NULL DEFAULT 0,
    image_url   VARCHAR(255) DEFAULT NULL,
    description TEXT,
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categories (name) VALUES
    ('Puff jetable'),
    ('Pod rechargeable'),
    ('E-liquide');

INSERT INTO products (category_id, name, flavor, nicotine_mg, puffs, price, stock, description) VALUES
    (1, 'JNR Bar 600',     'Fraise glacée',     20.00,  600, 7.90,  50, 'Puff jetable 600 bouffées, saveur fraise glacée.'),
    (1, 'JNR Bar 600',     'Mangue passion',    20.00,  600, 7.90,  35, 'Puff jetable 600 bouffées, saveur mangue passion.'),
    (1, 'JNR Max 2000',    'Pastèque ice',      20.00, 2000, 12.50, 20, 'Puff longue durée 2000 bouffées.'),
    (1, 'JNR Max 2000',    'Cola cherry',       20.00, 2000, 12.50, 18, 'Puff longue durée 2000 bouffées, saveur cola cherry.'),
    (2, 'JNR Pod Mini',    'Sans saveur',        0.00,    0, 19.90, 12, 'Pod rechargeable compact, batterie 800 mAh.'),
    (2, 'JNR Pod Pro',     'Sans saveur',        0.00,    0, 29.90,  8, 'Pod rechargeable haut de gamme, batterie 1500 mAh.'),
    (3, 'E-liquide 10ml',  'Menthe polaire',    12.00,    0,  4.90, 60, 'Flacon e-liquide 10 ml, base 50/50.'),
    (3, 'E-liquide 10ml',  'Vanille caramel',    6.00,    0,  4.90, 45, 'Flacon e-liquide 10 ml, base 50/50.');
