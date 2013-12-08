from datetime import datetime

import pygit2 as git

repo = git.Repository('/home/yannick/linux')


def get_tags():
    tags = {}

    for name in repo.listall_references():
        if not name.startswith('refs/tags'):
            continue

        tag = repo.revparse_single(name)
        commit = tag.get_object()

        if commit.type != git.GIT_OBJ_COMMIT:
            continue

        name = name.split('/')[-1]
        version = name.split('-')[0][1:]
        rc = int(name.split('-')[-1][2:]) if 'rc' in name else 99
        version_id = sum(map(lambda x: x[0] * x[1], zip((1000000, 10000, 100), map(int, version.split('.'))))) + rc

        tags[tag.target.hex] = {
            'id': version_id,
            'version': version,
            'rc': rc,
            'name': name
        }

    return tags


def process_commits(commits):
    size = 1000
    batch = [None] * size
    progress = 0
    count = 0

    refs = get_tags()
    tag = None

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