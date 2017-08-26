import requests
import pandas, json, collections, psycopg2
from sqlalchemy import create_engine
url= 'https://api.stackexchange.com/2.2/questions?order=desc&sort=activity&site=stackoverflow&filter=!LaSRLvLv*sr67dzbv7FXGk&access_token=0bwAYzM3ae4ZzQs1o5R73Q))&key=*aiCyheCAqPgs8YUmUVEzA((&page=page_no&page_size=99'
engine = create_engine('postgresql://postgres:qwertyuiop@localhost:5432/rampup')
# for i in range(1000):
#     response = requests.get(url.replace('page_no', str(i+1)), headers={"content-type":"json"})
#     df = pandas.read_json(response.content)
#     c = 0
#     for row in df['items']:
#         c = c+1
#         df1 = pandas.io.json.json_normalize(row)
#         l1=[]
#         try:
#             for r1 in df1['answers']:
#                 l1.append(json.dumps(r1))
#             df1['answers'] = l1
#         except Exception:
#             pass
#         df1.to_sql('questions', engine,  if_exists='append')
database = psycopg2.connect(
    database='rampup', user='postgres', password='qwertyuiop',
    host='localhost', port='5432'
)
cursor = database.cursor()
cursor.execute("SELECT * from live_questions where tags like '%ruby%' and accepted_answer_id is NULL and answers is NOT NULL ORDER BY last_activity_date, answer_count;")
df = pandas.DataFrame(cursor.fetchall())
for xt in df.iterrows():
    print xt
    seq = [y['score'] for y in eval(xt[1][34].replace('false', 'False'))]
    print 'UPDATE live_questions SET max_score={0} where question_id={1}'.format(max(seq), xt[1][14])
    cursor.execute('UPDATE live_questions SET max_score={0} where question_id={1}'.format(max(seq), xt[1][14]))
database.commit()
# df['max_score'] = max(df['answers'], key=lambda x: x['score'])['score']
# df[35] = [y['score'] for y in eval(x.replace('false',  'False')) for x in df[34]]
#
# for row in df:
#     print row[0]
#     # row = row.replace('false', 'False')
#     # row1 = eval(row)
#     # minPricedItem = min(row1, key=lambda x: x['score'])['score']
#     # print '*'*100
#     # cursor.execute("UPDATE live_questions SET max_score={0} where question_id={1}".format(minPricedItem, row1['question_id']))
#
# cursor.commit()

