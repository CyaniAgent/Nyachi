// SPDX-License-Identifier: AGPL-3.0-or-later

import { FlutterView } from '@ohos/flutter_ohos';

@Entry
@Component
struct Index {

  build() {
    Column() {
      FlutterView({ entryName: 'main' })
    }
    .width('100%')
    .height('100%')
  }
}