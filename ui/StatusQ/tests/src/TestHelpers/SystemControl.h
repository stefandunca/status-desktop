#pragma once

#include <QObject>

class QQuickItem;

class SystemControl: public QObject
{
    Q_OBJECT
public:
    SystemControl();

    Q_INVOKABLE void startSimulateMacOSTrackpadScrollEvent(QQuickItem* item, int x, int y);
    Q_INVOKABLE void simulateMacOSTrackpadScrollEvent(QQuickItem* item, int x, int y, int xDelta, int yDelta);
    Q_INVOKABLE void endSimulateMacOSTrackpadScrollEvent(QQuickItem* item, int x, int y);
};
