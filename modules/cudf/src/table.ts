// Copyright (c) 2020, NVIDIA CORPORATION.
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

import CUDF from './addon';
import { Column } from './column';
import { ColumnAccessor } from './column_accessor';

interface TableConstructor {
    readonly prototype: CUDFTable;
    new(props: {
        columns?: ReadonlyArray<Column> | null
    }): CUDFTable;
}

interface CUDFTable {

    [index: number]: any;

    readonly numColumns: number;
    readonly numRows: number;
    columns: ReadonlyArray<string> | null;
    _data: ColumnAccessor;
    
    getColumn(index: number): Column;
    select(columns: ReadonlyArray<number> | ReadonlyArray<string> | null): CUDFTable;
    slice(start: number | string, end: number | string): CUDFTable;
}

export class Table extends (<TableConstructor> CUDF.Table) {
    constructor(props: {
        data?: ColumnAccessor,
    })
    {   
        if(!(props.data instanceof ColumnAccessor)){
            props.data = new ColumnAccessor(new Map(Object.entries(typeof props.data === 'object' ? props.data || {} : {})));
        }
        super({columns: props.data.columns});
        this._data = props.data;
        //column names array
        this.columns = this._data.names;
    }

    select(columns: Array<number> | Array<string>): CUDFTable{
        const column_indices: Array<number | undefined> =  (columns as any[]).map((value) => {
            return this.transformInputLabel(value);
        });
        
        const column_accessor = this._data.selectByColumnIndices(column_indices);
        return new Table({data:column_accessor});
        
    }

    slice(start: number | string, end: number | string): CUDFTable{
        return new Table({
            data: this._data.sliceByColumnIndices(
                this.transformInputLabel(start),
                this.transformInputLabel(end)
            )
        });
    }

    private transformInputLabel(label: number | string): number | undefined{
        if(typeof label == "string" && this.columns?.includes(label)){
            return this._data.columnNameToColumnIndex(label)
        }
        return label as number | undefined;
    }
    
}

Object.setPrototypeOf(CUDF.Table.prototype, new Proxy({}, {
    get(target: {}, p: any, table: any) {
        let i: string = p;
        switch (typeof p) {
            // @ts-ignore
            case 'string':
                if (table.columns.includes(i)) {
                    let column_index: number = table.columns.indexOf(i);
                    return table.getColumn(column_index);
                }
                break;
        }
        return Reflect.get(target, p, table);
    }
}));
