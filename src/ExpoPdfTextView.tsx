import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ExpoPdfTextViewProps } from './ExpoPdfText.types';

const NativeView: React.ComponentType<ExpoPdfTextViewProps> =
  requireNativeViewManager('ExpoPdfText');

export default function ExpoPdfTextView(props: ExpoPdfTextViewProps) {
  return <NativeView {...props} />;
}
