#pragma once

#include <QtCore>

namespace Status::Keychain
{
    class LocalAuthentication : public QObject
    {
        Q_OBJECT

    public:

        enum Error {
            Domain=0,
            AppCanceled,
            SystemCanceled,
            UserCanceled,
            TouchIdNotAvailable,
            TouchIdNotConfigured,
            WrongCredentials,
            OtherError
        };

        void runAuthentication(const QString& authenticationReason);

    signals:
        void success();
        void error(int error, const QString& errorString);
    };
}
