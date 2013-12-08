from datetime import datetime

import pygit2 as git

from flask import Flask, g, jsonify
from flask_yeoman import flask_yeoman

from pymongo import MongoClient

app = Flask(__name__)
app.register_blueprint(flask_yeoman)


client = MongoClient()
db = client.likevisu
commits = db.commits
tags = db.tags

repo = git.Repository('/home/yannick/linux')


@app.route("/commits/top_authors")
def top_authors():
    top = commits.aggregate([
        {"$match": {'merge': False}},
        {'$group': {'_id': '$author', 'count': {'$sum': 1}}},
        {'$sort': {'count': -1}},
        {'$limit': 10},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)

@app.route("/commits/by_date")
def by_date():
    query = commits.aggregate([
        {'$group': {
            '_id': {'$add': [{'$dayOfYear': '$date'}, {'$multiply': [400, {'$year': '$date'}]}]},
            'count': {'$sum': 1},
            'first': {'$min': '$date'},
        }},
    ])

    dates = {v['first'].strftime("%Y-%m-%d"): v['count'] for v in query['result']}
    return jsonify(dates)

@app.route("/commits/diffs")
def diffs():
    query = commits.aggregate([
        {'$match': {'merge': False}},
        {'$group': {
            '_id': {'$add': [{'$month': '$date'}, {'$multiply': [100, {'$year': '$date'}]}]},
            'additions': {'$sum': "$additions"},
            'deletions': {'$sum': "$deletions"},
            'first': {'$min': '$date'},
        }},
        {'$project': {'_id': 0, 'date': '$first', 'additions': 1, 'deletions': 1}},
        {'$sort': {'date': 1}},
    ])

    return jsonify(query)

def process_commits():
    size = 1000
    batch = [None] * size
    progress = 0
    count = 0

    refs = {tag['target']: tag['_id'] for tag in tags.find()}
    tag = ''

    head = repo[repo.head.target]
    for commit in repo.walk(head.oid, git.GIT_SORT_TOPOLOGICAL | git.GIT_SORT_TIME):
        if progress == size:
            count += progress
            progress = 0
            print(count)
            commits.insert(batch)

        if commit.hex in refs:
            tag = refs[commit.hex]

        obj = {
            '_id': commit.hex,
            'author': commit.author.name.strip(),
            'date': datetime.fromtimestamp(commit.commit_time),
            'merge': len(commit.parents) > 1,
            'tag': tag,
        }

        if len(commit.parents) == 1:
            diffs = commit.parents[0].tree.diff_to_tree(commit.tree, context_lines=0)
            stats = [(diff.additions, diff.deletions) for diff in diffs]
            if stats:
                obj['additions'], obj['deletions'] = map(sum, zip(*stats))

        batch[progress] = obj
        progress += 1

    if progress != 0:
        print(count + progress)
        commits.insert(batch[:progress])


def process_tags():
    bulk = []

    for name in repo.listall_references():
        if not name.startswith('refs/tags'):
            continue

        tag = repo.revparse_single(name)
        commit = tag.get_object()

        if commit.type != git.GIT_OBJ_COMMIT:
            continue

        bulk.append({
            '_id': name.split('/')[-1],
            'target': commit.hex,
            'date': datetime.fromtimestamp(commit.commit_time)
        })

    tags.insert(bulk)

if __name__ == "__main__":
    if False:
        process_commits()
    if False:
        process_tags()
    app.run(port=5000, debug=True)
