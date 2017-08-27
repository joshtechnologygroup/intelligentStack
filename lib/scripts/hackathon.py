#!/mnt/env/sqrt_python2.7/bin/python

import os
import json
import gensim
import string
import requests
import pandas
import numpy as np
from sq_sql import db_client
from gensim import corpora
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer

class TextMiner(object):

    def __init__(self):
        """
        Initializations
        """
        self.all_tags = set()
        self.user_tags=set()
        self.users_and_tags = {}
        self.stop = self.lemma = self.exclude = []
        self.db_client_obj = db_client.DBClient('dw')
        self.api_domain='https://api.stackexchange.com'
        self.all_questions_sql = """
            SELECT
              id,
              body
            FROM temphitesh_dbo.aug25_posts
            WHERE posttypeid = '1' limit 5;
        """
        self.create_user_skill_table_sql = """
            DROP TABLE IF EXISTS temphitesh_dbo.aug25;
            CREATE TABLE temphitesh_dbo.aug25(
              id text,
              tags text
            );
        """
        self.db_client_obj.RunQuery(self.create_user_skill_table_sql)


    def get_all_tags(self):
        """
        All tags in SO
        """
        params='2.2/tags?order=desc&sort=popular&site=stackoverflow&access_token=0bwAYzM3ae4ZzQs1o5R73Q))&key=*aiCyheCAqPgs8YUmUVEzA(('
        response = requests.get(os.path.join(self.api_domain, params), headers={"content-type":"json"})
        for row in response.json()['items']:
            self.all_tags.add(row['name'])

 
    def get_previous_tags(self, userId):
        """
        Collected user tags
        """
        params = '2.2/users/{}/tags?order=desc&sort=popular&site=stackoverflow&access_token=0bwAYzM3ae4ZzQs1o5R73Q))&key=*aiCyheCAqPgs8YUmUVEzA(('.format(userId)
        response = requests.get(os.path.join(self.api_domain, params))
        for row in response.json()['items']:
            self.user_tags.add(row['name'])


    def clean(self, doc):
        """
        Remove unnecessary noise from document
        """
        stop_free = " ".join([i for i in doc.lower().split() if i not in self.stop])
        punc_free = ''.join(ch for ch in stop_free if ch not in self.exclude)
        normalized = " ".join(self.lemma.lemmatize(word) for word in punc_free.split())
        return normalized


    def new_tags(self):
        """
        Update set of tags for skillset. And creates table with skills for a userid.
        """
        questions = self.db_client_obj.RunQuery(self.all_questions_sql, 'list_of_dicts')

        for question in questions:
            doc_complete = [question['body']]
            self.stop = set(stopwords.words('english'))
            self.exclude = set(string.punctuation)
            self.lemma = WordNetLemmatizer()
            doc_clean = [self.clean(doc).split() for doc in doc_complete]

            # Creating the term dictionary of our corpus, where every unique term is assigned an index.
            dictionary = corpora.Dictionary(doc_clean)

            # Converting list of documents (corpus) into Document Term Matrix using dictionary prepared above.
            doc_term_matrix = [dictionary.doc2bow(doc) for doc in doc_clean]

            # Creating the object for LDA model using gensim library
            Lda = gensim.models.ldamodel.LdaModel

            # Running and Training LDA model on the document term matrix
            ldamodel = Lda(doc_term_matrix, num_topics=3, id2word = dictionary, passes=50)
            # all matrix representations
            # print ldamodel.print_topics(2)

            list_of_list=[a.split(',') for a in doc_clean[0]]
            list_of_str= map(''.join, list_of_list)
            # print set([a for a in list_of_str if a in self.all_tags])
            v = set([a for a in list_of_str if a in self.all_tags])

            self.user_tags = v.union(self.user_tags)
            self.db_client_obj.RunQuery("""INSERT INTO temphitesh_dbo.aug25 VALUES(""" + "'%s'"%question['id'] + ' , ' + "'%s'"%(
                ', '.join(self.user_tags)) + ");")


if __name__ == "__main__":
    t=TextMiner()
    t.get_all_tags()
    t.new_tags()
