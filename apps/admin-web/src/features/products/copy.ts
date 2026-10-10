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
      errors: { required: 'Fill in the name, SKU, category and price', field: 'Required', price: 'Enter a price, e.g. 185.00', count: 'A whole number, 0 or more', CONFLICT: 'This SKU is already used', generic: 'Could not save. Try again.', image: 'Product images must be PNG or JPG up to 5 MB' }
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
      errors: { required: 'Заполните название, артикул, категорию и цену', field: 'Обязательное поле', price: 'Введите цену, например 185.00', count: 'Целое число, 0 или больше', CONFLICT: 'Этот артикул уже используется', generic: 'Не удалось сохранить. Попробуйте ещё раз.', image: 'Изображение: PNG или JPG до 5 МБ' }
    }
  },
  tk: {
    title: 'Önümler', badge: 'Işde',
    description: 'Harytlary dolandyryň we olaryň nokatlar, merçendaýzerler we sebitler boýunça ýaýraýşyny yzarlaň.',
    exportCatalog: 'Katalogy eksport et', addProduct: 'Önüm goş', search: 'Önümi gözle...',
    status: 'Ýagdaý', allStatus: 'Ähli ýagdaýlar', statuses: { ACTIVE: 'Işjeň', DRAFT: 'Garalama', INACTIVE: 'Arhiw' },
    columns: { product: 'Önüm', code: 'Kod', status: 'Ýagdaý' },
    selectAll: 'Ählisini saýla', selectRow: 'Önümi saýla', actions: 'Hereketler', edit: 'Üýtget', empty: 'Häzirlikçe önüm ýok', exportFailed: 'Faýly düşürip bolmady. Gaýtadan synanyşyň.',
    pagination: { showing: 'Görkezilýär', of: '/', show: 'Görkez:', perPage: 'sahypada', previous: 'Öňki sahypa', next: 'Indiki sahypa', noun: 'önüm' },
    form: {
      addTitle: 'Önüm goş', editTitle: 'Önümi üýtget', subtitle: 'Katalog we galyndylary hasaba almak üçin harydyň häsiýetlerini dolduryň', close: 'Ýap',
      image: 'Harydyň suraty', photo: 'SURAT', imageHint: 'Auditoryň mobil programmasynda we sapar hasabatlarynda görkezilýär (PNG, JPG 5 MB çenli).', chooseFile: 'Faýl saýla', noFile: 'Faýl saýlanmady', uploading: 'Ýüklenýär…', uploadFailed: 'Ýükläp bolmady',
      descriptionLabel: 'Beýany we düzümi', descriptionPlaceholder: 'Jikme-jik häsiýetleri, ulanyş düzgünleri we maslahatlar...',
      name: 'Önümiň ady', namePlaceholder: 'Mysal üçin, Saç üçin dikeldiji maska 500ml', sku: 'Artikul (SKU)', skuPlaceholder: 'SKU-204',
      category: 'Kategoriýa', categoryPlaceholder: 'Kategoriýany saýlaň...', brand: 'Brend', brandPlaceholder: 'Brendiň ady',
      price: 'Bölek satuw bahasy', currency: 'TMT', statusLabel: 'Harydyň ýagdaýy', statuses: { ACTIVE: 'Işjeň', DRAFT: 'Garalama', INACTIVE: 'Arhiw' },
      stock: 'Ammar hasaby we partiýalar', stockQty: 'Häzirki galyndy (sany)', minStock: 'Duýduryş üçin iň az çäk',
      cancel: 'Ýatyr', save: 'Üýtgeşmeleri ýatda sakla',
      errors: { required: 'Adyny, artikuly, kategoriýany we bahany dolduryň', field: 'Hökmany meýdança', price: 'Bahany giriziň, mysal üçin 185.00', count: 'Bitin san, 0 ýa-da köp', CONFLICT: 'Bu artikul eýýäm ulanylýar', generic: 'Ýatda saklap bolmady. Gaýtadan synanyşyň.', image: 'Surat: PNG ýa-da JPG, 5 MB çenli' }
    }
  }
})

export type ProductsCopy = typeof productsCopy.en
