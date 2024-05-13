import {
  NativeModulesProxy,
  EventEmitter,
  Subscription,
} from "expo-modules-core";

import ExpoPdfTextModule from "./ExpoPdfTextModule";

export async function parsePdf(url: string): Promise<string> {
  return await ExpoPdfTextModule.parsePdf(url);
}
