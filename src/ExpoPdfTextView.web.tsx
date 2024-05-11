import * as React from 'react';

import { ExpoPdfTextViewProps } from './ExpoPdfText.types';

export default function ExpoPdfTextView(props: ExpoPdfTextViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
