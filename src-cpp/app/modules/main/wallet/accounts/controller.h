#ifndef WALLET_ACCOUNT_CONTROLLER_H
#define WALLET_ACCOUNT_CONTROLLER_H

#include <QObject>

#include "wallet_accounts/wallet_account.h"
#include "wallet_accounts/service_interface.h"
#include "interfaces/controller_interface.h"
#include "signals.h"

namespace Modules::Main::Wallet::Accounts
{
class Controller : public QObject, IController
{
    Q_OBJECT

public:
    explicit Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);
    ~Controller() = default;

    void init() override;

    QList<Wallets::WalletAccountDto> getWalletAccounts();

private:
    std::shared_ptr<Wallets::ServiceInterface> m_walletServicePtr;
};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_CONTROLLER_H
