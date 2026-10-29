# Comparateur de Crédits Immobilier

Application web locale pour comparer les crédits immobiliers avec une architecture minimaliste.


![VueJS](https://img.shields.io/badge/VueJS-42b883?logo=vuedotjs&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-7952B3?logo=bootstrap&logoColor=white)
![: Wasm](https://img.shields.io/badge/-Wasm-02569B?logo=webassembly&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-000000?logo=rust&logoColor=white)


## Architecture

### Backend (Rust + WASM)
- **Logique métier** en Rust compilée en WebAssembly
- Utilise `wasm-bindgen` pour l'interopérabilité JavaScript
- Calculs précis des mensualités, intérêts et assurance
- Sérialisation JSON avec `serde`

### Frontend (Vue.js + Bootstrap)
- **Vue.js 3** (via CDN) pour la réactivité et la manipulation du DOM
- **Bootstrap 5** (Bootswatch Flatly theme) pour le design
- **Bootstrap Icons** pour les icônes
- Appel direct aux fonctions WASM depuis JavaScript

## Structure du Projet

```
.
├── src/
│   └── lib.rs              # Logique métier Rust
├── pkg/                    # WASM compilé (généré par wasm-pack)
├── index.html              # Application frontend
├── Cargo.toml              # Dépendances Rust
└── README.md               # Documentation
```

## Fonctionnalités

- Ajout de plusieurs offres de crédit immobilier
- Calcul automatique des mensualités
- Comparaison des coûts totaux
- Identification de la meilleure offre (mensualité / coût total)
- Support de l'assurance emprunteur
- Interface responsive et intuitive

## Dépendances Frontend (CDN)

- Bootstrap 5.3.8 (Bootswatch Flatly)
- Bootstrap Icons 1.13.1
- Vue.js 3.5.44

## Dépendances Rust

- wasm-bindgen 0.2
- serde 1.0
- serde_json 1.0
- serde-wasm-bindgen 0.6
- web-sys 0.3
- wasm-bindgen-futures 0.4

## Installation et Exécution

### Prérequis

- Rust (avec cargo)
- wasm-pack: `curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh`
- Python 3 (pour le serveur HTTP local)

### Compiler le WASM

```bash
wasm-pack build --target web
```

### Lancer le serveur de développement

```bash
python3 -m http.server 8080
```

### Accéder à l'application

Ouvrir http://localhost:8080 dans votre navigateur

## Recompiler après modifications

Après avoir modifié le code Rust:

```bash
wasm-pack build --target web
```

Puis rafraîchir la page dans le navigateur.

## Formules de Calcul

### Mensualité (amortissement constant)
```
M = P * r * (1 + r)^n / ((1 + r)^n - 1)
```
Où:
- M = mensualité
- P = principal (montant du prêt)
- r = taux mensuel (taux annuel / 12 / 100)
- n = nombre de mois (années * 12)

### Assurance
```
Assurance mensuelle = P * taux_assurance / 12 / 100
Assurance totale = Assurance mensuelle * n
```

### Taux effectif
```
Taux effectif = ((Coût total / Principal) - 1) / Années * 100
```

## Architecture Technique

Le module WASM expose deux fonctions principales:

1. `calculate_single_mortgage_json(json: &str) -> Result<String, JsValue>`
   - Calcule une seule offre de crédit
   - Prend un JSON en entrée, retourne un JSON en sortie

2. `compare_mortgages_json(json: &str) -> Result<String, JsValue>`
   - Compare plusieurs offres
   - Identifie la meilleure mensualité et le meilleur coût total

L'intégration avec Vue.js se fait via import direct du module WASM:

```javascript
import init from './pkg/mortgage_calculator.js';
const wasmModule = await init();
const result = wasmModule.compare_mortgages_json(requestBody);
```

## Licence

Projet d'exemple pour démonstration Rust + WASM + Vue.js
