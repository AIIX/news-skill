import re
import sys
import json
import requests
import time
from os.path import dirname, join
from bs4 import BeautifulSoup
from adapt.intent import IntentBuilder
from mycroft import MycroftSkill, intent_handler, intent_file_handler
from mycroft.messagebus.message import Message 

newsItemList = []
newsItemObject = {}

class NewsSkill(MycroftSkill):
    """ 
    News Skill
    """
    @intent_file_handler('show.news.ideal.screen.intent')
    def handle_show_news_ideal_screen_intent(self, message):
        """ 
        News Ideal Screen Test Intent
        """
        getNewsLang = self.lang.split("-")
        newsLang = getNewsLang[1]
        newsAPIURL = 'https://newsapi.org/v2/top-headlines?country=in&apiKey=a1091945307b434493258f3dd6f36698'.format(newsLang)
        newsAPIRespone = requests.get(newsAPIURL)
        newsItems = newsAPIRespone.json()
        self.enclosure.bus.emit(Message("metadata", {"type": "news-skill/resting", "newsData": newsItems}))
        
    @intent_file_handler('get.latest.news.intent')
    def handle_get_latest_news_intent(self, message):
        """ 
        Get News and Read Title
        """
        global newsItemList
        global newsItemObject
        getNewsLang = self.lang.split("-")
        newsLang = getNewsLang[1]
        newsAPIURL = 'https://newsapi.org/v2/top-headlines?country=in&apiKey=a1091945307b434493258f3dd6f36698'.format(newsLang)
        newsAPIRespone = requests.get(newsAPIURL)
        newsItems = newsAPIRespone.json()
        self.speak("Today's top news items")
        self.enclosure.bus.emit(Message("metadata", {"type": "news-skill", "newsData": newsItems}))
        for x in newsItems['articles']:
            newsSource = x['source']['name']
            newsTitle = x['title']
            newsAuthor = x['author']
            newsDesc = x['content']
            newsItemList.append({"title": newsTitle, "content": newsDesc})
            newsItemObject['articles'] = newsItemList
            newsSpeakResultIntro = "News From {0} Reported By {1}".format(newsSource, newsAuthor)
            self.speak(newsSpeakResultIntro)
            time.sleep(1)
            self.speak(newsTitle)

    @intent_file_handler('read.news.from.title.intent')
    def handle_read_news_from_title(self, message):
        """ 
        Read News Description
        """
        utterance = message.data['title']
        titleRank = self.rank_title(utterance)
        if len(titleRank) < 1: 
            self.speak('Sorry no news item found')
        elif len(titleRank) > 1:
            self.speak('Found multiple news items, please select an news item number you would like me to read', expect_response=True)
            #self.handle_multiple_news_items(titleRank)
        else:
            self.speak(titleRank[0]['content'])
        
    def rank_title(self, utterance):
        split_words = utterance.lower().split()
        
        global newsItemObject
        search_result = newsItemObject['articles']
        found_titles = []
        for article in search_result:
            rank = 0
            split_title = article['title'].lower().split()
            for words in split_words:
                for title_words in split_title: 
                    if words == title_words: 
                        rank += 1
                        break
            article['rank'] = rank
            if (rank > 1):
                if len(found_titles) > 0: 
                    for p in found_titles:
                        if article['rank'] > p['rank']:
                            if article not in found_titles: 
                                found_titles = []
                                found_titles.append(article)
                                break
                        elif article['rank'] == p['rank']:
                            if article not in found_titles: 
                                found_titles.append(article)
                else: 
                    found_titles.append(article)

        return found_titles 
        
    def stop(self):
        pass


def create_skill():
    return NewsSkill()

