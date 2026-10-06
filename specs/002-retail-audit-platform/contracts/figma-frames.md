# Contract: Figma Frames and Variables

**Source**: Figma file `9s5b56r9zs1s0Ty2UgvL0W` ("Map"), page `0:1` "Main", section `7:1130` "MAP".

Frame link pattern: `https://www.figma.com/design/9s5b56r9zs1s0Ty2UgvL0W/Map?node-id=<id with - instead of :>`

The file has no component library (5,600 frames, 1,705 text nodes, 1 symbol). Shared
components are derived from repeated frames, not from Figma components.

## Admin Web: section `246:22821` (1440 wide)

| Node | Frame | Size | Notes |
|------|-------|------|-------|
| `3:2` | Map | 1440×900 | Shop popup (left card with visit history) + filters panel open |
| `21:2` | Map | 1440×900 | Default map, nothing selected |
| `3:407` | Shops | 1440×900 | List with row action menu (Edit Shop, …) open |
| `53:151` | Shops | 1440×900 | Rows selected, bulk actions (Assign salesman, View on Map, Delete) |
| `47:7387` | Shops \| Details | 1440×1102 | Details page |
| `162:20071` | Shops \| Details | 1440×900 | Edit dialog |
| `30:574` | Products | 1440×900 | |
| `495:2311` | **Add Product** | 1440×900 | |
| `31:2307` | Salesman | 1440×900 | |
| `495:3932` | **Add Salesman** | 1440×900 | |
| `122:7981` | Salesman details | 1440×1578 | |
| `53:1375` | Pictures | 1440×900 | Photo grid |
| `138:11987` | Pictures | 1440×900 | Detail panel |
| `39:603`, `39:606`, `39:608`, `39:610`, `49:9563` | title | 1440×221 | Page-header variants (reference) |

## Agent Mobile light: section `111:6815` (390 wide)

| Node | Frame | Size |
|------|-------|------|
| `83:16786` | home | 390×844 |
| `83:16884` | shops | 390×890 |
| `83:17057` | shop details | 390×961 |
| `83:17207` | audit | 390×882 — locating, no photo, Finish disabled |
| `83:17285` | audit finish | 390×882 — photos + comment, Finish enabled |
| `252:26487` | add shop | 390×898 — empty, Save disabled |
| `252:26607` | add shop | 390×898 — filled with storefront photo |
| `83:17636` | map | 390×844 — nothing selected |
| `83:17775` | map | 390×844 — shop sheet with Start audit |
| `83:17954` | gallery | 390×844 — grid by date |
| `83:18045` | gallery | 390×844 — photo detail |

## Agent Mobile dark: section `111:6814` (390 wide)

| Node | Frame | Size |
|------|-------|------|
| `101:1880` | home | 390×844 |
| `101:1985` | shops | 390×890 |
| `106:4035` | shops | 390×1017 — **shop details** (dark) |
| `106:4374` | audit | 390×882 — locating, no photo |
| `106:6229` | audit | 390×882 — finish state |
| `101:2472` | add shop | 390×964 — empty |
| `106:5970` | add shop | 390×964 — filled |
| `106:5485` | map | 390×844 — nothing selected |
| `106:5609` | map | 390×844 — shop sheet |
| `106:6558` | gallery | 390×844 — grid by date |
| `106:6710` | gallery | 390×844 — photo detail |

## Admin mobile light: section `248:23959` (390 wide)

| Node | Frame | Size |
|------|-------|------|
| `246:23129` | home | 390×844 |
| `246:23300` | shops | 390×1051 |
| `248:23963` | map | 390×844 — nothing selected |
| `248:24102` | map | 390×844 — shop sheet with Подробнее |
| `248:24311` | gallery | 390×844 — grid by date |
| `248:24402` | gallery | 390×884 — photo detail |
| `248:24538` | Shop details | 390×1535 |
| `252:25423` | add shop | 390×1004 — empty (gallery or camera) |
| `252:25542` | add/edit shop | 390×1004 — filled |
| `265:27616` | Агенты | 390×1001 |
| `273:153` | Агенты details | 390×2200 |

## Color variables (from `get_variable_defs` on `7:1130`)

| Token | Light | Dark |
|-------|-------|------|
| Accent | `#493EE5` | `#493EE5` |
| Main bg | `#FBF8FF` | `#0B0F19` |
| Secondary bg | `#F3F2FF` | `#121A2C` |
| Surface (Pure white / White) | `#FFFFFF` | `#FCFDFF` (text) |
| Text: Black / White | `#0F172A` | `#FCFDFF` |
| Text: Default black / Off white | `#62617B` | `#94A3B8` |
| Border | `#E2E8F0` | White 5% |
| Dark accent | `#EDEDFB` | `#1E2549` |
| Light accent | — | `#A5B4FC` |
| Accent 6% | `#493EE5` @ 6% | — |
| Grey 3 | `#F1F5F9` | — |
| Success | `#00685A` | `#25D998` |
| Success 10% | `#00685A` @ 10% | — |
| Light green | `#03D66C` | — |
| Error | `#CE3437` | `#FDA4AF` |
| Error bg | `#F9EDEC` | `#450A0A` |
| Error stroke | — | `#9F1239` |
| White 5% / White 20% | `#FFFFFF` @ 5% / 20% | same |
| Text main (web) | `#181717` | — |

Values are read per frame with `get_design_context`. Where a node uses a raw value instead of a
variable, that raw value is used for that node (Constitution I). Frame states above were
verified from each frame's text layers.
