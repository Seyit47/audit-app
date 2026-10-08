import { test } from 'node:test'
import * as assert from 'node:assert'
import { tmPhone } from '../../src/lib/phone.js'

test('Turkmen numbers in any common form become +993XXXXXXXX', () => {
  for (const input of ['+993 65 123456', '+99365123456', '993 65 123456', '8 65 123456', '865123456', '65 123456', '(65) 12-34-56']) {
    assert.strictEqual(tmPhone(input, 'mobile'), '+99365123456', input)
  }
  assert.strictEqual(tmPhone('+993 71 123456', 'mobile'), '+99371123456')
  assert.strictEqual(tmPhone('+993 72 123456', 'mobile'), '+99372123456')
})

test('salesmen need a mobile number; shop contacts may be landlines', () => {
  assert.strictEqual(tmPhone('+993 12 345678', 'mobile'), null, 'Ashgabat landline is not mobile')
  assert.strictEqual(tmPhone('+993 12 345678', 'any'), '+99312345678')
  assert.strictEqual(tmPhone('+993 322 12345', 'any'), '+99332212345')
})

test('not Turkmen numbers or wrong lengths are rejected', () => {
  for (const input of ['+7 912 345 67 89', '+993 65 12345', '+993 65 1234567', '+993 85 123456', '+993 01 234567', 'phone', '']) {
    assert.strictEqual(tmPhone(input, 'any'), null, input)
  }
})
