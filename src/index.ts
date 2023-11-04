import { registerPlugin } from '@capacitor/core';

import type { AwsAmplifyPlugin } from './definitions';

const AwsAmplify = registerPlugin<AwsAmplifyPlugin>('AwsAmplify', {
  web: () => import('./web').then(m => new m.AwsAmplifyWeb()),
});

export * from './definitions';
export { AwsAmplify };
