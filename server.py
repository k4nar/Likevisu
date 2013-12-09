import os

import pymongo

from flask import Flask, jsonify, send_file

from processor import process_commits

app = Flask(__name__)

client = pymongo.MongoClient()
db = client.likevisu
commits = db.commits
tags = db.tags


@app.route('/')
@app.route('/<path:path>')
def serve_files(path='index.html'):
    root = os.environ.get('FLASK_ROOT', 'app')
    dest = os.path.join(app.root_path, root, path)
    if os.path.isfile(dest):
        return send_file(dest)

    root = os.environ.get('FLASK_ROOT_ALT', '.tmp')
    dest = os.path.join(app.root_path, root, path)
    if os.path.isfile(dest):
        return send_file(dest)

    from werkzeug.exceptions import NotFound
    return NotFound()


@app.route("/versions")
def versions():
    query = tags.aggregate([
        {'$match': {'rc': 99}},
        {'$sort': {'_id': 1}},
        {'$project': {'id': '$_id', 'name': '$version'}},
    ])

    return jsonify(query)


@app.route("/authors/by_commits/<int:start>/<int:stop>/<int:limit>")
def top_authors_by_commits(start, stop, limit):
    top = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {'_id': '$author', 'count': {'$sum': 1}}},
        {'$sort': {'count': -1}},
        {'$limit': limit},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)


@app.route("/authors/by_lines/<int:start>/<int:stop>/<int:limit>")
def top_authors_by_lines(start, stop, limit):
    top = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {'_id': '$author', 'count': {'$sum': '$additions'}}},
        {'$sort': {'count': -1}},
        {'$limit': limit},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)


@app.route("/companies/by_commits/<int:start>/<int:stop>/<int:limit>")
def top_companies_by_commits(start, stop, limit):
    top = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {'_id': '$company', 'count': {'$sum': 1}}},
        {'$sort': {'count': -1}},
        {'$limit': limit},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)


@app.route("/companies/by_lines/<int:start>/<int:stop>/<int:limit>")
def top_companies_by_lines(start, stop, limit):
    top = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {'_id': '$company', 'count': {'$sum': '$additions'}}},
        {'$sort': {'count': -1}},
        {'$limit': limit},
        {'$project': {'name': '$_id', 'count': 1, '_id': 0}},
    ])

    return jsonify(top)


@app.route("/commits/by_date/<int:start>/<int:stop>")
def by_date(start, stop):
    query = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}}},
        {'$group': {
            '_id': {'$add': [
                {'$dayOfYear': '$date'},
                {'$multiply': [400, {'$year': '$date'}]}
            ]},
            'count': {'$sum': 1},
            'first': {'$min': '$date'},
        }},
        {'$sort': {'first': 1}}
    ])

    return jsonify({
        'dates': {str(v['first'].date()): v['count'] for v in query['result']},
        'start': query['result'][0]['first'].year,
        'stop': query['result'][-1]['first'].year,
    })


@app.route("/commits/diffs/<int:start>/<int:stop>")
def diffs(start, stop):
    query = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {
            '_id': '$tag.version',
            'additions': {'$sum': '$additions'},
            'deletions': {'$sum': '$deletions'},
            'version': {'$first': '$tag.name'},
            'version_nb': {'$first': '$tag.id'},
        }},
        {'$sort': {'version_nb': 1}},
        {'$project': {'_id': 0, 'additions': 1, 'deletions': 1, 'version': 1}},
    ])

    return jsonify(query)


@app.route("/commits/evolution/<int:start>/<int:stop>")
def authors_evolution(start, stop):
    query = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {
            '_id': '$tag.version',
            'count': {'$sum': 1},
            'version': {'$first': '$tag.name'},
            'version_nb': {'$first': '$tag.id'},
        }},
        {'$sort': {'version_nb': 1}},
        {'$project': {'_id': 0, 'count': 1, 'version': 1}},
    ])

    return jsonify(query)


@app.route("/authors/evolution/<int:start>/<int:stop>")
def evolution(start, stop):
    query = commits.aggregate([
        {'$match': {'tag.id': {'$gte': start, '$lte': stop}, 'merge': False}},
        {'$group': {
            '_id': '$tag.version',
            'authors': {'$addToSet': '$author'},
            'version': {'$first': '$tag.name'},
            'version_nb': {'$first': '$tag.id'},
        }},
        {'$sort': {'version_nb': 1}},
        {'$project': {'_id': 0, 'authors': 1, 'version': 1}},
    ])

    for row in query['result']:
        row['count'] = len(row['authors'])
        del row['authors']

    return jsonify(query)


if __name__ == "__main__":
    if False:
        process_commits(commits)
    debug = os.environ.get('FLASK_DEBUG', False)
    app.run(port=5000, debug=debug)
