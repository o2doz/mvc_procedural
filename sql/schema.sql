-- Script de création de la base PixelParts
-- À exécuter dans une base nommée `pixel_parts` (utf8mb4).

CREATE TABLE categories (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    category_id     INT NOT NULL,
    name            VARCHAR(120) NOT NULL,
    brand           VARCHAR(80)  NOT NULL,
    model           VARCHAR(120) NOT NULL,
    warranty_months INT          NOT NULL DEFAULT 24,
    price           DECIMAL(8,2) NOT NULL,
    stock           INT          NOT NULL DEFAULT 0,
    image_url       VARCHAR(255) DEFAULT NULL,
    description     TEXT,
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO categories (name) VALUES
    ('Composant PC'),
    ('Console'),
    ('Périphérique');

INSERT INTO products (category_id, name, brand, model, warranty_months, price, stock, description) VALUES
    (1, 'Carte graphique',    'NVIDIA',    'GeForce RTX 4070',         36, 599.00, 15, 'GPU milieu de gamme, 12 Go GDDR6X, idéal 1440p.'),
    (1, 'Processeur',          'AMD',       'Ryzen 7 7800X3D',          36, 449.00, 22, 'CPU 8 cœurs / 16 threads, cache 3D V-Cache, socket AM5.'),
    (1, 'SSD NVMe',            'Samsung',   '990 Pro 2 To',             60, 199.00, 40, 'SSD M.2 PCIe Gen4, lecture jusqu''à 7450 Mo/s.'),
    (1, 'Mémoire DDR5',        'Corsair',   'Vengeance 32 Go 6000 MHz', 120,129.00, 30, 'Kit 2x16 Go DDR5-6000 CL30, profil EXPO.'),
    (2, 'Console de salon',    'Sony',      'PlayStation 5 Slim',       24, 549.00, 10, 'Console nouvelle génération, SSD 1 To, manette DualSense.'),
    (2, 'Console portable',    'Nintendo',  'Switch OLED',              12, 349.00, 18, 'Console hybride, écran OLED 7", 64 Go de stockage.'),
    (3, 'Clavier mécanique',   'Logitech',  'G Pro X TKL',              24, 219.00, 25, 'Clavier sans fil tenkeyless, switches GX, rétroéclairage RGB.'),
    (3, 'Souris gamer',        'Razer',     'DeathAdder V3',            24,  89.00, 50, 'Souris ergonomique, capteur Focus Pro 30K, 59 g.');
