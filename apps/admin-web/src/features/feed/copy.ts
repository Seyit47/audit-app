import { defineCopy } from '@/lib/i18n'

// Bell activity feed (approved exception A6); labels reuse the visit history wording of 47:7387.
export const feedCopy = defineCopy({
  en: {
    open: 'Notifications', title: 'Activity', subtitle: 'Violations and missed visits',
    close: 'Close', violation: 'Violation', missed: 'Missed', comment: 'Violation recorded:',
    empty: 'Nothing new yet', more: 'Show more', today: 'Today', error: 'Could not load the feed'
  },
  ru: {
    open: 'Уведомления', title: 'Активность', subtitle: 'Нарушения и пропущенные визиты',
    close: 'Закрыть', violation: 'Нарушение', missed: 'Пропущен', comment: 'Зафиксировано нарушение:',
    empty: 'Пока ничего нового', more: 'Показать ещё', today: 'Сегодня', error: 'Не удалось загрузить ленту'
  },
  tk: {
    open: 'Bildirişler', title: 'Işjeňlik', subtitle: 'Bozulmalar we sypdyrylan saparlar',
    close: 'Ýap', violation: 'Bozulma', missed: 'Sypdyryldy', comment: 'Bozulma bellenildi:',
    empty: 'Häzirlikçe täze zat ýok', more: 'Ýene görkez', today: 'Şu gün', error: 'Habarlary ýükläp bolmady'
  }
})

export type FeedCopy = typeof feedCopy.en
