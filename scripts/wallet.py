import argparse
from common import Config
from common.db_utils import open_db, setup_commands, Print, DBPrint

def setup_transactions(parser):
    trans_cmd = parser.add_parser('transactions')
    trans_cmd.set_defaults(func=execute_transactions)

    trans_cmd.add_argument('--asc', default=False, action='store_true')
    trans_cmd.add_argument('--sorted-by', default='timestamp')
    trans_cmd.add_argument('--limit', default=10, type=int)

def execute_transactions(db, args, printer):
    db_print = DBPrint(db, printer)
    db_print.print_table('transfers', args.limit)

def main():
    parser = argparse.ArgumentParser()

    Config.initParserWithConfigOptions(parser)
    Print.setupCmdLine(parser)

    subparsers = parser.add_subparsers()

    setup_transactions(subparsers)
    setup_commands(subparsers)

    args = parser.parse_args()

    config = Config(args)
    config.try_load_settings_or_request_user()
    config.try_save_to_settings()

    db = open_db(config.database_path, config.password_hash, config.selectedAccount.kdfIterations, config.verbose)

    printer = Print(args=args)

    if hasattr(args, 'func'):
        args.func(db, args, printer)
    else:
        print("No command specified, exiting.")
        print()

        parser.print_help()
        exit(1)

if __name__ == "__main__":
    main()
