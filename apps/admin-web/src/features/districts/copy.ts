import { defineCopy } from '@/lib/i18n'

export const districtsCopy = defineCopy({
  en: {
    title: 'Districts',
    description: 'Shops are grouped by district. A district with shops cannot be deleted: move its shops first.',
    name: 'District name', add: 'Add district', shops: 'Shops', empty: 'No districts yet',
    rename: 'Rename', delete: 'Delete', cancel: 'Cancel', confirm: 'Save',
    inUse: 'This name is already used, or the district still has shops.',
    all: 'All districts', none: 'No district',
    errors: { VALIDATION_FAILED: 'Enter a name.', generic: 'Could not save. Try again.' }
  },
  ru: {
    title: 'Районы',
    description: 'Точки сгруппированы по районам. Район с точками нельзя удалить: сначала перенесите точки.',
    name: 'Название района', add: 'Добавить район', shops: 'Точки', empty: 'Районов пока нет',
    rename: 'Переименовать', delete: 'Удалить', cancel: 'Отмена', confirm: 'Сохранить',
    inUse: 'Название уже занято, или в районе ещё есть точки.',
    all: 'Все районы', none: 'Без района',
    errors: { VALIDATION_FAILED: 'Введите название.', generic: 'Не удалось сохранить. Попробуйте ещё раз.' }
  },
  tk: {
    title: 'Etraplar',
    description: 'Nokatlar etraplar boýunça toparlanýar. Nokatly etraby pozup bolmaýar: ilki nokatlary geçiriň.',
    name: 'Etrabyň ady', add: 'Etrap goş', shops: 'Nokatlar', empty: 'Entek etrap ýok',
    rename: 'Adyny üýtget', delete: 'Poz', cancel: 'Ýatyr', confirm: 'Ýatda sakla',
    inUse: 'Bu at eýýäm bar, ýa-da etrapda henizem nokatlar bar.',
    all: 'Ähli etraplar', none: 'Etrapsyz',
    errors: { VALIDATION_FAILED: 'Ady giriziň.', generic: 'Ýatda saklap bolmady. Täzeden synanyşyň.' }
  }
})
export type DistrictsCopy = typeof districtsCopy.en
