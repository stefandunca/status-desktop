#include "SystemControl.h"

#include <QWheelEvent>
#include <QCoreApplication>
#include <QQuickItem>

SystemControl::SystemControl()
{

}

void SystemControl::startSimulateMacOSTrackpadScrollEvent(QQuickItem* item, int x, int y)
{
    Qt::ScrollPhase phase = Qt::ScrollBegin;
    auto wheelEvent = new QWheelEvent(QPointF(x, y), item->mapToGlobal(QPointF(x, y)),
                                      QPoint(), QPoint(), Qt::NoButton, Qt::NoModifier, phase, false);
    QCoreApplication::postEvent(item, wheelEvent);
}

void SystemControl::simulateMacOSTrackpadScrollEvent(QQuickItem* item, int x, int y, int xDelta, int yDelta)
{
    //QInputDevice("Simulated trackpad", 11, QInputDevice::DeviceType::TouchPad, )

    Qt::ScrollPhase phase = Qt::ScrollUpdate;
    auto wheelEvent = new QWheelEvent(QPointF(x, y), item->mapToGlobal(QPointF(x, y)),
                                      QPoint(xDelta, yDelta), QPoint(), Qt::NoButton, Qt::NoModifier, phase, false);
    QCoreApplication::postEvent(item, wheelEvent);
}

void SystemControl::endSimulateMacOSTrackpadScrollEvent(QQuickItem* item, int x, int y)
{
    Qt::ScrollPhase phase = Qt::ScrollEnd;
    auto wheelEvent = new QWheelEvent(QPointF(x, y), item->mapToGlobal(QPointF(x, y)),
                                      QPoint(), QPoint(), Qt::NoButton, Qt::NoModifier, phase, false);
    QCoreApplication::postEvent(item, wheelEvent);
}
