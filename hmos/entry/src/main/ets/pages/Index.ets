// SPDX-License-Identifier: AGPL-3.0-or-later

import { FlutterPage, FlutterManager, Log } from '@ohos/flutter_ohos';

const TAG = "NyachiIndex";

@Entry
@Component
struct Index {
  @LocalStorageProp('viewId') viewId: string = "";

  aboutToAppear() {
    if (this.viewId === "") {
      let viewList = FlutterManager.getInstance().getFlutterViewList();
      if (viewList.size > 0) {
        let firstKey = viewList.keys().next().value as string;
        if (firstKey !== undefined) {
          this.viewId = firstKey;
        }
      }
    }
    Log.i(TAG, "aboutToAppear viewId=" + this.viewId);
  }

  build() {
    Column() {
      FlutterPage({ viewId: this.viewId })
    }
    .width('100%')
    .height('100%')
  }
}