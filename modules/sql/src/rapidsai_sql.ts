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

import {DataFrame, Table} from '@rapidsai/cudf';
import {ParsedSchema} from './SQLTable';
import type {defaultContextConfigValues} from './config';

/** @ignore */
export declare const _cpp_exports: any;

export declare function getTableScanInfo(logicalPlan: string): [string[], string[]];

export declare function runGeneratePhysicalGraph(
  workerIds: string[], ctxToken: number, query: string): string;

export declare function parseSchema(input: string[], fileType: 'csv'|'orc'|'parquet'): ParsedSchema;

export type WorkerUcpInfo = {
  id: number;    //
  ip: string;    //
  port: number;  //
}

export type ContextProps = {
  id: number;                //
  port: number;              //
  ucpContext?: UcpContext;   //
  networkIfaceName: string;  //
  workersUcpInfo: WorkerUcpInfo[];
  configOptions: typeof defaultContextConfigValues;
  allocationMode: string;
  initialPoolSize: number | null;
  maximumPoolSize: number | null;
  enableLogging: boolean;
};

export declare class Context {
  constructor(props: ContextProps);

  public readonly id: number;

  broadcast(ctxToken: number, df: DataFrame): string[];
  pull(messageId: string): Promise<{names: string[], tables: Table[]}>;
  send(id: number, ctxToken: number, messageId: string, df: DataFrame): void;
  runGenerateGraph(dataframes: DataFrame[],
                   schemas: Record<string, unknown>[],
                   tableNames: string[],
                   tableScans: string[],
                   ctxToken: number,
                   query: string,
                   configOptions: Record<string, unknown>,
                   sql: string,
                   currentTimestamp: string): ExecutionGraph;
}

export declare class ExecutionGraph {
  constructor();

  start(): void;
  result(): Promise<{names: string[], tables: Table[]}>;
  sendTo(id: number, df: DataFrame[], nonce: string): string[];
}

export declare class UcpContext {
  constructor();
}
