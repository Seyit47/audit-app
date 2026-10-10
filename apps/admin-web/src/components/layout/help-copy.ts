import { defineCopy } from '@/lib/i18n'

export interface HelpTopic { title: string, tips: string[] }

// What each header page lets you do; shown by the header help button. Keys are route patterns.
export const helpCopy = defineCopy({
  en: {
    heading: 'On this page',
    close: 'Close',
    pages: {
      '/shops': {
        title: 'Shops',
        tips: [
          'Search by name, code or address — matches appear as you type; Enter filters the list.',
          'Filter by status and region with the selects in the toolbar.',
          'Tick rows to assign a salesman, view them on the map or delete them together.',
          'Use ⋯ on a row to view, edit, show on the map, assign or delete a shop.',
          '“Add Shop” creates a shop; “Export Shops” downloads the current list as Excel.'
        ]
      },
      '/shops/[id]': {
        title: 'Shop details',
        tips: [
          'See the shop’s KPIs, contacts, assigned salesman and products carried.',
          'Edit the shop, change its status or open it on the map from the header.',
          'Browse the visit history: audits with photos, comments and violations, and missed visits.',
          'Click a photo to open it in the gallery.'
        ]
      },
      '/products': {
        title: 'Products',
        tips: [
          'Search the catalog as you type; filter by status.',
          'Click a product to edit its details, price, image and stock settings.',
          '“Add Product” creates a new item; “Export Catalog” downloads it as Excel.'
        ]
      },
      '/salesmen': {
        title: 'Salesmen',
        tips: [
          'The cards sum up today’s field activity.',
          'Choose a date range or a preset (Today, Yesterday, This week) — the table counts visits and photos for it.',
          'Filter by status and region; click a column header to sort.',
          'Open a salesman for their route, timeline and photo reports, or edit them from ⋯.',
          '“Add Salesman” creates an account with the password you set; “Change password” in ⋯ sets a new one; “Export Roster” downloads the list as Excel.'
        ]
      },
      '/salesmen/[id]': {
        title: 'Salesman details',
        tips: [
          'Follow the route on the map; the timeline lists each stop of the selected day.',
          'Check the KPIs, audit photo reports and visit history (completed and missed).',
          'Export a PDF or Excel report from the header.',
          'The status chip shows whether the salesman is online and how precise the last position is.'
        ]
      },
      '/pictures': {
        title: 'Gallery',
        tips: [
          'Every audit photo, newest first; switch between grid and grouping by date.',
          'Use Filters to narrow by date, location and status.',
          'Click a photo to see the shop, salesman, comment and related shots.'
        ]
      },
      '/settings': {
        title: 'Settings',
        tips: [
          'Set the company name and logo shown in the sidebar.',
          'Working hours and time zone define the field day and reports.',
          'Audit rules: visit frequency, check-in radius, minimum GPS accuracy and the no-signal alert time.',
          'Press “Save changes” to apply them for everyone.'
        ]
      }
    } satisfies Record<string, HelpTopic>
  },
  ru: {
    heading: 'На этой странице',
    close: 'Закрыть',
    pages: {
      '/shops': {
        title: 'Клиенты',
        tips: [
          'Ищите по названию, коду или адресу — совпадения появляются при вводе; Enter фильтрует список.',
          'Фильтруйте по статусу и региону в панели над таблицей.',
          'Отметьте строки, чтобы назначить агента, показать их на карте или удалить сразу несколько.',
          'Меню ⋯ в строке: подробнее, редактировать, на карте, назначить агента, удалить.',
          '«Добавить клиента» создаёт точку; «Экспорт клиентов» скачивает текущий список в Excel.'
        ]
      },
      '/shops/[id]': {
        title: 'Карточка клиента',
        tips: [
          'Показатели точки, контакты, закреплённый агент и ассортимент.',
          'В шапке: редактирование, смена статуса и переход на карту.',
          'История визитов: аудиты с фото, комментариями и нарушениями, а также пропущенные визиты.',
          'Нажмите на фото, чтобы открыть его в галерее.'
        ]
      },
      '/products': {
        title: 'Продукции',
        tips: [
          'Поиск по каталогу при вводе; фильтр по статусу.',
          'Нажмите на товар, чтобы изменить описание, цену, изображение и учёт остатков.',
          '«Добавить продукт» создаёт товар; «Экспорт каталога» скачивает его в Excel.'
        ]
      },
      '/salesmen': {
        title: 'Агенты',
        tips: [
          'Карточки сверху — сводка полевой работы за сегодня.',
          'Выберите период или быстрый фильтр (Сегодня, Вчера, Текущая неделя) — таблица посчитает визиты и фото за него.',
          'Фильтруйте по статусу и региону; нажмите на заголовок столбца для сортировки.',
          'Откройте агента, чтобы увидеть маршрут, хронологию и фотоотчёты, или измените его через ⋯.',
          '«Добавить агента» создаёт аккаунт с заданным вами паролем; «Изменить пароль» в ⋯ задаёт новый; «Экспорт списка» выгружает список в Excel.'
        ]
      },
      '/salesmen/[id]': {
        title: 'Карточка агента',
        tips: [
          'Маршрут на карте; хронология показывает все остановки выбранного дня.',
          'Показатели, фотоотчёты аудитов и история визитов (завершённые и пропущенные).',
          'Отчёт в PDF или Excel — кнопкой экспорта в шапке.',
          'Статус показывает, в сети ли агент и точность последней геопозиции.'
        ]
      },
      '/pictures': {
        title: 'Галерея',
        tips: [
          'Все фото аудитов, новые сверху; переключайте сетку и группировку по датам.',
          'Кнопка «Фильтры» сужает выборку по дате, точке и статусу.',
          'Нажмите на фото — увидите точку, агента, комментарий и связанные снимки.'
        ]
      },
      '/settings': {
        title: 'Настройки',
        tips: [
          'Название компании и логотип в боковом меню.',
          'Рабочие часы и часовой пояс задают рабочий день и отчёты.',
          'Правила аудита: частота визитов, радиус отметки, минимальная точность GPS и время до сигнала «нет связи».',
          'Нажмите «Сохранить изменения», чтобы применить их для всех.'
        ]
      }
    } satisfies Record<string, HelpTopic>
  },
  tk: {
    heading: 'Bu sahypada',
    close: 'Ýap',
    pages: {
      '/shops': {
        title: 'Müşderiler',
        tips: [
          'Ady, kody ýa-da salgysy boýunça gözläň — gabat gelýänler ýazan wagtyňyz görünýär; Enter sanawy süzýär.',
          'Tablisanyň üstündäki panelde ýagdaý we sebit boýunça süzüň.',
          'Agent bellemek, kartada görkezmek ýa-da birnäçesini birden pozmak üçin setirleri belläň.',
          'Setirdäki ⋯ menýusy: jikme-jik, üýtgetmek, kartada, agent bellemek, pozmak.',
          '«Müşderi goş» täze nokat döredýär; «Müşderileri eksport et» häzirki sanawy Excel görnüşinde göçürýär.'
        ]
      },
      '/shops/[id]': {
        title: 'Müşderiniň kartoçkasy',
        tips: [
          'Nokadyň görkezijileri, habarlaşmak maglumatlary, berkidilen agent we assortiment.',
          'Ýokarky bölekde: üýtgetmek, ýagdaýy çalyşmak we karta geçmek.',
          'Saparlaryň taryhy: suratly, teswirli we bozulmaly auditler, şeýle hem galdyrylan saparlar.',
          'Suraty galereýada açmak üçin oňa basyň.'
        ]
      },
      '/products': {
        title: 'Önümler',
        tips: [
          'Ýazan wagtyňyz katalog boýunça gözleg; ýagdaý boýunça süzgüç.',
          'Beýanyny, bahasyny, suratyny we galyndy hasabyny üýtgetmek üçin önüme basyň.',
          '«Önüm goş» täze haryt döredýär; «Katalogy eksport et» ony Excel görnüşinde göçürýär.'
        ]
      },
      '/salesmen': {
        title: 'Agentler',
        tips: [
          'Ýokardaky kartoçkalar — şu günki meýdan işiniň jemi.',
          'Döwri ýa-da çalt süzgüji (Şu gün, Düýn, Şu hepde) saýlaň — tablisa şol döwür üçin saparlary we suratlary hasaplar.',
          'Ýagdaý we sebit boýunça süzüň; tertiplemek üçin sütüniň adyna basyň.',
          'Ugruny, wakalaryň yzygiderliligini we surat hasabatlaryny görmek üçin agenti açyň ýa-da ⋯ arkaly üýtgediň.',
          '«Agent goş» siziň beren açar sözüňiz bilen hasap döredýär; ⋯ içindäki «Açar sözi üýtget» täzesini bellär; «Sanawy eksport et» sanawy Excel görnüşinde göçürýär.'
        ]
      },
      '/salesmen/[id]': {
        title: 'Agentiň kartoçkasy',
        tips: [
          'Kartadaky ugur; wakalaryň yzygiderliligi saýlanan günüň ähli duralgalaryny görkezýär.',
          'Görkezijiler, auditleriň surat hasabatlary we saparlaryň taryhy (tamamlanan we galdyrylan).',
          'PDF ýa-da Excel hasabat — ýokarky bölekdäki eksport düwmesi bilen.',
          'Ýagdaý agentiň ulgamdadygyny we soňky ýerleşişiň takyklygyny görkezýär.'
        ]
      },
      '/pictures': {
        title: 'Galereýa',
        tips: [
          'Auditleriň ähli suratlary, täzeleri ýokarda; tor bilen sene boýunça toparlamagyň arasynda geçiň.',
          '«Süzgüçler» düwmesi saýlawy sene, nokat we ýagdaý boýunça daraldýar.',
          'Surata basyň — nokady, agenti, teswiri we baglanyşykly suratlary görersiňiz.'
        ]
      },
      '/settings': {
        title: 'Sazlamalar',
        tips: [
          'Gapdal menýudaky kompaniýanyň ady we logotipi.',
          'Iş sagatlary we sagat guşagy iş gününi we hasabatlary kesgitleýär.',
          'Audit düzgünleri: saparlaryň ýygylygy, bellik radiusy, GPS-iň iň az takyklygy we «aragatnaşyk ýok» duýduryşyna çenli wagt.',
          'Hemmeler üçin ulanmak üçin «Üýtgeşmeleri ýatda sakla» düwmesine basyň.'
        ]
      }
    } satisfies Record<string, HelpTopic>
  }
})

/** Route pattern of a pathname: `/shops/abc` → `/shops/[id]`. */
export function helpKey (pathname: string) {
  const [, section, rest] = pathname.split('/')
  return rest == null || rest === '' ? `/${section}` : `/${section}/[id]`
}
