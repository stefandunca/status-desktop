import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule
    // Since qml component doesn't follow encaptulation from the backend side, we're introducing
    // a method which will return appropriate chat content module for selected chat/channel
    function currentChatContentModule(){
        // When we decide to have the same struct as it's on the backend we will remove this function.
        // So far this is a way to deal with refactord backend from the current qml structure.
        if(chatCommunitySectionModule.activeItem.isSubItemActive)
            chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.activeSubItem.id)
        else
            chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.id)

        return chatCommunitySectionModule.getChatContentModule()
    }


    // Contact requests related part
    property var contactRequestsModel: chatCommunitySectionModule.contactRequestsModel

    function acceptContactRequest(pubKey) {
        chatCommunitySectionModule.acceptContactRequest(pubKey)
    }

    function acceptAllContactRequests() {
        chatCommunitySectionModule.acceptAllContactRequests()
    }

    function rejectContactRequest(pubKey) {
        chatCommunitySectionModule.rejectContactRequest(pubKey)
    }

    function rejectAllContactRequests() {
        chatCommunitySectionModule.rejectAllContactRequests()
    }

    function blockContact(pubKey) {
        chatCommunitySectionModule.blockContact(pubKey)
    }


    property var messageStore
    property var emojiReactionsModel

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var utilsModelInst: utilsModel
    // Not Refactored Yet
//    property var walletModelInst: walletModel
    // Not Refactored Yet
//    property var profileModelInst: profileModel
    property var mainModuleInst: mainModule
    property var activityCenterModuleInst: activityCenterModule
    property var activityCenterList: activityCenterModuleInst.model

    property var communitiesModuleInst: communitiesModule
    property var communitiesList: communitiesModuleInst.model

    property var userProfileInst: userProfile

    property bool isDebugEnabled: profileSectionModule.isDebugEnabled

    property var accounts: walletSectionAccounts.model
    property var currentAccount: walletSectionCurrent
    property var currentCurrency: walletSection.currentCurrency

    property ListModel addToGroupContacts: ListModel {}

    function reCalculateAddToGroupContacts(channel) {
        const contacts = getContactListObject()

        if (channel) {
            contacts.forEach(function (contact) {
                if(channel.contains(contact.pubKey) ||
                        !contact.isContact) {
                    return;
                }
                addToGroupContacts.append(contact)
            })
        }
    }

    property var stickersModuleInst: stickersModule

    // Not Refactored Yet
//    property var activeCommunity: chatsModelInst.communities.activeCommunity



    function sendSticker(channelId, hash, replyTo, pack) {
        stickersModuleInst.send(channelId, hash, replyTo, pack)
    }

    function copyToClipboard(text) {
        // Not Refactored Yet
//        chatsModelInst.copyToClipboard(text);
    }

    function deleteMessage(messageId) {
        // Not Refactored Yet
//        chatsModelInst.messageView.deleteMessage(messageId);
    }

    function getCommunity(communityId) {
        // Not Refactored Yet
//        try {
//            const communityJson = chatsModelInst.communities.list.getCommunityByIdJson(communityId);
//            if (!communityJson) {
//                return null;
//            }

//            let community = JSON.parse(communityJson);
//            if (community) {
//                community.nbMembers = community.members.length;
//            }
//            return community
//        } catch (e) {
//            console.error("Error parsing community", e);
//        }

       return null;
    }

    // Not Refactored Yet
    property var activeCommunityChatsModel: "" //chatsModelInst.communities.activeCommunity.chats

    function createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        communitiesModuleInst.createCommunity(communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY) {
        communitiesModuleInst.editCommunity(communityId, communityName, communityDescription, checkedMembership, ensOnlySwitchChecked, communityColor, communityImage, imageCropperModalaX, imageCropperModalaY, imageCropperModalbX, imageCropperModalbY);
    }

    function createCommunityCategory(communityId, categoryName, channels) {
        // Not Refactored Yet
//        chatsModelInst.communities.createCommunityCategory(communityId, categoryName, channels);
    }

    function editCommunityCategory(communityId, categoryId, categoryName, channels) {
        // Not Refactored Yet
//        chatsModelInst.communities.editCommunityCategory(communityId, categoryId, categoryName, channels);
    }

    function deleteCommunityCategory(categoryId) {
        // Not Refactored Yet
//        chatsModelInst.communities.deleteCommunityCategory(chatsModelInst.communities.activeCommunity.id, categoryId);
    }

    function leaveCommunity(communityId) {
        // Not Refactored Yet
//        chatsModelInst.communities.leaveCommunity(communityId);
    }

    function setCommunityMuted(communityId, checked) {
        // Not Refactored Yet
//        chatsModelInst.communities.setCommunityMuted(communityId, checked);
    }

    function exportCommunity() {
        // Not Refactored Yet
//        return chatsModelInst.communities.exportCommunity();
    }

    function createCommunityChannel(communityId, channelName, channelDescription) {
       communitiesModuleInst.createCommunityChannel(communityId, channelName, channelDescription);
    }

    function editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition) {
        // TODO: pass the private value when private channels
        // are implemented
        //privateSwitch.checked)
        // Not Refactored Yet
//        chatsModelInst.editCommunityChannel(communityId, channelId, channelName, channelDescription, channelCategoryId, popupPosition);
    }

    function acceptRequestToJoinCommunity(id) {
        // Not Refactored Yet
//        chatsModelInst.communities.acceptRequestToJoinCommunity(id);
    }

    function declineRequestToJoinCommunity(id) {
        // Not Refactored Yet
//        chatsModelInst.communities.declineRequestToJoinCommunity(id);
    }

    function userNameOrAlias(pk) {
        // Not Refactored Yet
//        return chatsModelInst.userNameOrAlias(pk);
    }

    function generateIdenticon(pk) {
        // Not Refactored Yet
//        return utilsModelInst.generateIdenticon(pk);
    }
}
