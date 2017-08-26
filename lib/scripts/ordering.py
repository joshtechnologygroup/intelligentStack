import requests
import pandas, json, collections, psycopg2
import argparse
from sqlalchemy import create_engine

parser = argparse.ArgumentParser()
parser.add_argument('--tab', '-t', type=str, required=True)
args = parser.parse_args()

url= 'https://api.stackexchange.com/2.2/questions?order=desc&sort=activity&site=stackoverflow&filter=!LaSRLvLv*sr67dzbv7FXGk&access_token=0bwAYzM3ae4ZzQs1o5R73Q))&key=*aiCyheCAqPgs8YUmUVEzA((&page=page_no&tagged={0}'.format(args.tab)
engine = create_engine('postgresql://postgres:qwertyuiop@localhost:5432/rampup')
for i in range(1):
    response = requests.get(url.replace('page_no', str(i+1)), headers={"content-type":"json"})
    df = pandas.read_json(response.content)
    c = 0
    for row in df['items']:
        c = c+1
        df1 = pandas.io.json.json_normalize(row)
        l1=[]
        try:
            for r1 in df1['answers']:
                l1.append(json.dumps(r1))
            df1['answers'] = l1
        except Exception:
            pass
        df1.to_sql('tagged_questions', engine,  if_exists='append')
database = psycopg2.connect(
    database='rampup', user='postgres', password='qwertyuiop',
    host='localhost', port='5432'
)

cursor = database.cursor()
cursor.execute("SELECT * from tagged_questions where tags like '%{0}%' and accepted_answer_id is NULL and answers is NOT NULL;")
df = pandas.DataFrame(cursor.fetchall())
for xt in df.iterrows():
    seq = [y['score'] for y in eval(xt[1][34].replace('false', 'False'))]
    cursor.execute('UPDATE tagged_questions SET max_score={0} where question_id={1}'.format(max(seq), xt[1][14]))
cursor.execute("""
DELETE FROM questions where question_id in (select question_id from tagged_questions);
INSERT INTO questions select * from tagged_questions;
""")
database.commit()

