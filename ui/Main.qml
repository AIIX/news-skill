import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Mycroft.ScrollableDelegate {
    id: root
    visible: true
    property var newsData
    property var newsmodel: newsData.articles
    graceTime: 80000
    backgroundImage: "https://source.unsplash.com/1920x1080/?+gloomy"
    backgroundDim: 0.8
    
    Kirigami.CardsGridView {
        id: newsListView
        model: newsmodel
        
        minimumColumnWidth: Kirigami.Units.gridUnit * 25
        maximumColumnWidth: Kirigami.Units.gridUnit * 35
        cellHeight: contentItem.children[0].implicitHeight + Kirigami.Units.gridUnit
        
        delegate: Kirigami.AbstractCard{
            id: cardNewsItem
            showClickFeedback: true
            implicitHeight: delegateItem.implicitHeight + Kirigami.Units.largeSpacing * 3
            contentItem: Item {
                implicitWidth: parent.implicitWidth
                implicitHeight: parent.implicitHeight
            ColumnLayout {
                id: delegateItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: Kirigami.Units.smallSpacing

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
                        if(source == ""){
                            source = "https://www.890kdxu.com/wp-content/uploads/2017/05/News_placeholder-image.jpg"
                        }
                    }
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    Component.onCompleted: {
                        if(modelData.content == ""){
                            text = modelData.title;
                        }
                        else {
                            text = modelData.content.substr(0, modelData.content.lastIndexOf("["));
                            }
                        }
                    }
                }
            }
            onClicked: console.log("Card clicked")
        }
    }
}
 
