import { defineCopy } from '@/lib/i18n'

// English from Figma 21:2 / 3:2; Russian labels of the shop card from 3:2.
export const mapCopy = defineCopy({
  en: {
    search: 'Search location, client or address...',
    filtered: 'Filtered view: {n}',
    locations: ['location', 'locations'], salesmen: ['salesman', 'salesmen'], regions: ['region', 'regions'],
    filters: 'Filters', recenter: 'Re-center', zoomIn: 'Zoom in', zoomOut: 'Zoom out',
    layers: 'Switch map / satellite', fullscreen: 'Full screen', refresh: 'Refresh',
    panel: { show: 'Users/Shops', showBoth: 'Both', showAgents: 'Agents', showShops: 'Shops', status: 'Status', statusAll: 'All', visited: 'Visited', notVisited: 'Not visited', recent: 'Recent', salesman: 'Salesman', searchable: 'Searchable', searchAgents: 'Search agents...', region: 'Region Zone', allRegions: 'All Regions ({n})', apply: 'Apply Filters', clear: 'Clear All', close: 'Close', remove: 'Remove' },
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
    panel: { show: 'Агенты/Магазины', showBoth: 'Все', showAgents: 'Агенты', showShops: 'Магазины', status: 'Статус', statusAll: 'Все', visited: 'Посещённые', notVisited: 'Не посещённые', recent: 'Недавние', salesman: 'Агент', searchable: 'С поиском', searchAgents: 'Поиск агентов...', region: 'Регион', allRegions: 'Все регионы ({n})', apply: 'Применить', clear: 'Сбросить', close: 'Закрыть', remove: 'Убрать' },
    unit: 'точек', hereNow: 'Сигнал: {n}',
    card: {
      close: 'Закрыть', verified: 'Проверено', pending: 'На проверке', inactive: 'Неактивен',
      types: { HYPERMARKET: 'Гипермаркет', SUPERMARKET: 'Супермаркет', MARKET: 'Маркет', MINIMARKET: 'Минимаркет', OTHER: 'Другое' },
      region: 'Регион', address: 'Адресс', lastAudit: 'Последний аудит', agent: 'Агент', audits: 'Число аудитов', phones: 'Номер телефона',
      photos: 'Фотографии', openGallery: 'Открыть галерею', morePhotos: '+{n} фото', none: '—', unassigned: 'Не назначен',
      details: 'Подробнее'
    }
  },
  tk: {
    search: 'Salgy, müşderi ýa-da ýer boýunça gözle...',
    filtered: 'Süzgüç: {n}',
    locations: ['nokat'], salesmen: ['agent'], regions: ['sebit'],
    filters: 'Süzgüçler', recenter: 'Merkeze getir', zoomIn: 'Ýakynlaşdyr', zoomOut: 'Daşlaşdyr',
    layers: 'Karta / hemra', fullscreen: 'Doly ekran', refresh: 'Täzele',
    panel: { show: 'Agentler/Dükanlar', showBoth: 'Ählisi', showAgents: 'Agentler', showShops: 'Dükanlar', status: 'Ýagdaý', statusAll: 'Ählisi', visited: 'Baryp görlen', notVisited: 'Baryp görülmedik', recent: 'Soňky', salesman: 'Agent', searchable: 'Gözleg bilen', searchAgents: 'Agentleri gözle...', region: 'Sebit', allRegions: 'Ähli sebitler ({n})', apply: 'Ulan', clear: 'Arassala', close: 'Ýap', remove: 'Aýyr' },
    unit: 'nokat', hereNow: 'Signal: {n}',
    card: {
      close: 'Ýap', verified: 'Barlandy', pending: 'Barlagda', inactive: 'Işjeň däl',
      types: { HYPERMARKET: 'Gipermarket', SUPERMARKET: 'Supermarket', MARKET: 'Market', MINIMARKET: 'Minimarket', OTHER: 'Başga' },
      region: 'Sebit', address: 'Salgy', lastAudit: 'Soňky audit', agent: 'Agent', audits: 'Auditleriň sany', phones: 'Telefon belgisi',
      photos: 'Suratlar', openGallery: 'Galereýany aç', morePhotos: '+{n} surat', none: '—', unassigned: 'Bellenmedik',
      details: 'Jikme-jiklikler'
    }
  }
})

export type MapCopy = typeof mapCopy.en
