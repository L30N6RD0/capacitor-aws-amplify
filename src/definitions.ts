export interface AwsAmplifyPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
