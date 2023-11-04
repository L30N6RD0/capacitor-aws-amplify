import { WebPlugin } from '@capacitor/core';

import type { AwsAmplifyPlugin } from './definitions';

export class AwsAmplifyWeb extends WebPlugin implements AwsAmplifyPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
