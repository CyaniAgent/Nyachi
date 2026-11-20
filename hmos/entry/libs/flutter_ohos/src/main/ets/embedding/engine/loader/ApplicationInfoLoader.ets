/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
* Use of this source code is governed by a BSD-style license that can be
* found in the LICENSE_KHZG file.
*/

import FlutterApplicationInfo from './FlutterApplicationInfo';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';

export default class ApplicationInfoLoader {
  static load(context: common.Context) {
    let arch = 'arm64';
    let x86LibPath = context.bundleCodeDir + '/libs/x86_64/libflutter.so';
    try {
      if (fs.accessSync(x86LibPath)) {
        arch = 'x86_64';
      }
    } catch (e) {
      // x86_64 libflutter.so 不存在，默认使用 arm64
    }
    let nativeLibraryDir = context.bundleCodeDir + '/libs/' + arch;
    let applicationInfo =
      new FlutterApplicationInfo(null, null, null, null, null, nativeLibraryDir, true);
    return applicationInfo
  }
}