import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Mycroft.DelegateBase {
    id: root
    visible: true
    property var newsData
    property var newsmodel: newsData.articles
    graceTime: Infinity
    backgroundImage: "https://source.unsplash.com/1920x1080/?+gloomy"
    backgroundDim: 0.8
    
    controlBar: Control {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        padding: Kirigami.Units.largeSpacing

        background: LinearGradient {
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "black" }
            }
        }
        contentItem: PageIndicator {
            id: slideShowIndicator
            anchors.centerIn: parent
            currentIndex: newsSwipeView.currentIndex
            count: newsSwipeView.count
            delegate: Rectangle {
                implicitWidth: Kirigami.Units.gridUnit * 0.3
                implicitHeight: Kirigami.Units.gridUnit * 0.3
                radius: width / 2
                color: Kirigami.Theme.textColor
                opacity: index === slideShowIndicator.currentIndex ? 0.65 : pressed ? 0.7 : 0.45
                Behavior on opacity {
                    OpacityAnimator {
                        duration: 100
                    }
                }
            }
        }
    }
    
    Timer {
        id: slideShowTimer
        interval: 5000
        running: false
        repeat: true
        onTriggered: {
            var getCount = newsSwipeView.count
            if(newsSwipeView.currentIndex !== getCount){
                newsSwipeView.currentIndex = newsSwipeView.currentIndex+1;
            }
            else{
                newsSwipeView.currentIndex = 0
            }
        }
    }

    Timer {
        id: clockTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            var date = new Date()
            timerText.text = date.toLocaleTimeString(Qt.locale("en_US"), "hh:mm:ss ap")
            timerDay.text = date.toLocaleDateString(Qt.locale("en_US"))
        }
    }

    Rectangle {
        id: rectSpace
        color: Kirigami.Theme.linkColor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Kirigami.Units.gridUnit * 4
        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 2
            Kirigami.Heading {
                id: timerText
                level: 1
                wrapMode: Text.WordWrap
                font.weight: Font.ExtraBold
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin:  Kirigami.Units.largeSpacing
            }
            Label {
                id: timerDay
                color: Kirigami.Theme.textColor
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    ListView {
        id: newsSwipeView
        model: newsmodel
        anchors.top:  rectSpace.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        layoutDirection: Qt.LeftToRight
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem;
        flickDeceleration: 500
        focus: true
        flickableDirection: Flickable.AutoFlickDirection
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        spacing: Kirigami.Units.largeSpacing
        delegate: Kirigami.AbstractCard{
            id: cardNItem
            showClickFeedback: true
            width: newsSwipeView.width
            height: newsSwipeView.height
            contentItem: ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                Item {
                    height: root.height > Kirigami.Units.gridUnit * 20 ? Kirigami.Units.gridUnit * 0 : Kirigami.Units.gridUnit * 2
                }
                Kirigami.Heading {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    level: 3
                    text: qsTr(modelData.title)
                }
                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.height / 4
                    source: modelData.urlToImage
                    fillMode: Image.PreserveAspectCrop
                    Component.onCompleted: {
                        slideShowTimer.start()
                        if(source == ""){
                            cardNItem.visible = false
                            cardNItem.height = 0
                            cardNItem.width = 0
                        }
                    }
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    Component.onCompleted: {
                        if(modelData.content == ""){
                            cardNItem.visible = false
                            cardNItem.height = 0
                            cardNItem.width = 0
                        }
                        else {
                            text = modelData.content.substr(0, modelData.content.lastIndexOf("["));
                        }
                    }
                }
            }
            onClicked: console.log("Card clicked")
        }

        Keys.onLeftPressed: {
            if (currentIndex > 0 )
                currentIndex = currentIndex-1
            slideShowTimer.restart()
        }

        Keys.onRightPressed: {
            if (currentIndex < count)
                currentIndex = currentIndex+1
            slideShowTimer.restart()
        }

        onFlickEnded: {
            slideShowTimer.restart()
        }
    }
}
 
