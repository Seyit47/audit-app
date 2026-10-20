import { defineCopy } from '@/lib/i18n'

export const districtsCopy = defineCopy({
  en: {
    title: 'Districts',
    description: 'Where your shops are, and how today\'s visits are going in each district.',
    search: 'Search districts…', add: 'Add district', addTitle: 'New district', renameTitle: 'Rename district',
    name: 'District name', namePlaceholder: 'e.g. Köpetdag',
    shops: ['shop', 'shops'], agents: ['salesman', 'salesmen'],
    visitedToday: 'Visited today', overdue: '{n} overdue', noShops: 'No shops yet', openShops: 'Open shops',
    rename: 'Rename', delete: 'Delete', cancel: 'Cancel', save: 'Save', create: 'Add',
    deleteTitle: 'Delete district?', deleteBody: '“{n}” will be removed. It has no shops.',
    inUse: 'This name is already used, or the district still has shops.',
    empty: 'No districts yet. Add the first one to group your shops.', noMatch: 'No district matches the search.',
    all: 'All', none: 'No district',
    errors: { VALIDATION_FAILED: 'Enter a name.', generic: 'Could not save. Try again.' }
  },
  ru: {
    title: 'Районы',
    description: 'Где находятся ваши магазины и как идут сегодняшние визиты в каждом районе.',
    search: 'Поиск района…', add: 'Добавить район', addTitle: 'Новый район', renameTitle: 'Переименовать район',
    name: 'Название района', namePlaceholder: 'Например, Köpetdag',
    shops: ['магазин', 'магазина', 'магазинов'], agents: ['агент', 'агента', 'агентов'],
    visitedToday: 'Посещено сегодня', overdue: 'Просрочено: {n}', noShops: 'Магазинов пока нет', openShops: 'Открыть магазины',
    rename: 'Переименовать', delete: 'Удалить', cancel: 'Отмена', save: 'Сохранить', create: 'Добавить',
    deleteTitle: 'Удалить район?', deleteBody: 'Район «{n}» будет удалён. Магазинов в нём нет.',
    inUse: 'Название уже занято, или в районе ещё есть магазины.',
    empty: 'Районов пока нет. Добавьте первый, чтобы сгруппировать магазины.', noMatch: 'Нет районов по запросу.',
    all: 'Все', none: 'Без района',
    errors: { VALIDATION_FAILED: 'Введите название.', generic: 'Не удалось сохранить. Попробуйте ещё раз.' }
  },
  tk: {
    title: 'Etraplar',
    description: 'Dükanlaryňyz nirede we her etrapda şu günki saparlar nähili barýar.',
    search: 'Etrap gözle…', add: 'Etrap goş', addTitle: 'Täze etrap', renameTitle: 'Etrabyň adyny üýtget',
    name: 'Etrabyň ady', namePlaceholder: 'Mysal üçin, Köpetdag',
    shops: ['dükan'], agents: ['agent'],
    visitedToday: 'Şu gün baryldy', overdue: 'Gijikdirilen: {n}', noShops: 'Entek dükan ýok', openShops: 'Dükanlary aç',
    rename: 'Adyny üýtget', delete: 'Poz', cancel: 'Ýatyr', save: 'Ýatda sakla', create: 'Goş',
    deleteTitle: 'Etraby pozmalymy?', deleteBody: '«{n}» etraby pozular. Onda dükan ýok.',
    inUse: 'Bu at eýýäm bar, ýa-da etrapda henizem dükanlar bar.',
    empty: 'Entek etrap ýok. Dükanlary toparlamak üçin birinjisini goşuň.', noMatch: 'Gözleg boýunça etrap ýok.',
    all: 'Ählisi', none: 'Etrapsyz',
    errors: { VALIDATION_FAILED: 'Ady giriziň.', generic: 'Ýatda saklap bolmady. Täzeden synanyşyň.' }
  }
})
export type DistrictsCopy = typeof districtsCopy.en
