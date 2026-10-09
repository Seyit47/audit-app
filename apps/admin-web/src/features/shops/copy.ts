import { defineCopy } from '@/lib/i18n'

// English from Figma 3:407, 53:151, 47:7387; Russian dialog text from 162:20071.
export const shopsCopy = defineCopy({
  en: {
    title: 'Shops',
    badge: 'Operations Live',
    description: 'Manage physical shops, retail outlets, and field deployment locations.',
    exportShops: 'Export Shops', addShop: 'Add Shop', assign: 'Assign salesman', viewOnMap: 'View on Map', deleteShop: 'Delete Shop',
    search: 'Search shops...', status: 'Status', region: 'Region', allStatus: 'All status', allRegions: 'All regions',
    statuses: { ACTIVE: 'Active', INACTIVE: 'Inactive', PENDING_REVIEW: 'Pending Review' },
    columns: { shop: 'Shop', code: 'Code', owner: 'Owner', phone: 'Phone', lastVisit: 'Last visit', agent: 'Assigned salesman', status: 'Status' },
    selectAll: 'Select all', selectRow: 'Select shop', by: 'by', today: 'Today', never: '—', unassigned: 'Unassigned',
    actions: 'Actions', viewDetails: 'View Details', editShop: 'Edit Shop', empty: 'No shops match these filters',
    exportFailed: 'The export failed. Try again.',
    pagination: { showing: 'Showing', of: 'of', show: 'Rows per page:', perPage: '', previous: 'Previous page', next: 'Next page', noun: 'clients' },
    assignDialog: { title: 'Assign salesman', subtitle: 'Selected shops: {n}', label: 'Salesman', none: 'Unassigned', cancel: 'Cancel', save: 'Assign' },
    deleteDialog: { title: 'Delete shops?', body: '{n} shop(s) will be removed from lists, the map and future routes. Their audit history and photos are kept.', cancel: 'Cancel', confirm: 'Delete' },
    errors: { generic: 'Something went wrong. Try again.' },
    details: {
      breadcrumb: 'Clients', assigned: 'Assigned:', statusLabel: 'Status:', edit: 'Edit',
      totalAudits: 'Total audits', productsCarried: 'Products carried', skus: 'SKUs', compliance: '{n}% shelf compliance',
      auditPhotos: 'Audit photos', geotagged: '{n}% geotagged', noAudits: 'No audits yet',
      geo: 'Geographic Distribution', gpsValid: 'All GPS Nodes Valid', noRegion: 'No region',
      recenter: 'Show the shop', fullscreen: 'Full screen', zoomIn: 'Zoom in', zoomOut: 'Zoom out',
      history: 'Visit history', updatedAt: 'Updated at', total: 'Total: {n}', completed: 'Completed ({n})', missed: 'Missed ({n})',
      done: 'Completed', missedStatus: 'Missed', declined: 'Missed', duration: 'Duration: {n} min', code: 'Code', comment: 'Agent comment:', violation: 'Violation recorded:',
      morePhotos: '+{n} photos', more: 'Show more', noVisits: 'No visits yet'
    }
  },
  ru: {
    title: 'Клиенты',
    badge: 'В работе',
    description: 'Управляйте магазинами, торговыми точками и локациями полевой работы.',
    exportShops: 'Экспорт клиентов', addShop: 'Добавить клиента', assign: 'Назначить агента', viewOnMap: 'На карте', deleteShop: 'Удалить',
    search: 'Поиск клиентов...', status: 'Статус', region: 'Регион', allStatus: 'Все статусы', allRegions: 'Все регионы',
    statuses: { ACTIVE: 'Активен', INACTIVE: 'Неактивен', PENDING_REVIEW: 'На проверке' },
    columns: { shop: 'Магазин', code: 'Код', owner: 'Владелец', phone: 'Телефон', lastVisit: 'Последний визит', agent: 'Агент', status: 'Статус' },
    selectAll: 'Выбрать все', selectRow: 'Выбрать магазин', by: '', today: 'Сегодня', never: '—', unassigned: 'Не назначен',
    actions: 'Действия', viewDetails: 'Подробнее', editShop: 'Редактировать', empty: 'Нет клиентов по этим фильтрам',
    exportFailed: 'Не удалось выгрузить файл. Попробуйте ещё раз.',
    pagination: { showing: 'Показано', of: 'из', show: 'Строк на странице:', perPage: '', previous: 'Предыдущая страница', next: 'Следующая страница', noun: 'клиентов' },
    assignDialog: { title: 'Назначить агента', subtitle: 'Выбрано магазинов: {n}', label: 'Агент', none: 'Не назначен', cancel: 'Отменить', save: 'Назначить' },
    deleteDialog: { title: 'Удалить магазины?', body: 'Магазины ({n}) исчезнут из списков, карты и будущих маршрутов. История аудитов и фото сохранятся.', cancel: 'Отменить', confirm: 'Удалить' },
    errors: { generic: 'Что-то пошло не так. Попробуйте ещё раз.' },
    details: {
      breadcrumb: 'Клиенты', assigned: 'Ответственный:', statusLabel: 'Статус:', edit: 'Изменить',
      totalAudits: 'Всего аудитов', productsCarried: 'Ассортимент', skus: 'SKU', compliance: '{n}% соответствие полки',
      auditPhotos: 'Фото аудитов', geotagged: '{n}% с геометкой', noAudits: 'Аудитов ещё нет',
      geo: 'География', gpsValid: 'Все GPS-точки валидны', noRegion: 'Без региона',
      recenter: 'Показать магазин', fullscreen: 'Во весь экран', zoomIn: 'Приблизить', zoomOut: 'Отдалить',
      history: 'История визитов', updatedAt: 'Обновлено в', total: 'В общем: {n}', completed: 'Завершён ({n})', missed: 'Пропущен ({n})',
      done: 'Завершён', missedStatus: 'Пропущен', declined: 'Отклонён', duration: 'Длительность: {n} мин', code: 'Код точки', comment: 'Комментарий агента:', violation: 'Зафиксировано нарушение:',
      morePhotos: '+{n} фото', more: 'Показать ещё', noVisits: 'Визитов ещё нет'
    }
  }
})

export type ShopsCopy = typeof shopsCopy.en

// Text of the edit/add dialog (162:20071); the frame is in Russian, English is a translation.
export const shopFormCopy = defineCopy({
  en: {
    editTitle: 'Edit shop', addTitle: 'Add shop', subtitle: 'Change the contacts, address or responsible representative', close: 'Close modal',
    photoTitle: 'SHOP FACADE PHOTO', photoHint: 'Shown on the shop cards (PNG, JPG up to 5 MB).', photoCaption: 'Current',
    upload: 'Upload new photo', remove: 'Delete', uploading: 'Uploading…', uploadFailed: 'Upload failed',
    name: 'Shop name', nameHint: 'Official legal entity or brand name',
    agent: 'Assigned sales representative', agentHint: 'The sales agent receives automatic shelf audit tasks and photo reports', noAgent: 'Not assigned',
    address: 'Actual address and geolocation', pickOnMap: 'Point on the interactive map', gpsBound: 'GPS bound', gpsMissing: 'No GPS',
    coords: 'Coordinates', zone: 'Zone', calibrate: 'Calibrate GPS', mapHint: 'Click the map to set the shop location',
    products: 'Products carried', productsPlaceholder: 'No products selected', productsSearch: 'Search products...', productsSelected: '{n} products',
    phones: 'Shop contact phones', phonesHint: 'Up to 4 numbers supported', phoneLabel: 'Label (e.g. Purchasing)', addPhone: 'Add another number', removePhone: 'Remove number',
    archive: 'Archive the shop', restore: 'Restore the shop', cancel: 'Cancel', save: 'Save changes',
    errors: { required: 'Fill in the name, address and location', phone: 'Phone numbers must be Turkmen: +993 and 8 digits (e.g. +993 65 123456, +993 12 345678)', CONFLICT: 'Someone changed this shop. Reload the page and try again.', generic: 'Could not save. Try again.' }
  },
  ru: {
    editTitle: 'Редактирование торговой точки', addTitle: 'Новая торговая точка', subtitle: 'Измените контактные данные, адрес или ответственного представителя', close: 'Закрыть модальное окно',
    photoTitle: 'ФОТОГРАФИЯ ФАСАДА МАГАЗИНА', photoHint: 'Отображается в карточке магазинов (PNG, JPG до 5 МБ).', photoCaption: 'Текущее',
    upload: 'Загрузить новое фото', remove: 'Удалить', uploading: 'Загрузка…', uploadFailed: 'Не удалось загрузить',
    name: 'Название торговой точки', nameHint: 'Официальное наименование юридического лица или бренда',
    agent: 'Закрепленный торговый представитель', agentHint: 'Торговый агент получает автоматические задачи аудита полки и сбор фотоотчетов', noAgent: 'Не назначен',
    address: 'Фактический адрес и геопозиция', pickOnMap: 'Указать на интерактивной карте', gpsBound: 'GPS привязан', gpsMissing: 'Нет GPS',
    coords: 'Координаты', zone: 'Зона', calibrate: 'Калибровать GPS', mapHint: 'Нажмите на карту, чтобы указать точку',
    products: 'Ассортимент точки', productsPlaceholder: 'Продукты не выбраны', productsSearch: 'Поиск продукта...', productsSelected: 'Продуктов: {n}',
    phones: 'Контактные телефоны точки', phonesHint: 'Поддерживается до 4 номеров', phoneLabel: 'Подпись (напр. Закупки)', addPhone: 'Добавить еще один номер', removePhone: 'Удалить номер',
    archive: 'Архивировать торговую точку', restore: 'Восстановить торговую точку', cancel: 'Отменить', save: 'Сохранить изменения',
    errors: { required: 'Заполните название, адрес и геопозицию', phone: 'Номер должен быть туркменским: +993 и 8 цифр (например, +993 65 123456, +993 12 345678)', CONFLICT: 'Магазин изменён другим пользователем. Обновите страницу и повторите.', generic: 'Не удалось сохранить. Попробуйте ещё раз.' }
  }
})

export type ShopFormCopy = typeof shopFormCopy.en
