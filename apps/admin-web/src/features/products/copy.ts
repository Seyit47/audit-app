import { defineCopy } from '@/lib/i18n'

// English from Figma 30:574; Russian dialog text from 495:2311.
export const productsCopy = defineCopy({
  en: {
    title: 'Products', badge: 'Operations Live',
    description: 'Manage products and track their distribution across locations, field merchandisers, and regional shelves.',
    exportCatalog: 'Export Catalog', addProduct: 'Add Product', search: 'Search product...',
    status: 'Status', allStatus: 'All status', statuses: { ACTIVE: 'Active', DRAFT: 'Draft', INACTIVE: 'Archived' },
    columns: { product: 'Product', code: 'Code', status: 'Status' },
    selectAll: 'Select all', selectRow: 'Select product', actions: 'Actions', edit: 'Edit', empty: 'No products yet', exportFailed: 'The export failed. Try again.',
    pagination: { showing: 'Showing', of: 'of', show: 'Show:', perPage: 'per page', previous: 'Previous page', next: 'Next page', noun: 'products' },
    form: {
      addTitle: 'Add product', editTitle: 'Edit product', subtitle: 'Fill in the product details for the catalog and stock tracking', close: 'Close',
      image: 'Product image', photo: 'PHOTO', imageHint: 'Shown in the auditor mobile app and visit reports (PNG, JPG up to 5 MB).', chooseFile: 'Choose file', noFile: 'No file chosen', uploading: 'Uploading…', uploadFailed: 'Upload failed',
      descriptionLabel: 'Description and composition', descriptionPlaceholder: 'Detailed properties, usage rules and recommendations...',
      name: 'Product name', namePlaceholder: 'e.g. Restoring hair mask 500ml', sku: 'SKU', skuPlaceholder: 'SKU-204',
      category: 'Category', categoryPlaceholder: 'Choose a category...', brand: 'Brand', brandPlaceholder: 'Brand name',
      price: 'Retail price', currency: 'TMT', statusLabel: 'Product status', statuses: { ACTIVE: 'Active', DRAFT: 'Draft', INACTIVE: 'Archive' },
      stock: 'Stock and batches', stockQty: 'Current stock (pcs)', minStock: 'Minimum alert threshold',
      cancel: 'Cancel', save: 'Save changes',
      errors: { required: 'Fill in the name, SKU, category and price', CONFLICT: 'This SKU is already used', generic: 'Could not save. Try again.', image: 'Product images must be PNG or JPG up to 5 MB' }
    }
  },
  ru: {
    title: 'Продукции', badge: 'В работе',
    description: 'Управляйте товарами и отслеживайте их распространение по точкам, мерчендайзерам и регионам.',
    exportCatalog: 'Экспорт каталога', addProduct: 'Добавить продукт', search: 'Поиск продукта...',
    status: 'Статус', allStatus: 'Все статусы', statuses: { ACTIVE: 'Активен', DRAFT: 'Черновик', INACTIVE: 'Архив' },
    columns: { product: 'Продукт', code: 'Код', status: 'Статус' },
    selectAll: 'Выбрать все', selectRow: 'Выбрать продукт', actions: 'Действия', edit: 'Редактировать', empty: 'Продуктов пока нет', exportFailed: 'Не удалось выгрузить файл. Попробуйте ещё раз.',
    pagination: { showing: 'Показано', of: 'из', show: 'Показывать:', perPage: 'на странице', previous: 'Предыдущая страница', next: 'Следующая страница', noun: 'продуктов' },
    form: {
      addTitle: 'Добавить продукт', editTitle: 'Редактировать продукт', subtitle: 'Заполните характеристики товара для каталога и учета остатков', close: 'Закрыть',
      image: 'Изображение Товара', photo: 'ФОТО', imageHint: 'Отображается в мобильном приложении аудитора и отчетах визитов (PNG, JPG до 5 МБ).', chooseFile: 'Выбрать файл', noFile: 'Файл не выбран', uploading: 'Загрузка…', uploadFailed: 'Не удалось загрузить',
      descriptionLabel: 'Описание и состав', descriptionPlaceholder: 'Подробные свойства, правила применения и рекомендации...',
      name: 'Название продукта', namePlaceholder: 'Например, Восстанавливающая маска для волос 500мл', sku: 'Артикул (sku)', skuPlaceholder: 'SKU-204',
      category: 'Категория', categoryPlaceholder: 'Выберите категорию...', brand: 'Бренд', brandPlaceholder: 'Название бренда',
      price: 'Розничная цена', currency: 'TMT', statusLabel: 'Статус товара', statuses: { ACTIVE: 'Активен', DRAFT: 'Черновик', INACTIVE: 'Архив' },
      stock: 'Складской учет и партии', stockQty: 'Текущий остаток (шт)', minStock: 'Минимальный лимит оповещения',
      cancel: 'Отменить', save: 'Сохранить изменения',
      errors: { required: 'Заполните название, артикул, категорию и цену', CONFLICT: 'Этот артикул уже используется', generic: 'Не удалось сохранить. Попробуйте ещё раз.', image: 'Изображение: PNG или JPG до 5 МБ' }
    }
  }
})

export type ProductsCopy = typeof productsCopy.en
