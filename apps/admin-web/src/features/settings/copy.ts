import { defineCopy } from '@/lib/i18n'

// Settings page (approved exception A4), built from existing components only.
export const settingsCopy = defineCopy({
  en: {
    title: 'Settings', description: 'Company profile, working hours, visit rules, GPS checks and sales regions.',
    company: 'Company', companyName: 'Company name', logo: 'Company logo', logoHint: 'PNG or JPG, shown in the sidebar',
    upload: { upload: 'Upload', remove: 'Remove', uploading: 'Uploading…', failed: 'Upload failed' },
    hours: 'Working hours', workStart: 'Start of day', workEnd: 'End of day', timezone: 'Time zone',
    hoursHint: 'Routes are built before the start of day; unvisited stops become missed at its end.',
    rules: 'Visits and GPS', visitFrequency: 'Visit frequency', days: 'days',
    radius: 'Audit radius', accuracy: 'Required GPS accuracy', noSignal: 'No-signal alert after', meters: 'm', minutes: 'min',
    radiusHint: 'Default for new shops; an audit must start within it.',
    save: 'Save changes', saving: 'Saving…', saved: 'Saved',
    regions: 'Regions', regionName: 'Region name', addRegion: 'Add region', rename: 'Rename', delete: 'Delete', cancel: 'Cancel', confirm: 'Save',
    noRegions: 'No regions yet',
    errors: { field: 'Required', range: 'From {min} to {max}', hours: 'The end must be after the start', CONFLICT: 'This name is already used, or the region still has shops or salesmen.', VALIDATION_FAILED: 'Check the values: some are out of range.', generic: 'Could not save. Try again.' }
  },
  ru: {
    title: 'Настройки', description: 'Профиль компании, рабочие часы, правила визитов, проверки GPS и регионы продаж.',
    company: 'Компания', companyName: 'Название компании', logo: 'Логотип компании', logoHint: 'PNG или JPG, показывается в меню',
    upload: { upload: 'Загрузить', remove: 'Удалить', uploading: 'Загрузка…', failed: 'Не удалось загрузить' },
    hours: 'Рабочие часы', workStart: 'Начало дня', workEnd: 'Конец дня', timezone: 'Часовой пояс',
    hoursHint: 'Маршруты строятся до начала дня; непосещённые точки становятся пропущенными в его конце.',
    rules: 'Визиты и GPS', visitFrequency: 'Частота визитов', days: 'дн.',
    radius: 'Радиус аудита', accuracy: 'Требуемая точность GPS', noSignal: 'Нет сигнала — тревога через', meters: 'м', minutes: 'мин',
    radiusHint: 'По умолчанию для новых точек; аудит начинается только внутри радиуса.',
    save: 'Сохранить изменения', saving: 'Сохранение…', saved: 'Сохранено',
    regions: 'Регионы', regionName: 'Название региона', addRegion: 'Добавить регион', rename: 'Переименовать', delete: 'Удалить', cancel: 'Отмена', confirm: 'Сохранить',
    noRegions: 'Регионов пока нет',
    errors: { field: 'Обязательное поле', range: 'От {min} до {max}', hours: 'Конец должен быть позже начала', CONFLICT: 'Название уже занято, или в регионе ещё есть точки или агенты.', VALIDATION_FAILED: 'Проверьте значения: некоторые вне допустимого диапазона.', generic: 'Не удалось сохранить. Попробуйте ещё раз.' }
  }
})

export type SettingsCopy = typeof settingsCopy.en
