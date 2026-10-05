import { describe, expect, it } from 'vitest';
import en from '../messages/en.json';
import ru from '../messages/ru.json';

function keys(messages: object, prefix = ''): string[] {
  return Object.entries(messages).flatMap(([key, value]) =>
    typeof value === 'object' && value !== null
      ? keys(value, `${prefix}${key}.`)
      : [`${prefix}${key}`],
  );
}

describe('translations', () => {
  it('ru and en define the same keys', () => {
    const ruKeys = keys(ru);
    const enKeys = keys(en);
    expect(ruKeys.filter((k) => !enKeys.includes(k)), 'missing in en.json').toEqual([]);
    expect(enKeys.filter((k) => !ruKeys.includes(k)), 'missing in ru.json').toEqual([]);
  });
});
