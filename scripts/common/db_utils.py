import sqlcipher3

import binascii
from prettytable import PrettyTable
from typing import List, Union


def open_db(file_path, passwordHash: str, kdfIterations: int, verbose: bool):
    db = sqlcipher3.connect(file_path)
    pageSize = 8192 if file_path.endswith("-v4.db") else 1024

    if verbose:
        print(f'> Opening database. Selected cipher_page_size: {pageSize}')

    db.execute(f'PRAGMA key = "{passwordHash}"')
    db.execute(f'PRAGMA cipher_page_size = {pageSize}') #1024 for older db, 8192 for newer
    db.execute(f'PRAGMA kdf_iter = {kdfIterations}')
    db.execute('PRAGMA cipher_hmac_algorithm = HMAC_SHA1')
    db.execute('PRAGMA cipher_kdf_algorithm = PBKDF2_HMAC_SHA1')
    # db.execute('PRAGMA cipher_compatibility = 3;')

    return db

class Print:
    @staticmethod
    def setupCmdLine(parser):
        parser.add_argument('--max-table-width', default=100)

    def __init__(self, max_width: int = 50, elide_width: int = 10, max_table_width: int = 100, args = None):
        self.max_width = max_width
        self.elide_width = elide_width
        self.max_table_width = max_table_width

        if args is not None:
            self.max_table_width = int(args.max_table_width)

    def print_table(self, column_names: List[str], rows: List[List[Union[str, int, float]]]):
        table = PrettyTable(field_names = column_names, max_width = self.max_width, max_table_width = self.max_table_width)

        for row in rows:
            table.add_row(row)

        print(table)

class DBPrint:
    def __init__(self, db, printer: Print):
        self.db = db
        self.printer = printer

    def get_table_info(self, table_name: str) -> List[List[Union[str, int]]]:
        cursor = self.db.execute(f"PRAGMA table_info({table_name})")
        return cursor.fetchall()

    def print_table(self, table_name: str, max_rows: int = 100):
        column_names = [row[1] for row in self.get_table_info(table_name)]
        cursor = self.db.execute(f'SELECT {",".join(column_names)} FROM {table_name} LIMIT {max_rows}')
        rows = self.get_printable_rows(cursor)
        self.printer.print_table(column_names, rows)

    def print_table_info(self, table_name: str):
        table_info = self.get_table_info(table_name)
        column_names = ["cid", "name", "type", "notnull", "dflt_value", "pk"]
        self.printer.print_table(column_names, table_info)

    def get_printable_rows(self, cursor) -> List[List[Union[str, int, float]]]:
        rows = []
        for raw_row in cursor.fetchall():
            row = []
            for val in raw_row:
                if isinstance(val, bytes):
                    val = binascii.hexlify(val).decode('utf-8')
                if isinstance(val, str) and len(val) > self.printer.elide_width:
                    val = val[:self.printer.elide_width // 2] + "..." + val[-self.printer.elide_width // 2:]
                row.append(val)
            rows.append(row)
        return rows


def table_info(db, args, printer: Print):
    db_print = DBPrint(db, printer)
    db_print.print_table_info(args.table_name)

def table_content(db, args, printer: Print):
    db_print = DBPrint(db, printer)
    db_print.print_table(args.table_name)

def setup_commands(parser):
    cmd = parser.add_parser('table-info')
    cmd.set_defaults(func=table_info)
    cmd.add_argument('--table-name', default='sqlite_master')
    cmd = parser.add_parser('table-content')
    cmd.set_defaults(func=table_content)
    cmd.add_argument('--table-name', default='sqlite_master')

