import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to ExpoPdfText.web.ts
// and on native platforms to ExpoPdfText.ts
import ExpoPdfTextModule from './ExpoPdfTextModule';
import ExpoPdfTextView from './ExpoPdfTextView';
import { ChangeEventPayload, ExpoPdfTextViewProps } from './ExpoPdfText.types';

// Get the native constant value.
export const PI = ExpoPdfTextModule.PI;

export function hello(): string {
  return ExpoPdfTextModule.hello();
}

export async function setValueAsync(value: string) {
  return await ExpoPdfTextModule.setValueAsync(value);
}

const emitter = new EventEmitter(ExpoPdfTextModule ?? NativeModulesProxy.ExpoPdfText);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ExpoPdfTextView, ExpoPdfTextViewProps, ChangeEventPayload };
