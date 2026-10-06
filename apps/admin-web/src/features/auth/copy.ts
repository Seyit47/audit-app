import { defineCopy } from '@/lib/i18n'

// Sign-in is an approved exception (G1): no Figma frame, so the text is ours.
export const authCopy = defineCopy({
  en: {
    title: 'Sign in',
    subtitle: 'Admin panel',
    email: 'Email',
    password: 'Password',
    submit: 'Sign in',
    errors: {
      credentials: 'Wrong email or password',
      agent: 'Agents sign in from the mobile app',
      rateLimited: 'Too many attempts. Try again in a minute.',
      generic: 'Something went wrong. Please try again.'
    }
  },
  ru: {
    title: 'Вход',
    subtitle: 'Панель администратора',
    email: 'Email',
    password: 'Пароль',
    submit: 'Войти',
    errors: {
      credentials: 'Неверный email или пароль',
      agent: 'Агенты входят через мобильное приложение',
      rateLimited: 'Слишком много попыток. Попробуйте через минуту.',
      generic: 'Что-то пошло не так. Попробуйте ещё раз.'
    }
  }
})
