# Want to contribute?

That's awesome, thank you!

The following is a set of guidelines for contributing to the MerMEId. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.


## Code of conduct

Please note that this project is released with a [Contributor Code of Conduct]. By participating in this project you agree to abide by its terms.


## I don't want to read this whole thing I just have a question!!!

The best way to initially get in touch with the MerMEId community is via the `mermeid` [Slack channel] on music-encoding.slack.com.
Or you can start a discussion here at [GitHub Discussions].


## Bug reports and feature requests

If you've noticed a bug or have a feature request, please open a [GitHub issue] (well, you might want to look through the open issues before to avoid creating duplicates)! It's generally best if you get confirmation of your bug or approval for your feature request this way before starting to code.


## Fork & create a branch

If this is something you think you can fix, then [fork this repo] and create
a branch with a descriptive name. Please keep in mind that before coding along there should be a ticket for the task you want to accomplish.

A good branch name would be (where issue #33 is the ticket you're working on):

```sh
git checkout -b issue-33
```

## Build and test your branch locally

With [Docker installed] you simply tell it to build your locally checked out branch ("issue-33") with

```sh
docker build -t mermeid:issue-33
```

and then you run it like 

```sh
docker run --name mermeid-issue-33 -p 8080:8080 -d mermeid:issue-33
```

## Make a Pull Request

If everything works as expected, you should switch back to your develop branch and make sure it's up to date with our develop (= our default) branch:
```sh
git remote add upstream git@github.com:edirom/MerMEId.git
git checkout develop
git pull upstream develop
```

Then update your feature branch from your local copy of develop, and push it

```sh
git checkout issue-33
git rebase develop
git push --set-upstream origin issue-33
```

Finally, go to GitHub and [make a Pull Request]

## Merging a PR (maintainers only)

A PR can only be merged into master by a maintainer if:

* It is passing CI.
* It has been approved by at least two maintainers. If it was a maintainer who opened the PR, only one extra approval is needed.
* It has no requested changes.
* It is up to date with current develop.

Any maintainer is allowed to merge a PR if all of these conditions are
met.


## Acknowledgements

Large portions of these Contributing Guidelines were copied from [ActiveAdmin]. Thanks!

[Contributor Code of Conduct]: CODE_OF_CONDUCT.md
[Slack channel]: https://join.slack.com/t/music-encoding/shared_invite/zt-4zgx6zbq-2jEjDiUT7ym3dygTaY8C0g 
[GitHub Discussions]: https://github.com/Edirom/MerMEId/discussions
[GitHub issue]: https://github.com/Edirom/MerMEId/issues/new
[fork this repo]: https://help.github.com/articles/fork-a-repo
[Docker installed]: https://docs.docker.com/get-docker/
[make a pull request]: https://help.github.com/articles/creating-a-pull-request
[ActiveAdmin]: https://github.com/activeadmin/activeadmin/blob/HEAD/CONTRIBUTING.md
