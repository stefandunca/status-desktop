import allure
import pytest
from allure_commons._allure import step

import driver
from gui.components.signing_phrase_popup import SigningPhrasePopup
from gui.components.wallet.authenticate_popup import AuthenticatePopup
from gui.main_window import MainWindow
from scripts.tools import image


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/view/703415',
                 'Account order: account order could be changed with drag&drop')
@pytest.mark.case(703415)
@pytest.mark.parametrize('address, default_name, name, color, emoji, second_name, second_color, second_emoji', [
    pytest.param('0xea123F7beFF45E3C9fdF54B324c29DBdA14a639A', 'Status account',
                 'WatchOnly', '#2a4af5', 'sunglasses', 'Generated', '#216266', 'thumbsup')
])
@pytest.mark.skip(reaason="https://github.com/status-im/desktop-qa-automation/issues/165")
def test_change_account_order_by_drag_and_drop(main_screen: MainWindow, user_account, address: str, default_name,
                                               name: str, color: str, emoji: str, second_name: str, second_color: str,
                                               second_emoji: str):
    with step('Create watch-only wallet account'):
        wallet = main_screen.left_panel.open_wallet()
        SigningPhrasePopup().wait_until_appears().confirm_phrase()
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(name).set_emoji(emoji).set_color(color).set_origin_eth_address(address).save()
        account_popup.wait_until_hidden()

    with step('Create generated wallet account'):
        account_popup = wallet.left_panel.open_add_account_popup()
        account_popup.set_name(second_name).set_emoji(second_emoji).set_color(second_color).save()
        AuthenticatePopup().wait_until_appears().authenticate(user_account.password)
        account_popup.wait_until_hidden()

    with step('Verify accounts in wallet settings'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        with step('Account order is correct'):
            assert account_order.accounts[0].name == default_name
            assert account_order.accounts[1].name == name
            assert account_order.accounts[2].name == second_name
        with step('Eye icon is displayed on watch-only account'):
            account_order.get_eye_icon(name)
        with step('Icons on accounts are correct'):
            image.compare(account_order.accounts[1].icon, 'watch_only_account_icon.png')
            image.compare(account_order.accounts[2].icon, 'generated_account_icon.png')

    with step('Drag first account to the end of the list'):
        account_order.drag_account(default_name, 2)

    with step('Verify the account order'):
        with step('Account order is correct in wallet settings'):
            assert driver.waitFor(lambda: account_order.accounts[0].name == name)
            assert driver.waitFor(lambda: account_order.accounts[1].name == second_name)
            assert driver.waitFor(lambda: account_order.accounts[2].name == default_name)
        with step('Account order is correct in wallet'):
            wallet = main_screen.left_panel.open_wallet()
            assert driver.waitFor(lambda: wallet.left_panel.accounts[0].name == name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[1].name == second_name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[2].name == default_name)

    with step('Drag second account to the top of the list'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()
        account_order.drag_account(second_name, 0)

    with step('Verify the account order'):
        with step('Account order is correct in wallet settings'):
            assert driver.waitFor(lambda: account_order.accounts[0].name == second_name)
            assert driver.waitFor(lambda: account_order.accounts[1].name == name)
            assert driver.waitFor(lambda: account_order.accounts[2].name == default_name)
        with step('Account order is correct in wallet'):
            wallet = main_screen.left_panel.open_wallet()
            assert driver.waitFor(lambda: wallet.left_panel.accounts[0].name == second_name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[1].name == name)
            assert driver.waitFor(lambda: wallet.left_panel.accounts[2].name == default_name)


@allure.testcase('https://ethstatus.testrail.net/index.php?/cases/edit/703416',
                 'Account order: reordering is not possible having a single account')
@pytest.mark.case(703416)
@pytest.mark.parametrize('default_name, text_on_top', [
    pytest.param('Status account', 'This account looks a little lonely. Add another account'
                                   ' to enable re-ordering.')
])
def test_change_account_order_not_possible(main_screen: MainWindow, default_name: str, text_on_top: str):
    with step('Open edit account order view'):
        account_order = main_screen.left_panel.open_settings().left_panel.open_wallet_settings().open_account_order()

    with step('Verify that only default account displayed'):
        assert len(account_order.accounts) == 1
        assert account_order.accounts[0].name == default_name

    with step('Back button is present and text on top is correct'):
        assert account_order.account_recommendations[0] == text_on_top
        assert account_order.is_back_button_present() is True
