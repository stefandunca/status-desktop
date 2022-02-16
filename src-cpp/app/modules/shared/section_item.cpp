#include <QDebug>

#include "section_item.h"

namespace Shared::Models
{
SectionItem::SectionItem(QString id,
                         SectionType sectionType,
                         QString name,
                         QString description,
                         QString image,
                         QString icon,
                         QString color,
                         bool active,
                         bool enabled,
                         bool amISectionAdmin,
                         bool hasNotification,
                         int notificationsCount,
                         bool isMember,
                         bool joined,
                         bool canJoin,
                         bool canManageUsers,
                         bool canRequestAccess,
                         int access,
                         bool ensOnly,
                         QObject *parent):
    QObject(parent),
    m_id(id),
    m_sectionType(sectionType) ,
    m_name(name),
    m_amISectionAdmin(amISectionAdmin),
    m_description(description),
    m_image(image),
    m_icon(icon),
    m_color(color),
    m_hasNotification(hasNotification),
    m_notificationsCount(notificationsCount),
    m_active(active),
    m_enabled(enabled),
    m_isMember(isMember),
    m_joined(joined),
    m_canJoin(canJoin),
    m_canManageUsers(canManageUsers),
    m_canRequestAccess(canRequestAccess),
    m_access(access),
    m_ensOnly(ensOnly)
{
}

SectionType SectionItem::getSectionType()
{
    return m_sectionType;
}

QString SectionItem::getId()
{
    return m_id;
}

QString SectionItem::getName()
{
    return m_name;
}

bool SectionItem::getAmISectionAdmin()
{
    return m_amISectionAdmin;
}

QString SectionItem::getDescription()
{
    return m_description;
}

QString SectionItem::getImage()
{
    return m_image;
}

QString SectionItem::getIcon()
{
    return m_icon;
}

QString SectionItem::getColor()
{
    return m_color;
}

bool SectionItem::getHasNotification()
{
    return m_hasNotification;
}

int SectionItem::getNotificationsCount()
{
    return m_notificationsCount;
}

bool SectionItem::getIsActive()
{
    return m_active;
}

bool SectionItem::getIsEnabled()
{
    return m_enabled;
}

bool SectionItem::getIsMember()
{
    return m_isMember;
}

bool SectionItem::getHasJoined()
{
    return m_joined;
}

bool SectionItem::getCanJoin()
{
    return m_canJoin;
}

bool SectionItem::getCanManageUsers()
{
    return m_canManageUsers;
}

bool SectionItem::getCanRequestAccess()
{
    return m_canRequestAccess;
}

int SectionItem::getAccess()
{
    return m_access;
}

bool SectionItem::getIsEnsOnly()
{
    return m_ensOnly;
}

void SectionItem::setIsActive(bool isActive)
{
    if(m_active != isActive)
    {
        m_active = isActive;
        activeChanged();
    }
}

} // namespace Shared::Models
