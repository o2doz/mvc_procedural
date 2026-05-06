# TP — Mini boutique PixelParts en PHP procédural (MVC)

## Contexte

Vous allez développer un mini-site e-commerce pour **PixelParts**, un revendeur en
ligne de **composants PC**, **consoles de jeux** et **périphériques gaming**.
L'objectif n'est pas de faire un site complet, mais de **mettre en pratique le
pattern MVC** (Modèle - Vue - Contrôleur) en **PHP procédural** (sans aucune
classe), avec une base de données **MySQL** accédée via l'extension **`mysqli`**.

À la fin du TP vous disposerez :

- d'un catalogue de produits lu en base,
- d'une fiche détaillée par produit,
- d'un panier persisté en session,

le tout organisé selon une séparation stricte modèles / vues / contrôleurs.

---

> **Important** : tout le code PHP que vous écrirez doit être **procédural**.
> Aucune définition de `class`, ni `new`, ni `->` sur des objets que vous créeriez.
> Seuls les objets retournés par `mysqli` sont tolérés (vous ne créez pas de classes,
> vous utilisez les fonctions `mysqli_*`).

---

## Arborescence cible

À recréer à l'identique avant de commencer :

```
pixel_parts/
├── public/
│   ├── index.php          # Front Controller (point d'entrée unique)
│   └── assets/
│       └── style.css      # Feuille de style fournie
├── config/
│   └── database.php       # Constantes de connexion
├── controllers/
│   ├── home_controller.php
│   ├── product_controller.php
│   └── cart_controller.php
├── models/
│   └── product_model.php
├── views/
│   ├── layouts/
│   │   ├── header.php
│   │   └── footer.php
│   ├── home/
│   │   └── index.php
│   ├── products/
│   │   ├── index.php
│   │   └── show.php
│   ├── cart/
│   │   └── index.php
│   └── errors/
│       └── 404.php
├── helpers/
│   └── render.php         # Fonction render()
└── sql/
    └── schema.sql         # Script de création + jeu de données
```

> **À avoir à la fin de cette section** : tous les dossiers et fichiers vides créés,
> respectant exactement cette arborescence.

---

## Partie 1 — Base de données

Vous travaillerez sur deux tables : `categories` et `products`.

1. Créer une base nommée `pixel_parts` (encodage `utf8mb4`).
2. Recopier le script suivant dans `sql/schema.sql` puis l'exécuter dans la base.

```sql
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
```

> **À avoir à la fin de cette partie** : la base `pixel_parts` contient les deux
> tables avec les huit produits seed et trois catégories. Vérifiez avec
> `SELECT COUNT(*) FROM products;` (résultat attendu : `8`).

---

## Partie 2 — Connexion à la base

Le fichier `config/database.php` doit centraliser les paramètres de connexion et
exposer **une fonction** `db_connect()` qui retourne la ressource `mysqli`.

1. Définir les constantes `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME`.
2. Écrire la fonction `db_connect()` :

```php
<?php
const DB_HOST = 'localhost';
const DB_USER = 'root';
const DB_PASS = '';
const DB_NAME = 'pixel_parts';

function db_connect(): mysqli
{
    static $conn = null; // mémorise la connexion entre les appels

    if ($conn === null) {
        // TODO : ouvrir la connexion avec mysqli_connect() en utilisant les constantes ci-dessus.
        // TODO : si la connexion échoue, arrêter le script avec un message d'erreur (voir mysqli_connect_error()).
        // TODO : forcer l'encodage en utf8mb4 sur la connexion.
    }

    return $conn;
}
```

> **Indices** : `mysqli_connect()`, `mysqli_connect_error()`, `mysqli_set_charset()`.

3. Tester la connexion avec un fichier jetable `test_db.php` à la racine :

```php
<?php
require __DIR__ . '/config/database.php';
$conn = db_connect();
$res  = mysqli_query($conn, 'SELECT COUNT(*) AS n FROM products');
$row  = mysqli_fetch_assoc($res);
echo 'Produits en base : ' . $row['n'];
```

Lancez-le via `php test_db.php`. Une fois validé, **supprimez** ce fichier de test.

> **À avoir à la fin de cette partie** : la fonction `db_connect()` opérationnelle
> et le test affichant `Produits en base : 8`.

---

## Partie 3 — Front Controller et routeur

Toutes les requêtes HTTP doivent passer par `public/index.php`. Ce fichier va :

- démarrer la session,
- charger les dépendances,
- lire la route demandée,
- déléguer à la **fonction de contrôleur** correspondante.

1. Dans `public/index.php`, démarrez la session puis chargez la configuration et
   les helpers :

```php
<?php
session_start();

require __DIR__ . '/../config/database.php';
require __DIR__ . '/../helpers/render.php';

require __DIR__ . '/../models/product_model.php';

require __DIR__ . '/../controllers/home_controller.php';
require __DIR__ . '/../controllers/product_controller.php';
require __DIR__ . '/../controllers/cart_controller.php';
```

2. Récupérez la route et l'action depuis `$_GET` (avec valeurs par défaut) :

```php
$route  = $_GET['route']  ?? 'home';
$action = $_GET['action'] ?? 'index';
```

3. Implémentez le dispatch via un `switch` qui appelle la bonne fonction de
   contrôleur. Une route inconnue doit afficher la vue `errors/404.php` avec un
   code HTTP `404`.

```php
switch ($route) {
    case 'home':
        // TODO : appeler la fonction de contrôleur de la page d'accueil.
        break;

    case 'products':
        // TODO : si l'action vaut 'show', appeler product_show().
        // TODO : sinon appeler product_index() (la liste).
        break;

    case 'cart':
        // À compléter en partie 7
        break;

    default:
        // TODO : envoyer un code HTTP 404 puis rendre la vue errors/404.
        break;
}
```

> **À avoir à la fin de cette partie** : `index.php` complet, prêt à dispatcher.
> Les contrôleurs n'existent pas encore, donc la page va planter — c'est normal,
> on les écrit juste après.

---

## Partie 4 — Helper de rendu et layout

Pour respecter la séparation MVC, **aucun contrôleur ne doit faire d'`echo`** ni
contenir de HTML. C'est le rôle des vues, appelées via une fonction utilitaire.

1. Créez `helpers/render.php` :

```php
<?php
function render(string $view, array $data = []): void
{
    // TODO : transformer les clés du tableau $data en variables locales (extract()).

    // TODO : construire le chemin complet vers le fichier de vue à partir de $view
    //        (ex. : 'home/index' -> __DIR__ . '/../views/home/index.php').

    // TODO : si le fichier de vue n'existe pas, retourner une erreur 500 propre.

    // TODO : inclure le header du layout, puis la vue, puis le footer du layout.
}
```

> **Indices** : `extract()`, `is_file()`, `require`, `http_response_code()`.

2. Écrivez le layout dans `views/layouts/header.php` :

```php
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <title>PixelParts</title>
    <link rel="stylesheet" href="/assets/style.css">
</head>
<body>
<header class="topbar">
    <a class="logo" href="/?route=home">PixelParts</a>
    <nav>
        <a href="/?route=home">Accueil</a>
        <a href="/?route=products">Catalogue</a>
        <a href="/?route=cart">
            Panier (<?= array_sum($_SESSION['cart'] ?? []) ?>)
        </a>
    </nav>
</header>
<main class="container">
```

3. Et `views/layouts/footer.php` :

```php
</main>
<footer class="footer">
    <p>&copy; <?= date('Y') ?> PixelParts — projet pédagogique</p>
</footer>
</body>
</html>
```

4. Vue 404 minimale dans `views/errors/404.php` :

```php
<h1>Page introuvable</h1>
<p>La page demandée n'existe pas. <a href="/?route=home">Retour à l'accueil</a>.</p>
```

5. Feuille de style fournie à coller dans `public/assets/style.css` :

```css
* { box-sizing: border-box; }
body { font-family: system-ui, sans-serif; margin: 0; background: #f7f7f9; color: #222; }
.topbar { display: flex; align-items: center; justify-content: space-between; padding: 1rem 2rem; background: #1a1a2e; color: #fff; }
.topbar a { color: #fff; text-decoration: none; margin-left: 1rem; }
.logo { font-weight: 700; font-size: 1.25rem; }
.container { max-width: 1100px; margin: 2rem auto; padding: 0 1rem; }
.footer { text-align: center; padding: 2rem; color: #888; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 1rem; }
.card { background: #fff; border-radius: 8px; padding: 1rem; box-shadow: 0 2px 6px rgba(0,0,0,.06); }
.card h3 { margin: .25rem 0; }
.price { font-weight: 700; color: #c0392b; }
.btn { display: inline-block; padding: .5rem 1rem; background: #1a1a2e; color: #fff; text-decoration: none; border: 0; border-radius: 4px; cursor: pointer; }
.btn:hover { background: #16213e; }
table { width: 100%; border-collapse: collapse; background: #fff; }
th, td { padding: .75rem; border-bottom: 1px solid #eee; text-align: left; }
```

> **À avoir à la fin de cette partie** : la fonction `render()` opérationnelle,
> un layout commun (header + footer), une page 404, et un fichier CSS chargé.

---

## Partie 5 — Page d'accueil

Premier contrôleur trivial pour valider la chaîne complète Front Controller →
Contrôleur → Vue.

1. Dans `controllers/home_controller.php` :

```php
<?php
function home_index(): void
{
    // TODO : appeler render() sur la vue 'home/index' en passant un titre
    //        (ex. 'Bienvenue sur PixelParts') dans le tableau de données.
}
```

2. Dans `views/home/index.php` :

```php
<h1><?= htmlspecialchars($title) ?></h1>
<p>Découvrez notre sélection de composants PC, consoles et périphériques gaming.</p>
<p><a class="btn" href="/?route=products">Voir le catalogue</a></p>
```

3. Lancez le serveur (`php -S localhost:8000 -t public/`) et ouvrez
   `http://localhost:8000/?route=home`.

> **À avoir à la fin de cette partie** : la page d'accueil s'affiche avec le
> layout, la nav et le bouton vers le catalogue. Le compteur du panier affiche `0`.

---

## Partie 6 — Catalogue produits (liste + détail)

Cette partie met en place le **modèle** (accès BDD) et deux actions de
contrôleur : la liste et la fiche produit.

### 6.1 — Modèle

Dans `models/product_model.php`, écrivez **deux fonctions**.

`get_all_products()` retourne un tableau associatif de tous les produits avec le
nom de la catégorie joint :

```php
<?php
function get_all_products(): array
{
    $conn = db_connect();

    // TODO : écrire la requête SQL qui sélectionne tous les produits joints à leur catégorie.
    //        Le résultat doit contenir toutes les colonnes de products + une colonne category_name.
    //        Trier par marque puis par nom.

    // TODO : exécuter la requête avec mysqli_query().

    // TODO : retourner toutes les lignes en tableau associatif (mysqli_fetch_all + MYSQLI_ASSOC).
}
```

`get_product_by_id($id)` doit utiliser une **requête préparée** (l'`id` provient
de l'utilisateur, c'est non négociable) :

```php
function get_product_by_id(int $id): ?array
{
    $conn = db_connect();

    // TODO : préparer une requête SELECT qui récupère le produit dont l'id = ?
    //        (jointure avec categories pour récupérer category_name).

    // TODO : lier le paramètre $id (type entier) à la requête préparée.

    // TODO : exécuter la requête et récupérer le résultat.

    // TODO : récupérer la ligne (mysqli_fetch_assoc) ; retourner null si aucun résultat.
}
```

> **Indices** : `mysqli_prepare()`, `mysqli_stmt_bind_param()`,
> `mysqli_stmt_execute()`, `mysqli_stmt_get_result()`, `mysqli_fetch_assoc()`.

### 6.2 — Contrôleur

Dans `controllers/product_controller.php` :

```php
<?php
function product_index(): void
{
    // TODO : récupérer tous les produits via le modèle.
    // TODO : appeler render() sur la vue 'products/index' en passant les produits.
}

function product_show(): void
{
    // TODO : récupérer et valider l'id depuis $_GET (filter_input + FILTER_VALIDATE_INT).
    // TODO : si l'id est invalide, renvoyer une 404.

    // TODO : appeler le modèle pour récupérer le produit.
    // TODO : si le produit n'existe pas, renvoyer une 404.

    // TODO : appeler render() sur la vue 'products/show' en passant le produit.
}
```

### 6.3 — Vues

`views/products/index.php` — la grille de cartes :

```php
<h1>Catalogue</h1>

<?php if (empty($products)): ?>
    <p>Aucun produit disponible.</p>
<?php else: ?>
    <div class="grid">
        <?php foreach ($products as $p): ?>
            <article class="card">
                <small><?= htmlspecialchars($p['category_name']) ?></small>
                <h3><?= htmlspecialchars($p['name']) ?></h3>
                <p>
                    <strong><?= htmlspecialchars($p['brand']) ?></strong>
                    — <?= htmlspecialchars($p['model']) ?>
                </p>
                <?php if ((int) $p['warranty_months'] > 0): ?>
                    <p>Garantie : <?= (int) $p['warranty_months'] ?> mois</p>
                <?php endif; ?>
                <p class="price"><?= number_format((float) $p['price'], 2) ?> €</p>
                <a class="btn" href="/?route=products&amp;action=show&amp;id=<?= (int) $p['id'] ?>">
                    Voir la fiche
                </a>
            </article>
        <?php endforeach; ?>
    </div>
<?php endif; ?>
```

`views/products/show.php` — la fiche détaillée avec le formulaire d'ajout au
panier :

```php
<p><a href="/?route=products">&larr; Retour au catalogue</a></p>

<h1>
    <?= htmlspecialchars($product['brand']) ?>
    <?= htmlspecialchars($product['model']) ?>
</h1>

<p><strong>Catégorie :</strong> <?= htmlspecialchars($product['category_name']) ?></p>
<p><strong>Type :</strong> <?= htmlspecialchars($product['name']) ?></p>
<p><strong>Garantie :</strong> <?= (int) $product['warranty_months'] ?> mois</p>
<p class="price"><?= number_format((float) $product['price'], 2) ?> €</p>
<p><?= nl2br(htmlspecialchars($product['description'] ?? '')) ?></p>
<p>Stock disponible : <?= (int) $product['stock'] ?></p>

<form method="post" action="/?route=cart&amp;action=add">
    <input type="hidden" name="product_id" value="<?= (int) $product['id'] ?>">
    <label>
        Quantité :
        <input type="number" name="quantity" min="1" max="<?= (int) $product['stock'] ?>" value="1">
    </label>
    <button type="submit" class="btn">Ajouter au panier</button>
</form>
```

> **À avoir à la fin de cette partie** : `?route=products` affiche les 8
> produits, `?route=products&action=show&id=1` affiche la fiche, un id invalide
> renvoie sur la 404. Le formulaire d'ajout est visible (mais non fonctionnel).

---

## Partie 7 — Panier en session

Le panier est un **tableau associatif** stocké dans `$_SESSION['cart']`, de la
forme `[product_id => quantity]`. Aucune nouvelle table n'est créée.

### 7.1 — Contrôleur panier

Dans `controllers/cart_controller.php`, trois fonctions :

```php
<?php
function cart_index(): void
{
    $cart  = $_SESSION['cart'] ?? [];
    $items = [];
    $total = 0.0;

    // TODO : pour chaque (productId => quantity) dans $cart :
    //   - récupérer le produit via get_product_by_id() ;
    //   - s'il n'existe plus, l'ignorer ;
    //   - calculer le sous-total (prix * quantité) ;
    //   - empiler dans $items un tableau ['product' => ..., 'quantity' => ..., 'subtotal' => ...] ;
    //   - cumuler dans $total.

    render('cart/index', [
        'items' => $items,
        'total' => $total,
    ]);
}

function cart_add(): void
{
    // TODO : refuser tout ce qui n'est pas une requête POST (rediriger vers le catalogue).

    // TODO : récupérer et valider product_id et quantity depuis $_POST
    //        (filter_input + FILTER_VALIDATE_INT, quantité minimale = 1).
    // TODO : si invalide, rediriger vers le catalogue.

    // TODO : vérifier que le produit existe en base (get_product_by_id).
    //        Sinon, rediriger vers le catalogue.

    // TODO : initialiser $_SESSION['cart'] si nécessaire.

    // TODO : ajouter la quantité à celle déjà présente pour ce produit,
    //        sans jamais dépasser le stock du produit.

    // TODO : rediriger l'utilisateur vers la page panier.
}

function cart_remove(): void
{
    // TODO : récupérer et valider l'id en GET.
    // TODO : si l'id est valide et présent dans $_SESSION['cart'], le retirer.
    // TODO : rediriger vers la page panier.
}
```

> **Indices** : `header('Location: ...'); exit;`, `min()`, `isset()`, `unset()`.

### 7.2 — Routage

Complétez le `case 'cart'` dans `public/index.php` :

```php
case 'cart':
    // TODO : selon la valeur de $action, appeler :
    //   - cart_add()    si action == 'add'
    //   - cart_remove() si action == 'remove'
    //   - cart_index()  par défaut
    break;
```

### 7.3 — Vue panier

`views/cart/index.php` :

```php
<h1>Mon panier</h1>

<?php if (empty($items)): ?>
    <p>Votre panier est vide.</p>
    <p><a class="btn" href="/?route=products">Voir le catalogue</a></p>
<?php else: ?>
    <table>
        <thead>
            <tr>
                <th>Produit</th>
                <th>Prix unitaire</th>
                <th>Quantité</th>
                <th>Sous-total</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($items as $item): ?>
                <tr>
                    <td>
                        <?= htmlspecialchars($item['product']['brand']) ?>
                        <?= htmlspecialchars($item['product']['model']) ?>
                    </td>
                    <td><?= number_format((float) $item['product']['price'], 2) ?> €</td>
                    <td><?= (int) $item['quantity'] ?></td>
                    <td><?= number_format($item['subtotal'], 2) ?> €</td>
                    <td>
                        <a href="/?route=cart&amp;action=remove&amp;id=<?= (int) $item['product']['id'] ?>">
                            Retirer
                        </a>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
        <tfoot>
            <tr>
                <th colspan="3">Total</th>
                <th colspan="2"><?= number_format($total, 2) ?> €</th>
            </tr>
        </tfoot>
    </table>
<?php endif; ?>
```

> **À avoir à la fin de cette partie** : depuis la fiche produit, ajouter un
> article met à jour le panier ; `?route=cart` affiche le récapitulatif avec
> total ; le compteur dans la nav reflète la somme des quantités ; le lien
> "Retirer" supprime la ligne.

---

## Partie 8 — Vérifications finales

Avant de rendre le TP, contrôlez **tous** les points suivants :

1. Aucune classe (`class`, `new`) dans votre code.
2. Aucun `echo` ni HTML dans les fichiers de `controllers/` et `models/`.
3. Aucune requête SQL dans les fichiers de `controllers/` et `views/`.
4. Toute donnée provenant de `$_GET` ou `$_POST` est validée
   (`filter_input`, `FILTER_VALIDATE_INT`).
5. Toute donnée affichée provenant de la BDD ou de l'utilisateur passe par
   `htmlspecialchars()`.
6. La fonction `get_product_by_id()` utilise bien une **requête préparée**.
7. Le serveur lancé via `php -S localhost:8000 -t public/` permet de naviguer
   sur l'accueil, le catalogue, une fiche produit et le panier sans erreur.
8. Une URL inconnue renvoie une page 404 propre.

> **À avoir à la fin de cette partie** : un projet conforme aux 8 points
> ci-dessus, livrable en l'état.

---

## Pour aller plus loin

Si vous avez terminé en avance :

- Ajouter une route `?route=products&category=2` qui filtre par catégorie
  (composants, consoles ou périphériques).
- Ajouter un tri par prix (asc/desc) via un paramètre `?sort=price_asc`.
- Permettre la modification de la quantité directement depuis la vue panier.
- Ajouter un message flash (via session) après ajout au panier.
- Limiter dynamiquement la quantité dans le formulaire d'ajout au stock restant
  **moins** ce qui est déjà dans le panier.
