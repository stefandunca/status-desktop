import sys, os, re
import sqlcipher3
from getpass import getpass
import json
import appdirs
import argparse

from . import PasswordFunctions, Account

class Config:
    @staticmethod
    def initParserWithConfigOptions(parser: argparse.ArgumentParser):
        parser.add_argument('data_folder', help="The path to the data folder in the user data directory. e.g. ~/status-desktop/Status/data", nargs='?')

        parser.add_argument('--store-sensitive-useless-credentials-i-provide', action='store_true', default=None)
        parser.add_argument('--ask-for-config', action='store_true', default=None)
        parser.add_argument('--account_index', type=int, default=None, help='The account index to use.')
        parser.add_argument('--password', type=str, default=None, help='The password to use.')
        parser.add_argument('--verbose', type=bool, default=False, help='Show configuration details.')

    def print(self, *args, **kwargs):
        if self.verbose:
            print(*args, **kwargs)

    def __init__(self, args):
        self.storeSensitiveUselessData = args.store_sensitive_useless_credentials_i_provide
        self.data_folder = args.data_folder
        self.account_index = args.account_index
        self.password = args.password
        self.ask_for_config = args.ask_for_config
        self.verbose = args.verbose

    def input_base_path(self):
        if self.data_folder is not None:
            self.base_path = self.data_folder
        else:
            self.base_path = input('> Input a base path: ')
        if not self.base_path.endswith('/'):
            self.base_path += '/'

    def read_accounts(self):
        db = sqlcipher3.connect(self.base_path + '/accounts.sql')
        accounts = db.execute('SELECT name, keyUid, kdfIterations FROM accounts').fetchall()
        db.close()

        if len(accounts) == 0:
            print("no accounts found")
            exit(0)

        self.accounts = []
        self.print(f'> Accounts found: ')
        for i, a in enumerate(accounts):
            account = Account(a[0], a[1], a[2])
            self.accounts.append(account)
            self.print(f'{i}: {str(account)}')

    def find_database(self):
        regex = re.compile(f'{self.selectedAccount.keyUid}(\-v4)?.db$')
        for _, _, files in os.walk(self.base_path):
            for file in files:
                if regex.match(file):
                    return file
        return ''

    def select_account(self):
        if self.account_index is None:
            self.account_index = int(input('> Select an account by index: '))
        self.selectedAccount = self.accounts[self.account_index]
        self.database_path = self.base_path + self.find_database()
        self.print(f'selected database: {self.database_path}')

    def input_password(self):
        if self.password is None:
            self.password = getpass("> Input password: ")
        self.password_hash = PasswordFunctions.hash_password(self.password, old_desktop=False)

    def try_load_settings_or_request_user(self):
        filepath = self.get_settings_file()
        if os.path.isfile(filepath) and (self.ask_for_config is None or not self.ask_for_config):
            self.print(f'> Loaded settings from file "{filepath}"; (use --ask-for-config to override)')
            self.load_from_settings()
        else:
            self.verbose = True
            self.input_base_path()
            self.read_accounts()
            self.select_account()
            self.input_password()

    def get_config_path(self, filename):
        dir = appdirs.user_config_dir("DevTools", "Developer")
        return os.path.join(dir, filename)

    def get_settings_file(self):
        return self.get_config_path("sensitive_useless_info.json")

    def try_save_to_settings(self):
        if self.storeSensitiveUselessData:
            filepath = self.get_settings_file()
            data = {
                "base_path": self.base_path,
                "account_index": self.account_index,
                "password_hash": self.password_hash,
            }
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            with open(filepath, 'w') as f:
                json.dump(data, f)

    def load_from_settings(self):
        filepath = self.get_settings_file()
        with open(filepath, 'r') as f:
            data = json.load(f)
        self.base_path = data.get("base_path", "")
        self.account_index = data.get("account_index", 0)
        self.password_hash = data.get("password_hash", "")

        self.read_accounts()
        self.select_account()
