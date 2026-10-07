import { defineCopy } from '@/lib/i18n'

// English from Figma 53:1375 / 138:11987; Russian detail text from 138:11987.
export const photosCopy = defineCopy({
  en: {
    title: 'Pictures', description: 'Browse photos captured from field locations, retail audits, and display verifications.',
    total: '{n} Total Photos', today: '{n} Today', filters: 'Filters', upload: 'Upload Photos',
    modes: { grid: 'Grid', byDate: 'By date' },
    type: 'Type', allTypes: 'All Types', types: { AUDIT: 'Audit', FACADE: 'Storefront', ADMIN_UPLOAD: 'Uploaded' },
    location: 'Location', allLocations: 'All Locations',
    status: 'Status', allStatus: 'All status', statuses: { true: 'Verified', false: 'Not verified' },
    date: 'Date', dates: { today: 'Today', '7': 'Last 7 Days', '30': 'Last 30 Days', all: 'All time' },
    verified: 'Verified', empty: 'No photos match these filters', loading: 'Loading…',
    close: 'Close', assigned: 'Assigned:', duration: 'Duration: {n} min', today2: 'Today',
    agentComment: 'Salesman comment:', violation: 'Violation recorded:', related: 'Related audit photos ({n})', statusActive: 'Active',
    uploadDialog: {
      title: 'Upload photos', subtitle: 'Photos are added to the chosen shop', shop: 'Shop', shopPlaceholder: 'Choose a shop',
      files: 'Photos', choose: 'Choose photos', hint: 'PNG, JPG or WebP up to 10 MB each', cancel: 'Cancel', save: 'Upload', done: '{n} uploaded', failed: 'Some photos failed to upload'
    }
  },
  ru: {
    title: 'Галерея', description: 'Просматривайте фото с торговых точек, аудитов и проверок выкладки.',
    total: 'Всего фото: {n}', today: 'Сегодня: {n}', filters: 'Фильтры', upload: 'Загрузить фото',
    modes: { grid: 'Сетка', byDate: 'По дате' },
    type: 'Тип', allTypes: 'Все типы', types: { AUDIT: 'Аудит', FACADE: 'Фасад', ADMIN_UPLOAD: 'Загружено' },
    location: 'Регион', allLocations: 'Все регионы',
    status: 'Статус', allStatus: 'Все статусы', statuses: { true: 'Проверено', false: 'Не проверено' },
    date: 'Дата', dates: { today: 'Сегодня', '7': 'Последние 7 дней', '30': 'Последние 30 дней', all: 'За всё время' },
    verified: 'Проверено', empty: 'Нет фото по этим фильтрам', loading: 'Загрузка…',
    close: 'Закрыть', assigned: 'Ответственный:', duration: 'Длительность: {n} мин', today2: 'Сегодня',
    agentComment: 'Комментарий продавца:', violation: 'Зафиксировано нарушение:', related: 'Связанные фото аудита ({n})', statusActive: 'Активен',
    uploadDialog: {
      title: 'Загрузить фото', subtitle: 'Фото будут добавлены к выбранному магазину', shop: 'Магазин', shopPlaceholder: 'Выберите магазин',
      files: 'Фотографии', choose: 'Выбрать фото', hint: 'PNG, JPG или WebP до 10 МБ каждое', cancel: 'Отменить', save: 'Загрузить', done: 'Загружено: {n}', failed: 'Часть фото не загрузилась'
    }
  }
})

export type PhotosCopy = typeof photosCopy.en
