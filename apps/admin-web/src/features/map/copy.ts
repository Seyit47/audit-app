import { defineCopy } from '@/lib/i18n'

// English from Figma 21:2 / 3:2; Russian labels of the shop card from 3:2.
export const mapCopy = defineCopy({
  en: {
    search: 'Search location, client or address...',
    filtered: 'Filtered view: {n}',
    locations: ['location', 'locations'], salesmen: ['salesman', 'salesmen'], regions: ['region', 'regions'],
    filters: 'Filters', recenter: 'Re-center', zoomIn: 'Zoom in', zoomOut: 'Zoom out',
    layers: 'Switch map / satellite', fullscreen: 'Full screen', refresh: 'Refresh',
    panel: { salesman: 'Salesman', searchable: 'Searchable', searchAgents: 'Search agents...', region: 'Region Zone', allRegions: 'All Regions ({n})', apply: 'Apply Filters', clear: 'Clear All', close: 'Close', remove: 'Remove' },
    unit: 'units', hereNow: 'Last signal {n}',
    card: {
      close: 'Close', verified: 'Verified', pending: 'Pending review', inactive: 'Inactive',
      types: { HYPERMARKET: 'Hypermarket', SUPERMARKET: 'Supermarket', MARKET: 'Market', MINIMARKET: 'Minimarket', OTHER: 'Other' },
      region: 'Region', address: 'Address', lastAudit: 'Last audit', agent: 'Salesman', audits: 'Audits', phones: 'Phone number',
      photos: 'Photos', openGallery: 'Open gallery', morePhotos: '+{n} photos', none: '—', unassigned: 'Unassigned',
      details: 'Open details'
    }
  },
  ru: {
    search: 'Поиск по адресу, клиенту или локации...',
    filtered: 'Фильтр: {n}',
    locations: ['точка', 'точки', 'точек'], salesmen: ['агент', 'агента', 'агентов'], regions: ['регион', 'региона', 'регионов'],
    filters: 'Фильтры', recenter: 'Центрировать', zoomIn: 'Приблизить', zoomOut: 'Отдалить',
    layers: 'Карта / спутник', fullscreen: 'Во весь экран', refresh: 'Обновить',
    panel: { salesman: 'Агент', searchable: 'С поиском', searchAgents: 'Поиск агентов...', region: 'Регион', allRegions: 'Все регионы ({n})', apply: 'Применить', clear: 'Сбросить', close: 'Закрыть', remove: 'Убрать' },
    unit: 'точек', hereNow: 'Сигнал: {n}',
    card: {
      close: 'Закрыть', verified: 'Проверено', pending: 'На проверке', inactive: 'Неактивен',
      types: { HYPERMARKET: 'Гипермаркет', SUPERMARKET: 'Супермаркет', MARKET: 'Маркет', MINIMARKET: 'Минимаркет', OTHER: 'Другое' },
      region: 'Регион', address: 'Адресс', lastAudit: 'Последний аудит', agent: 'Агент', audits: 'Число аудитов', phones: 'Номер телефона',
      photos: 'Фотографии', openGallery: 'Открыть галерею', morePhotos: '+{n} фото', none: '—', unassigned: 'Не назначен',
      details: 'Подробнее'
    }
  }
})

export type MapCopy = typeof mapCopy.en
