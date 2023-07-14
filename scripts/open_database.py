from common import Config
from common.db_utils import open_db, setup_commands, Print
import argparse

parser = argparse.ArgumentParser()

Config.initParserWithConfigOptions(parser)
Print.setupCmdLine(parser)

subparsers = parser.add_subparsers()

setup_commands(subparsers)

args = parser.parse_args()

config = Config(args)
config.try_load_settings_or_request_user()
config.try_save_to_settings()

## Select and open database

db = open_db(config.database_path, config.password_hash, config.selectedAccount.kdfIterations, config.verbose)

## use the `db` instance to execute queries

tables = db.execute("SELECT name FROM sqlite_master WHERE type='table';").fetchall()
print(f"> Database opened. {len(tables)} tables found.")

printer = Print(args=args)

if hasattr(args, 'func'):
    args.func(db, args, printer)
    exit(0)

## loop sql operations

while True:
    cmd = input("SQL> ")
    if cmd == "exit":
        break
    output = db.execute(cmd).fetchall()
    print(output)

db.close()
