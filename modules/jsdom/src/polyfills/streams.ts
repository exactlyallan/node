// Copyright (c) 2021-2022, NVIDIA CORPORATION.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import * as jsdom from 'jsdom';

export function installStreams(window: jsdom.DOMWindow) {
  const streams                                 = require('web-streams-polyfill');
  window.jsdom.global.ReadableStream            ??= streams.ReadableStream;
  window.jsdom.global.WritableStream            ??= streams.WritableStream;
  window.jsdom.global.TransformStream           ??= streams.TransformStream;
  window.jsdom.global.CountQueuingStrategy      ??= streams.CountQueuingStrategy;
  window.jsdom.global.ByteLengthQueuingStrategy ??= streams.ByteLengthQueuingStrategy;
  return window;
}
